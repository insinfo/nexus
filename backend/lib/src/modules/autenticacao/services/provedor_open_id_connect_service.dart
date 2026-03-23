import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/app_config.dart';
import '../../../shared/utils/seguranca_utils.dart';
import '../repositories/autenticacao_repository.dart';
import '../repositories/provedor_oidc_repository.dart';
import 'assinador_token_oidc_service.dart';
import 'autenticacao_exception.dart';
import 'federacao_microsoft_service.dart';
import 'oidc_session_redis_service.dart';
import 'provedor_open_id_connect_port.dart';

class ProvedorOpenIdConnectService implements ProvedorOpenIdConnectPort {
  ProvedorOpenIdConnectService(
    this.db,
    this.config,
    this.autenticacaoRepository,
    this.provedorOidcRepository,
    this.assinadorTokenOidcService,
    this.oidcSessionRedisService,
    this.federacaoMicrosoftService,
  );

  final Connection db;
  final AppConfig config;
  final AutenticacaoRepository autenticacaoRepository;
  final ProvedorOidcRepository provedorOidcRepository;
  final AssinadorTokenOidcService assinadorTokenOidcService;
  final OidcSessionRedisService oidcSessionRedisService;
  final FederacaoMicrosoftService federacaoMicrosoftService;

  @override
  DocumentoDescobertaOpenIdConnect obterDocumentoDescoberta() {
    final issuer = config.issuerOpenIdConnect;
    return DocumentoDescobertaOpenIdConnect(
      issuer: issuer,
      endpointAutorizacao: '$issuer/oidc/authorize',
      endpointToken: '$issuer/oidc/token',
      endpointInformacoesUsuario: '$issuer/oidc/userinfo',
      uriConjuntoChaves: '$issuer/oidc/jwks',
      endpointEncerrarSessao: '$issuer/oidc/logout',
      escoposSuportados: const <String>[
        'openid',
        'profile',
        'email',
        'offline_access',
        'nexus.servicos',
      ],
      tiposRespostaSuportados: const <String>['code'],
      tiposConcessaoSuportados: const <String>[
        'authorization_code',
        'refresh_token',
      ],
      tiposAssuntoSuportados: const <String>['public'],
      algoritmosAssinaturaIdTokenSuportados: const <String>['RS256'],
      metodosAutenticacaoEndpointTokenSuportados: const <String>[
        'none',
        'client_secret_post',
        'client_secret_basic',
      ],
      claimsSuportados: const <String>[
        'sub',
        'preferred_username',
        'name',
        'email',
        'email_verified',
        'tipo_conta',
        'sid',
      ],
      metodosCodeChallengeSuportados: const <String>['S256', 'plain'],
    );
  }

  @override
  ConjuntoChavesJsonWeb obterConjuntoChaves() {
    return assinadorTokenOidcService.obterConjuntoChaves();
  }

  @override
  Future<ResultadoAutorizacaoOidc> autorizar(
    RequisicaoAutorizarOidc requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    final agora = DateTime.now().toUtc();
    final escoposSolicitados = _normalizarEscopos(requisicao.escopos);
    if (requisicao.responseType.trim() != 'code') {
      throw AutenticacaoException(
        'O backend OIDC do Nexus suporta apenas response_type=code.',
        statusCode: 400,
      );
    }
    if (requisicao.clientId.trim().isEmpty) {
      throw AutenticacaoException('client_id obrigatorio.', statusCode: 400);
    }
    if (requisicao.redirectUri.trim().isEmpty) {
      throw AutenticacaoException('redirect_uri obrigatorio.', statusCode: 400);
    }
    if (escoposSolicitados.isEmpty || !escoposSolicitados.contains('openid')) {
      throw AutenticacaoException(
        'O fluxo OIDC requer o escopo openid.',
        statusCode: 400,
      );
    }
    if (requisicao.identificador.trim().isEmpty || requisicao.senha.isEmpty) {
      throw AutenticacaoException(
        'Identificador e senha sao obrigatorios para autorizar o usuario.',
        statusCode: 400,
      );
    }

    final resultado = await db.transaction((Connection ctx) async {
      final cliente = await _obterClienteAtivo(ctx, requisicao.clientId);
      _validarClienteAutorizacao(cliente, requisicao, escoposSolicitados);

      final usuario = await autenticacaoRepository.findUsuarioPorIdentificador(
        ctx,
        requisicao.identificador,
      );
      if (usuario == null ||
          usuario.hashSenha == null ||
          !SegurancaUtils.validarSenha(requisicao.senha, usuario.hashSenha!)) {
        throw AutenticacaoException(
          'Credenciais invalidas para o fluxo OIDC.',
          statusCode: 401,
        );
      }
      if (!usuario.ativo) {
        throw AutenticacaoException(
          'Usuario inativo para emissao OIDC.',
          statusCode: 403,
        );
      }

      await _registrarConsentimento(
        ctx,
        cliente: cliente,
        usuario: usuario,
        escoposSolicitados: escoposSolicitados,
      );

      final codigoBruto = SegurancaUtils.gerarTokenSeguro(tamanho: 48);
      await provedorOidcRepository.createCodigoAutorizacao(
        ctx,
        CodigoAutorizacaoOidc(
          hashCodigo: SegurancaUtils.gerarHashToken(codigoBruto),
          idCliente: cliente.idCliente,
          idUsuario: usuario.id,
          escopos: escoposSolicitados,
          uriRedirecionamento: requisicao.redirectUri.trim(),
          expiraEm: agora.add(const Duration(minutes: 5)),
          desafioPkce: requisicao.codeChallenge?.trim(),
          metodoDesafioPkce: requisicao.codeChallengeMethod.trim(),
          nonce: requisicao.nonce?.trim(),
          loginGovbr: false,
          criadoEm: agora,
        ),
      );

      await autenticacaoRepository.updateUltimoLogin(ctx, usuario.id!, agora);

      return ResultadoAutorizacaoOidc(
        codigo: codigoBruto,
        redirectUri: requisicao.redirectUri.trim(),
        state: requisicao.state?.trim().isEmpty == true
            ? null
            : requisicao.state?.trim(),
        nonce: requisicao.nonce?.trim().isEmpty == true
            ? null
            : requisicao.nonce?.trim(),
      );
    });
    return resultado as ResultadoAutorizacaoOidc;
  }

  @override
  Future<ResultadoTokenOidc> trocarToken(
    RequisicaoTokenOidc requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    final grantType = requisicao.grantType.trim();
    if (grantType == 'authorization_code') {
      return _trocarAuthorizationCode(
        requisicao,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
    }
    if (grantType == 'refresh_token') {
      return _trocarRefreshToken(
        requisicao,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
    }
    throw AutenticacaoException(
      'grant_type nao suportado pelo provedor OIDC do Nexus.',
      statusCode: 400,
    );
  }

  @override
  Future<ResultadoUsuarioInfoOidc> obterUsuarioInfo(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw AutenticacaoException(
        'Bearer token obrigatorio no endpoint userinfo.',
        statusCode: 401,
      );
    }

    final resultado = await db.transaction((Connection ctx) async {
      final tokenPersistido =
          await provedorOidcRepository.findTokenAcessoPorHash(
        ctx,
        SegurancaUtils.gerarHashToken(token),
      );
      if (tokenPersistido == null || tokenPersistido.revogado) {
        throw AutenticacaoException(
          'Access token invalido.',
          statusCode: 401,
        );
      }
      final agora = DateTime.now().toUtc();
      if (tokenPersistido.expiraEm != null &&
          tokenPersistido.expiraEm!.isBefore(agora)) {
        throw AutenticacaoException(
          'Access token expirado.',
          statusCode: 401,
        );
      }

      final sessionState = tokenPersistido.claims['sid']?.toString();
      if (sessionState == null || sessionState.trim().isEmpty) {
        throw AutenticacaoException(
          'Access token sem vinculo de sessao OIDC compartilhada.',
          statusCode: 401,
        );
      }

      final sessaoRedis = await oidcSessionRedisService.obterSessao(sessionState);
      if (sessaoRedis == null) {
        throw AutenticacaoException(
          'Sessao OIDC nao encontrada no Redis compartilhado.',
          statusCode: 401,
        );
      }

      final usuario = await autenticacaoRepository.findUsuarioPorId(
        ctx,
        tokenPersistido.idUsuario!,
      );
      return _montarUsuarioInfo(usuario);
    });
    return resultado as ResultadoUsuarioInfoOidc;
  }

  @override
  ResultadoIniciarFederacaoOidc iniciarFederacao(
    RequisicaoIniciarFederacaoOidc requisicao,
  ) {
    if (requisicao.nomeProvedor.trim().toLowerCase() != 'microsoft') {
      throw AutenticacaoException(
        'Apenas a federacao Microsoft Active Directory esta modelada neste momento.',
        statusCode: 400,
      );
    }
    return federacaoMicrosoftService.iniciar(requisicao);
  }

  @override
  Future<void> encerrarSessao({
    String? sessionState,
    String? accessToken,
  }) async {
    final sessionStateNormalizado = sessionState?.trim() ?? '';
    final accessTokenNormalizado = accessToken?.trim() ?? '';
    if (sessionStateNormalizado.isEmpty && accessTokenNormalizado.isEmpty) {
      throw AutenticacaoException(
        'Informe session_state ou access token para logout OIDC.',
        statusCode: 400,
      );
    }

    var sid = sessionStateNormalizado;
    if (accessTokenNormalizado.isNotEmpty) {
      final resultado = await db.transaction((Connection ctx) async {
        final token = await provedorOidcRepository.findTokenAcessoPorHash(
          ctx,
          SegurancaUtils.gerarHashToken(accessTokenNormalizado),
        );
        if (token == null) {
          return null;
        }
        await provedorOidcRepository.revogarTokenAcesso(ctx, token.id!);
        if (token.idTokenRefresh != null) {
          await provedorOidcRepository.revogarTokenRefresh(
            ctx,
            token.idTokenRefresh!,
          );
        }
        return token;
      });
      final token = resultado as TokenAcessoOidc?;
      sid = sid.isNotEmpty ? sid : token?.claims['sid']?.toString() ?? '';
    }

    if (sid.isEmpty) {
      throw AutenticacaoException(
        'Nao foi possivel determinar a sessao OIDC a ser encerrada.',
        statusCode: 400,
      );
    }
    await oidcSessionRedisService.removerSessao(sid);
  }

  Future<ResultadoTokenOidc> _trocarAuthorizationCode(
    RequisicaoTokenOidc requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    final agora = DateTime.now().toUtc();
    final code = requisicao.code?.trim() ?? '';
    final redirectUri = requisicao.redirectUri?.trim() ?? '';
    final codeVerifier = requisicao.codeVerifier?.trim() ?? '';
    if (code.isEmpty) {
      throw AutenticacaoException('code obrigatorio.', statusCode: 400);
    }
    if (redirectUri.isEmpty) {
      throw AutenticacaoException('redirect_uri obrigatorio.', statusCode: 400);
    }
    if (codeVerifier.isEmpty) {
      throw AutenticacaoException('code_verifier obrigatorio.',
          statusCode: 400);
    }

    final resultado = await db.transaction((Connection ctx) async {
      final cliente = await _validarClienteToken(ctx, requisicao);
      final codigo = await provedorOidcRepository.findCodigoAutorizacaoPorHash(
        ctx,
        SegurancaUtils.gerarHashToken(code),
      );
      if (codigo == null) {
        throw AutenticacaoException(
          'Authorization code invalido.',
          statusCode: 400,
        );
      }
      if (codigo.idCliente != cliente.idCliente) {
        throw AutenticacaoException(
          'Authorization code nao pertence ao client_id informado.',
          statusCode: 400,
        );
      }
      if (codigo.uriRedirecionamento != redirectUri) {
        throw AutenticacaoException(
          'redirect_uri diferente da autorizacao original.',
          statusCode: 400,
        );
      }
      if (codigo.expiraEm != null && codigo.expiraEm!.isBefore(agora)) {
        await provedorOidcRepository.deleteCodigoAutorizacao(ctx, codigo.id!);
        throw AutenticacaoException(
          'Authorization code expirado.',
          statusCode: 400,
        );
      }
      final desafioPkce = codigo.desafioPkce?.trim() ?? '';
      final metodoPkce = codigo.metodoDesafioPkce?.trim().isEmpty == true
          ? 'S256'
          : codigo.metodoDesafioPkce!.trim();
      if (desafioPkce.isEmpty ||
          !SegurancaUtils.validarPkce(
            codeVerifier: codeVerifier,
            codeChallenge: desafioPkce,
            metodo: metodoPkce,
          )) {
        throw AutenticacaoException(
          'Falha na validacao do PKCE.',
          statusCode: 400,
        );
      }

      final usuario = await autenticacaoRepository.findUsuarioPorId(
        ctx,
        codigo.idUsuario!,
      );
      final resultado = await _emitirTokens(
        ctx,
        cliente: cliente,
        usuario: usuario,
        escopos: codigo.escopos,
        nonce: codigo.nonce,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
      await provedorOidcRepository.deleteCodigoAutorizacao(ctx, codigo.id!);
      return resultado;
    });
    return resultado as ResultadoTokenOidc;
  }

  Future<ResultadoTokenOidc> _trocarRefreshToken(
    RequisicaoTokenOidc requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    final tokenBruto = requisicao.refreshToken?.trim() ?? '';
    if (tokenBruto.isEmpty) {
      throw AutenticacaoException('refresh_token obrigatorio.',
          statusCode: 400);
    }
    final agora = DateTime.now().toUtc();

    final resultado = await db.transaction((Connection ctx) async {
      final cliente = await _validarClienteToken(ctx, requisicao);
      final token = await provedorOidcRepository.findTokenRefreshPorHash(
        ctx,
        SegurancaUtils.gerarHashToken(tokenBruto),
      );
      if (token == null || token.revogado) {
        throw AutenticacaoException(
          'Refresh token invalido.',
          statusCode: 400,
        );
      }
      if (token.idCliente != cliente.idCliente) {
        throw AutenticacaoException(
          'Refresh token nao pertence ao client_id informado.',
          statusCode: 400,
        );
      }
      if (token.expiraEm != null && token.expiraEm!.isBefore(agora)) {
        await provedorOidcRepository.revogarTokenRefresh(ctx, token.id!);
        throw AutenticacaoException(
          'Refresh token expirado.',
          statusCode: 400,
        );
      }

      final usuario = await autenticacaoRepository.findUsuarioPorId(
        ctx,
        token.idUsuario!,
      );
      await provedorOidcRepository.revogarTokenRefresh(ctx, token.id!);
      return _emitirTokens(
        ctx,
        cliente: cliente,
        usuario: usuario,
        escopos: token.escopos,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
    });
    return resultado as ResultadoTokenOidc;
  }

  Future<ResultadoTokenOidc> _emitirTokens(
    Connection ctx, {
    required ClienteOidc cliente,
    required Usuario usuario,
    required List<String> escopos,
    String? nonce,
    String? enderecoIp,
    String? userAgent,
  }) async {
    final agora = DateTime.now().toUtc();
    final refreshTokenBruto = SegurancaUtils.gerarTokenSeguro(tamanho: 48);
    final accessTokenBruto = SegurancaUtils.gerarTokenSeguro(tamanho: 48);
    final refreshToken = await provedorOidcRepository.createTokenRefresh(
      ctx,
      TokenRefreshOidc(
        hashToken: SegurancaUtils.gerarHashToken(refreshTokenBruto),
        idCliente: cliente.idCliente,
        idUsuario: usuario.id,
        escopos: escopos,
        expiraEm: agora.add(const Duration(days: 30)),
        criadoEm: agora,
        revogado: false,
      ),
    );
    final sessao = await autenticacaoRepository.createSessao(
      ctx,
      SessaoAutenticacao(
        idUsuario: usuario.id,
        hashRefreshToken: SegurancaUtils.gerarHashToken(refreshTokenBruto),
        enderecoIp: enderecoIp,
        userAgent: userAgent,
        expiraEm: agora.add(const Duration(days: 30)),
        criadoEm: agora,
      ),
    );
    final sessionState = sessao.idPublico ?? SegurancaUtils.gerarTokenSeguro();
    await oidcSessionRedisService.salvarSessao(
      sessionState: sessionState,
      ttl: const Duration(days: 30),
      dados: <String, dynamic>{
        'sid': sessionState,
        'id_usuario': usuario.id,
        'sub': _subjectUsuario(usuario),
        'client_id': cliente.idCliente,
        'scopes': escopos,
        'auth_time': agora.toIso8601String(),
        'nonce': nonce,
        'refresh_token_hash': SegurancaUtils.gerarHashToken(refreshTokenBruto),
      },
    );

    final claimsAccessToken = <String, dynamic>{
      'iss': config.issuerOpenIdConnect,
      'sub': _subjectUsuario(usuario),
      'aud': <String>[cliente.idCliente],
      'client_id': cliente.idCliente,
      'scope': escopos.join(' '),
      'preferred_username': usuario.nomeUsuario,
      'email': usuario.email,
      'tipo_conta': usuario.tipoConta,
      'sid': sessionState,
    };
    final tokenAcesso = await provedorOidcRepository.createTokenAcesso(
      ctx,
      TokenAcessoOidc(
        hashToken: SegurancaUtils.gerarHashToken(accessTokenBruto),
        idCliente: cliente.idCliente,
        idUsuario: usuario.id,
        idTokenRefresh: refreshToken.id,
        escopos: escopos,
        tipoToken: 'bearer',
        expiraEm: agora.add(const Duration(hours: 2)),
        revogado: false,
        claims: claimsAccessToken,
        criadoEm: agora,
      ),
    );

    final idTokenClaims = <String, dynamic>{
      'iss': config.issuerOpenIdConnect,
      'sub': _subjectUsuario(usuario),
      'aud': <String>[cliente.idCliente],
      'azp': cliente.idCliente,
      'exp': agora.add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      'iat': agora.millisecondsSinceEpoch ~/ 1000,
      'auth_time': agora.millisecondsSinceEpoch ~/ 1000,
      'preferred_username': usuario.nomeUsuario,
      'name': usuario.nomeExibicao.isEmpty
          ? usuario.nomeUsuario
          : usuario.nomeExibicao,
      'email': usuario.email,
      'email_verified': usuario.email.trim().isNotEmpty,
      'tipo_conta': usuario.tipoConta,
      'sid': sessionState,
      if ((nonce ?? '').trim().isNotEmpty) 'nonce': nonce!.trim(),
    };
    final idTokenBruto = assinadorTokenOidcService.assinarJwt(idTokenClaims);
    await provedorOidcRepository.createTokenId(
      ctx,
      TokenIdOidc(
        hashToken: SegurancaUtils.gerarHashToken(idTokenBruto),
        idCliente: cliente.idCliente,
        idUsuario: usuario.id,
        idTokenAcesso: tokenAcesso.id,
        nonce: nonce,
        hashSessao: sessionState.isEmpty
            ? null
          : SegurancaUtils.gerarHashToken(sessionState),
        expiraEm: agora.add(const Duration(hours: 2)),
        revogado: false,
        claims: idTokenClaims,
        criadoEm: agora,
      ),
    );
    await autenticacaoRepository.updateUltimoLogin(ctx, usuario.id!, agora);

    return ResultadoTokenOidc(
      accessToken: accessTokenBruto,
      tokenType: 'Bearer',
      expiresIn: 7200,
      refreshToken: refreshTokenBruto,
      idToken: idTokenBruto,
      scope: escopos.join(' '),
      sessionState: sessionState,
    );
  }

  Future<ClienteOidc> _obterClienteAtivo(
      Connection ctx, String clientId) async {
    final cliente =
        await provedorOidcRepository.findCliente(ctx, clientId.trim());
    if (cliente == null || !cliente.ativo) {
      throw AutenticacaoException('Cliente OIDC invalido.', statusCode: 400);
    }
    return cliente;
  }

  void _validarClienteAutorizacao(
    ClienteOidc cliente,
    RequisicaoAutorizarOidc requisicao,
    List<String> escoposSolicitados,
  ) {
    if (!cliente.tiposRespostaSuportados.contains('code')) {
      throw AutenticacaoException(
        'Cliente OIDC nao suporta authorization code.',
        statusCode: 400,
      );
    }
    if (!cliente.tiposGrantSuportados.contains('authorization_code')) {
      throw AutenticacaoException(
        'Cliente OIDC nao suporta authorization_code.',
        statusCode: 400,
      );
    }
    if (!cliente.urisRedirecionamento.contains(requisicao.redirectUri.trim())) {
      throw AutenticacaoException(
        'redirect_uri nao cadastrado para o client_id.',
        statusCode: 400,
      );
    }
    final escoposNaoPermitidos = escoposSolicitados
        .where((String item) => !cliente.escoposPermitidos.contains(item))
        .toList(growable: false);
    if (escoposNaoPermitidos.isNotEmpty) {
      throw AutenticacaoException(
        'Escopos nao permitidos para o cliente: ${escoposNaoPermitidos.join(', ')}.',
        statusCode: 400,
      );
    }
    final exigePkce = cliente.tipoAplicacao == 'web_spa' ||
        cliente.tipoAplicacao == 'aplicativo_nativo';
    if (exigePkce) {
      final challenge = requisicao.codeChallenge?.trim() ?? '';
      if (challenge.isEmpty) {
        throw AutenticacaoException(
          'Clientes publicos exigem code_challenge.',
          statusCode: 400,
        );
      }
      final metodo = requisicao.codeChallengeMethod.trim().toUpperCase();
      if (metodo != 'S256' && metodo != 'PLAIN') {
        throw AutenticacaoException(
          'code_challenge_method nao suportado.',
          statusCode: 400,
        );
      }
    }
  }

  Future<void> _registrarConsentimento(
    Connection ctx, {
    required ClienteOidc cliente,
    required Usuario usuario,
    required List<String> escoposSolicitados,
  }) async {
    final existente = await provedorOidcRepository.findConsentimentoAtivo(
      ctx,
      cliente.idCliente,
      usuario.id!,
    );
    if (existente == null) {
      await provedorOidcRepository.saveConsentimento(
        ctx,
        ConsentimentoOidc(
          idCliente: cliente.idCliente,
          idUsuario: usuario.id,
          escoposConcedidos: escoposSolicitados,
          claimsConcedidas: const <String, dynamic>{},
          origemConsentimento: 'tela_login',
          concedidoEm: DateTime.now().toUtc(),
          observacoes: 'Consentimento automatico do portal Nexus.',
        ),
      );
      return;
    }

    final escoposAtualizados = _normalizarEscopos(
      <String>[...existente.escoposConcedidos, ...escoposSolicitados],
    );
    final atualizado = existente.clone()
      ..escoposConcedidos = escoposAtualizados
      ..concedidoEm = DateTime.now().toUtc();
    await provedorOidcRepository.saveConsentimento(ctx, atualizado);
  }

  Future<ClienteOidc> _validarClienteToken(
    Connection ctx,
    RequisicaoTokenOidc requisicao,
  ) async {
    if (requisicao.clientId.trim().isEmpty) {
      throw AutenticacaoException('client_id obrigatorio.', statusCode: 400);
    }
    final cliente = await _obterClienteAtivo(ctx, requisicao.clientId);
    if (!cliente.tiposGrantSuportados.contains(requisicao.grantType.trim())) {
      throw AutenticacaoException(
        'Cliente OIDC nao suporta o grant_type solicitado.',
        statusCode: 400,
      );
    }

    final metodo = cliente.metodoAutenticacaoToken.trim();
    if (metodo == 'none') {
      return cliente;
    }

    final secret = requisicao.clientSecret?.trim() ?? '';
    if (secret.isEmpty ||
        cliente.hashSegredoCliente == null ||
        !SegurancaUtils.validarSenha(secret, cliente.hashSegredoCliente!)) {
      throw AutenticacaoException(
        'Falha na autenticacao do cliente OIDC.',
        statusCode: 401,
      );
    }
    return cliente;
  }

  ResultadoUsuarioInfoOidc _montarUsuarioInfo(Usuario usuario) {
    return ResultadoUsuarioInfoOidc(
      sub: _subjectUsuario(usuario),
      preferredUsername: usuario.nomeUsuario,
      name: usuario.nomeExibicao.isEmpty
          ? usuario.nomeUsuario
          : usuario.nomeExibicao,
      email: usuario.email,
      emailVerified: usuario.email.trim().isNotEmpty,
      tipoConta: usuario.tipoConta,
    );
  }

  String _subjectUsuario(Usuario usuario) {
    return usuario.idPublico?.trim().isNotEmpty == true
        ? usuario.idPublico!.trim()
        : '${usuario.id ?? ''}';
  }

  List<String> _normalizarEscopos(List<String> escopos) {
    final itens = <String>{};
    for (final item in escopos) {
      final valor = item.trim();
      if (valor.isNotEmpty) {
        itens.add(valor);
      }
    }
    return itens.toList(growable: false);
  }
}
