import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:ngdart/angular.dart';
import 'package:nexus_core/nexus_core.dart';

import 'servico_http_base.dart';

class ResultadoSessaoOidcPortal {
  const ResultadoSessaoOidcPortal({
    required this.token,
    required this.usuarioInfo,
  });

  final ResultadoTokenOidc token;
  final ResultadoUsuarioInfoOidc usuarioInfo;
}

@Injectable()
class OidcService {
  static const String _oidcClientId = 'nexus-frontend-portal';
  static const List<String> _oidcEscopos = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
    'nexus.servicos',
  ];

  OidcService(this._servicoHttpBase);

  final ServicoHttpBase _servicoHttpBase;
  final Random _random = Random.secure();

  Future<ResultadoSessaoOidcPortal> autenticar({
    required String identificador,
    required String senha,
  }) async {
    final codeVerifier = _gerarCodeVerifier();
    final autorizacaoJson = await _servicoHttpBase.sendJsonMap(
      '/oidc/authorize',
      metodo: 'POST',
      corpo: RequisicaoAutorizarOidc(
        responseType: 'code',
        clientId: _oidcClientId,
        redirectUri: redirectUriOidc,
        escopos: _oidcEscopos,
        state: _gerarValorAleatorio(tamanho: 18),
        nonce: _gerarValorAleatorio(tamanho: 18),
        codeChallenge: _gerarCodeChallenge(codeVerifier),
        codeChallengeMethod: 'S256',
        identificador: identificador,
        senha: senha,
      ).toMap(),
    );
    final autorizacao = ResultadoAutorizacaoOidc.fromMap(autorizacaoJson);

    final tokenJson = await _servicoHttpBase.sendJsonMap(
      '/oidc/token',
      metodo: 'POST',
      corpo: RequisicaoTokenOidc(
        grantType: 'authorization_code',
        clientId: _oidcClientId,
        code: autorizacao.codigo,
        redirectUri: redirectUriOidc,
        codeVerifier: codeVerifier,
      ).toMap(),
    );
    final token = ResultadoTokenOidc.fromMap(tokenJson);

    final usuarioInfoJson = await _servicoHttpBase.sendJsonMap(
      '/oidc/userinfo',
      metodo: 'GET',
      headers: <String, String>{
        'Authorization': 'Bearer ${token.accessToken}',
      },
    );
    final usuarioInfo = ResultadoUsuarioInfoOidc.fromMap(usuarioInfoJson);

    return ResultadoSessaoOidcPortal(
      token: token,
      usuarioInfo: usuarioInfo,
    );
  }

  Future<void> encerrarSessao({
    String? sessionState,
    String? accessToken,
  }) async {
    await _servicoHttpBase.sendJsonMap(
      '/oidc/logout',
      metodo: 'POST',
      corpo: <String, dynamic>{
        'session_state': sessionState,
      },
      headers: <String, String>{
        if ((accessToken ?? '').isNotEmpty)
          'Authorization': 'Bearer ${accessToken!}',
      },
    );
  }

  Future<ResultadoIniciarFederacaoOidc> iniciarFederacaoMicrosoft() async {
    final codeVerifier = _gerarCodeVerifier();
    final jsonMap = await _servicoHttpBase.sendJsonMap(
      '/oidc/federacao/microsoft/iniciar',
      metodo: 'POST',
      corpo: RequisicaoIniciarFederacaoOidc(
        nomeProvedor: 'microsoft',
        clientId: _oidcClientId,
        redirectUri: redirectUriOidc,
        escopos: _oidcEscopos,
        state: _gerarValorAleatorio(tamanho: 18),
        nonce: _gerarValorAleatorio(tamanho: 18),
        codeChallenge: _gerarCodeChallenge(codeVerifier),
        codeChallengeMethod: 'S256',
      ).toMap(),
    );
    return ResultadoIniciarFederacaoOidc.fromMap(jsonMap);
  }

  void redirecionarParaAutorizacao(String urlAutorizacao) {
    window.location.assign(urlAutorizacao);
  }

  ResultadoAutenticacaoUsuario criarSessaoUsuario(
    ResultadoTokenOidc token,
    ResultadoUsuarioInfoOidc usuarioInfo,
  ) {
    final nomeUsuario =
        usuarioInfo.preferredUsername ?? usuarioInfo.email ?? usuarioInfo.sub;
    final nomeExibicao = usuarioInfo.name ?? nomeUsuario;
    return ResultadoAutenticacaoUsuario(
      usuario: Usuario(
        idPublico: usuarioInfo.sub,
        nomeUsuario: nomeUsuario,
        email: usuarioInfo.email ?? '',
        nomeExibicao: nomeExibicao,
        tipoConta: usuarioInfo.tipoConta ?? 'cidadao',
        ativo: true,
      ),
      tokenAcesso: token.accessToken,
      refreshToken: token.refreshToken ?? '',
      tipoToken: token.tokenType,
      expiraEm: DateTime.now().add(Duration(seconds: token.expiresIn)),
    );
  }

  String get redirectUriOidc {
    final uri = Uri.base.removeFragment();
    final path = uri.path.isEmpty ? '/' : uri.path;
    return uri
        .replace(
          path: path,
          queryParameters: <String, String>{},
          fragment: '',
        )
        .toString();
  }

  String _gerarCodeVerifier() {
    return _base64UrlSemPadding(
      List<int>.generate(48, (_) => _random.nextInt(256)),
    );
  }

  String _gerarCodeChallenge(String codeVerifier) {
    return _base64UrlSemPadding(
      sha256.convert(utf8.encode(codeVerifier)).bytes,
    );
  }

  String _gerarValorAleatorio({int tamanho = 24}) {
    return _base64UrlSemPadding(
      List<int>.generate(tamanho, (_) => _random.nextInt(256)),
    );
  }

  String _base64UrlSemPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}