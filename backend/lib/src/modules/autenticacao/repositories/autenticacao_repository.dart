import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';

class AutenticacaoRepository {
  AutenticacaoRepository(this.db);

  final Connection db;

  Future<Usuario?> findUsuarioPorIdentificador(
    Connection ctx,
    String identificador,
  ) async {
    final valor = identificador.trim();
    if (valor.isEmpty) {
      return null;
    }

    Map<String, dynamic>? row;
    if (valor.contains('@')) {
      row = await ctx
          .table(Usuario.fqtb)
          .where(Usuario.emailCol, Operator.equal, valor)
          .first();
    }

    row ??= await ctx
        .table(Usuario.fqtb)
        .where(Usuario.nomeUsuarioCol, Operator.equal, valor)
        .first();

    final documento = _normalizarDocumento(valor);
    if (row == null && documento.length == 11) {
      final conta = await ctx
          .table(ContaCidadao.fqtb)
          .where(ContaCidadao.cpfCol, Operator.equal, documento)
          .first();
      final idUsuario = conta?[ContaCidadao.idUsuarioCol] as int?;
      if (idUsuario != null) {
        row = await ctx
            .table(Usuario.fqtb)
            .where(Usuario.idCol, Operator.equal, idUsuario)
            .first();
      }
    }

    if (row == null) {
      return null;
    }
    return Usuario.fromMap(Map<String, dynamic>.from(row));
  }

  Future<bool> existsUsuarioCadastro(
    Connection ctx,
    RequisicaoCadastroUsuario requisicao,
  ) async {
    final porNome = await ctx
        .table(Usuario.fqtb)
        .where(Usuario.nomeUsuarioCol, Operator.equal, requisicao.nomeUsuario)
        .first();
    if (porNome != null) {
      return true;
    }

    final porEmail = await ctx
        .table(Usuario.fqtb)
        .where(Usuario.emailCol, Operator.equal, requisicao.email)
        .first();
    if (porEmail != null) {
      return true;
    }

    final cpf = _normalizarDocumento(requisicao.cpf);
    if (cpf.isEmpty) {
      return false;
    }

    final porCpf = await ctx
        .table(ContaCidadao.fqtb)
        .where(ContaCidadao.cpfCol, Operator.equal, cpf)
        .first();
    return porCpf != null;
  }

  Future<Usuario> saveUsuario(Connection ctx, Usuario usuario) async {
    final id = usuario.id;
    if (id == null || id <= 0) {
      final novoId = await ctx.table(Usuario.fqtb).insertGetId(
            usuario.toInsertMap(),
            Usuario.idCol,
          ) as int;
      return findUsuarioPorId(ctx, novoId);
    }

    await ctx
        .table(Usuario.fqtb)
        .where(Usuario.idCol, Operator.equal, id)
        .update(usuario.toUpdateMap());
    return findUsuarioPorId(ctx, id);
  }

  Future<Usuario> findUsuarioPorId(Connection ctx, int idUsuario) async {
    final row = await ctx
        .table(Usuario.fqtb)
        .where(Usuario.idCol, Operator.equal, idUsuario)
        .first();
    if (row == null) {
      throw StateError('Usuario nao encontrado: $idUsuario');
    }
    return Usuario.fromMap(Map<String, dynamic>.from(row));
  }

  Future<ContaCidadao?> findContaCidadaoPorUsuario(
    Connection ctx,
    int idUsuario,
  ) async {
    final row = await ctx
        .table(ContaCidadao.fqtb)
        .where(ContaCidadao.idUsuarioCol, Operator.equal, idUsuario)
        .first();
    if (row == null) {
      return null;
    }
    return ContaCidadao.fromMap(Map<String, dynamic>.from(row));
  }

  Future<ContaCidadao> saveContaCidadao(
    Connection ctx,
    ContaCidadao conta,
  ) async {
    final existente = await findContaCidadaoPorUsuario(ctx, conta.idUsuario!);
    if (existente == null) {
      final novoId = await ctx.table(ContaCidadao.fqtb).insertGetId(
            conta.toInsertMap(),
            ContaCidadao.idCol,
          ) as int;
      final row = await ctx
          .table(ContaCidadao.fqtb)
          .where(ContaCidadao.idCol, Operator.equal, novoId)
          .first();
      return ContaCidadao.fromMap(Map<String, dynamic>.from(row!));
    }

    final atualizada = conta.clone()..id = existente.id;
    await ctx
        .table(ContaCidadao.fqtb)
        .where(ContaCidadao.idCol, Operator.equal, existente.id)
        .update(atualizada.toUpdateMap());
    final row = await ctx
        .table(ContaCidadao.fqtb)
        .where(ContaCidadao.idCol, Operator.equal, existente.id)
        .first();
    return ContaCidadao.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<SessaoAutenticacao> createSessao(
    Connection ctx,
    SessaoAutenticacao sessao,
  ) async {
    final novoId = await ctx.table(SessaoAutenticacao.fqtb).insertGetId(
          sessao.toInsertMap(),
          SessaoAutenticacao.idCol,
        ) as int;
    final row = await ctx
        .table(SessaoAutenticacao.fqtb)
        .where(SessaoAutenticacao.idCol, Operator.equal, novoId)
        .first();
    return SessaoAutenticacao.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<void> updateUltimoLogin(
    Connection ctx,
    int idUsuario,
    DateTime dataHora,
  ) async {
    await ctx
        .table(Usuario.fqtb)
        .where(Usuario.idCol, Operator.equal, idUsuario)
        .update(<String, dynamic>{
      Usuario.ultimoLoginEmCol: dataHora.toIso8601String(),
      Usuario.atualizadoEmCol: dataHora.toIso8601String(),
    });
  }

  Future<RedefinicaoSenha?> findRedefinicaoPorHashToken(
    Connection ctx,
    String hashToken,
  ) async {
    final row = await ctx
        .table(RedefinicaoSenha.fqtb)
        .where(RedefinicaoSenha.hashTokenCol, Operator.equal, hashToken)
        .first();
    if (row == null) {
      return null;
    }
    return RedefinicaoSenha.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> replaceRedefinicaoSenha(
    Connection ctx,
    RedefinicaoSenha redefinicao,
  ) async {
    await ctx
        .table(RedefinicaoSenha.fqtb)
        .where(RedefinicaoSenha.idUsuarioCol, Operator.equal, redefinicao.idUsuario)
        .delete();
    await ctx.table(RedefinicaoSenha.fqtb).insert(redefinicao.toInsertMap());
  }

  Future<void> deleteRedefinicaoSenha(Connection ctx, int idUsuario) async {
    await ctx
        .table(RedefinicaoSenha.fqtb)
        .where(RedefinicaoSenha.idUsuarioCol, Operator.equal, idUsuario)
        .delete();
  }

  Future<ControleRedefinicaoSenha?> findControleRedefinicao(
    Connection ctx,
    String identificador,
  ) async {
    final row = await ctx
        .table(ControleRedefinicaoSenha.fqtb)
        .where(
          ControleRedefinicaoSenha.identificadorUsuarioCol,
          Operator.equal,
          identificador,
        )
        .first();
    if (row == null) {
      return null;
    }
    return ControleRedefinicaoSenha.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> saveControleRedefinicao(
    Connection ctx,
    ControleRedefinicaoSenha controle,
  ) async {
    final existente = await findControleRedefinicao(
      ctx,
      controle.identificadorUsuario,
    );
    if (existente == null) {
      await ctx
          .table(ControleRedefinicaoSenha.fqtb)
          .insert(controle.toInsertMap());
      return;
    }

    await ctx
        .table(ControleRedefinicaoSenha.fqtb)
        .where(
          ControleRedefinicaoSenha.identificadorUsuarioCol,
          Operator.equal,
          controle.identificadorUsuario,
        )
        .update(controle.toUpdateMap());
  }

  String _normalizarDocumento(String? valor) {
    if (valor == null) {
      return '';
    }
    return valor.replaceAll(RegExp(r'[^0-9]'), '');
  }
}