import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/utils/seguranca_utils.dart';
import '../repositories/autenticacao_repository.dart';
import 'autenticacao_exception.dart';
import 'autenticacao_port.dart';

class AutenticacaoService implements AutenticacaoPort {
  AutenticacaoService(this.db, this.repository);

  final Connection db;
  final AutenticacaoRepository repository;

  @override
  Future<ResultadoAutenticacaoUsuario> cadastrar(
    RequisicaoCadastroUsuario requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    _validarCadastro(requisicao);

    return await db.transaction((Connection ctx) async {
      final existe = await repository.existsUsuarioCadastro(ctx, requisicao);
      if (existe) {
        throw AutenticacaoException(
          'Ja existe usuario cadastrado com os dados informados.',
          statusCode: 409,
        );
      }

      final agora = DateTime.now();
      final usuarioSalvo = await repository.saveUsuario(
        ctx,
        Usuario(
          nomeUsuario: requisicao.nomeUsuario.trim(),
          email: requisicao.email.trim().toLowerCase(),
          hashSenha: SegurancaUtils.gerarHashSenha(requisicao.senha),
          nomeExibicao: requisicao.nomeExibicao.trim(),
          tipoConta: 'cidadao',
          ativo: true,
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );

      final conta = await repository.saveContaCidadao(
        ctx,
        ContaCidadao(
          idUsuario: usuarioSalvo.id,
          cpf: _normalizarDocumento(requisicao.cpf),
          telefone: requisicao.telefone?.trim(),
          dataNascimento: requisicao.dataNascimento,
          metadados: const <String, dynamic>{},
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );

      return _criarResultadoAutenticacao(
        ctx,
        usuarioSalvo,
        conta,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
    });
  }

  @override
  Future<ResultadoAutenticacaoUsuario> login(
    RequisicaoLoginUsuario requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    final identificador = requisicao.identificador.trim();
    final senha = requisicao.senha;

    if (identificador.isEmpty || senha.isEmpty) {
      throw AutenticacaoException(
        'Informe identificador e senha para entrar.',
      );
    }

    return await db.transaction((Connection ctx) async {
      final usuario = await repository.findUsuarioPorIdentificador(
        ctx,
        identificador,
      );
      if (usuario == null || usuario.hashSenha == null) {
        throw AutenticacaoException(
          'Credenciais invalidas.',
          statusCode: 401,
        );
      }

      final senhaValida = SegurancaUtils.validarSenha(senha, usuario.hashSenha!);
      if (!senhaValida || !usuario.ativo) {
        throw AutenticacaoException(
          'Credenciais invalidas.',
          statusCode: 401,
        );
      }

      final conta = await repository.findContaCidadaoPorUsuario(ctx, usuario.id!);
      return _criarResultadoAutenticacao(
        ctx,
        usuario,
        conta,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
    });
  }

  @override
  Future<ResultadoSolicitacaoRedefinicaoSenha> solicitarRedefinicaoSenha(
    RequisicaoSolicitarRedefinicaoSenha requisicao, {
    String? enderecoIp,
  }) async {
    final identificador = requisicao.identificador.trim();
    if (identificador.isEmpty) {
      throw AutenticacaoException('Informe email, usuario ou CPF para continuar.');
    }

    return await db.transaction((Connection ctx) async {
      final agora = DateTime.now();
      final controle = await repository.findControleRedefinicao(ctx, identificador);
      if (controle?.ultimaSolicitacaoEm != null &&
          agora.difference(controle!.ultimaSolicitacaoEm!).inSeconds < 60) {
        throw AutenticacaoException(
          'Aguarde alguns instantes antes de solicitar nova redefinicao.',
          statusCode: 429,
        );
      }

      await repository.saveControleRedefinicao(
        ctx,
        ControleRedefinicaoSenha(
          identificadorUsuario: identificador,
          ultimaSolicitacaoEm: agora,
          ultimoIp: enderecoIp,
        ),
      );

      final usuario = await repository.findUsuarioPorIdentificador(
        ctx,
        identificador,
      );
      if (usuario == null) {
        return ResultadoSolicitacaoRedefinicaoSenha(
          mensagem: 'Se o identificador existir, um token temporario foi gerado.',
        );
      }

      final token = SegurancaUtils.gerarTokenSeguro();
      final expiraEm = agora.add(const Duration(minutes: 30));
      await repository.replaceRedefinicaoSenha(
        ctx,
        RedefinicaoSenha(
          idUsuario: usuario.id,
          hashToken: SegurancaUtils.gerarHashToken(token),
          expiraEm: expiraEm,
          criadoEm: agora,
        ),
      );

      return ResultadoSolicitacaoRedefinicaoSenha(
        mensagem: 'Token temporario gerado com sucesso.',
        token: token,
        expiraEm: expiraEm,
      );
    });
  }

  @override
  Future<ResultadoAutenticacaoUsuario> redefinirSenha(
    RequisicaoRedefinirSenha requisicao, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    if (requisicao.token.trim().isEmpty || requisicao.novaSenha.isEmpty) {
      throw AutenticacaoException('Informe token e nova senha.');
    }

    return await db.transaction((Connection ctx) async {
      final redefinicao = await repository.findRedefinicaoPorHashToken(
        ctx,
        SegurancaUtils.gerarHashToken(requisicao.token.trim()),
      );
      if (redefinicao == null || redefinicao.expiraEm == null) {
        throw AutenticacaoException(
          'Token de redefinicao invalido.',
          statusCode: 401,
        );
      }

      if (redefinicao.expiraEm!.isBefore(DateTime.now())) {
        throw AutenticacaoException(
          'Token de redefinicao expirado.',
          statusCode: 401,
        );
      }

      final usuario = await repository.findUsuarioPorId(ctx, redefinicao.idUsuario!);
      final agora = DateTime.now();
      final usuarioAtualizado = usuario.clone()
        ..hashSenha = SegurancaUtils.gerarHashSenha(requisicao.novaSenha)
        ..atualizadoEm = agora;

      final salvo = await repository.saveUsuario(ctx, usuarioAtualizado);
      final conta = await repository.findContaCidadaoPorUsuario(ctx, salvo.id!);
      await repository.deleteRedefinicaoSenha(ctx, salvo.id!);

      return _criarResultadoAutenticacao(
        ctx,
        salvo,
        conta,
        enderecoIp: enderecoIp,
        userAgent: userAgent,
      );
    });
  }

  Future<ResultadoAutenticacaoUsuario> _criarResultadoAutenticacao(
    Connection ctx,
    Usuario usuario,
    ContaCidadao? conta, {
    String? enderecoIp,
    String? userAgent,
  }) async {
    final agora = DateTime.now();
    final refreshToken = SegurancaUtils.gerarTokenSeguro(tamanho: 48);
    final tokenAcesso = SegurancaUtils.gerarTokenSeguro(tamanho: 32);

    await repository.createSessao(
      ctx,
      SessaoAutenticacao(
        idUsuario: usuario.id,
        hashRefreshToken: SegurancaUtils.gerarHashToken(refreshToken),
        enderecoIp: enderecoIp,
        userAgent: userAgent,
        expiraEm: agora.add(const Duration(days: 30)),
        criadoEm: agora,
      ),
    );
    await repository.updateUltimoLogin(ctx, usuario.id!, agora);

    return ResultadoAutenticacaoUsuario(
      usuario: (await repository.findUsuarioPorId(ctx, usuario.id!)),
      contaCidadao: conta,
      tokenAcesso: tokenAcesso,
      refreshToken: refreshToken,
      tipoToken: 'bearer',
      expiraEm: agora.add(const Duration(hours: 2)),
    );
  }

  void _validarCadastro(RequisicaoCadastroUsuario requisicao) {
    if (requisicao.nomeUsuario.trim().isEmpty) {
      throw AutenticacaoException('Informe o nome de usuario.');
    }
    if (requisicao.email.trim().isEmpty) {
      throw AutenticacaoException('Informe o email.');
    }
    if (requisicao.nomeExibicao.trim().isEmpty) {
      throw AutenticacaoException('Informe o nome para exibicao.');
    }
    if (requisicao.senha.length < 8) {
      throw AutenticacaoException('A senha deve ter ao menos 8 caracteres.');
    }
  }

  String? _normalizarDocumento(String? valor) {
    if (valor == null) {
      return null;
    }
    final normalizado = valor.replaceAll(RegExp(r'[^0-9]'), '');
    return normalizado.isEmpty ? null : normalizado;
  }
}