import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';

class ProvedorOidcRepository {
  ProvedorOidcRepository(this.db);

  final Connection db;

  Future<ClienteOidc?> findCliente(Connection ctx, String idCliente) async {
    final row = await ctx
        .table(ClienteOidc.fqtb)
        .where(ClienteOidc.idClienteCol, Operator.equal, idCliente)
        .first();
    if (row == null) {
      return null;
    }
    return ClienteOidc.fromMap(Map<String, dynamic>.from(row));
  }

  Future<CodigoAutorizacaoOidc> createCodigoAutorizacao(
    Connection ctx,
    CodigoAutorizacaoOidc codigo,
  ) async {
    final id = await ctx.table(CodigoAutorizacaoOidc.fqtb).insertGetId(
          codigo.toInsertMap(),
          CodigoAutorizacaoOidc.idCol,
        ) as int;
    final row = await ctx
        .table(CodigoAutorizacaoOidc.fqtb)
        .where(CodigoAutorizacaoOidc.idCol, Operator.equal, id)
        .first();
    return CodigoAutorizacaoOidc.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<CodigoAutorizacaoOidc?> findCodigoAutorizacaoPorHash(
    Connection ctx,
    String hashCodigo,
  ) async {
    final row = await ctx
        .table(CodigoAutorizacaoOidc.fqtb)
        .where(CodigoAutorizacaoOidc.hashCodigoCol, Operator.equal, hashCodigo)
        .first();
    if (row == null) {
      return null;
    }
    return CodigoAutorizacaoOidc.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> deleteCodigoAutorizacao(Connection ctx, int idCodigo) async {
    await ctx
        .table(CodigoAutorizacaoOidc.fqtb)
        .where(CodigoAutorizacaoOidc.idCol, Operator.equal, idCodigo)
        .delete();
  }

  Future<ConsentimentoOidc?> findConsentimentoAtivo(
    Connection ctx,
    String idCliente,
    int idUsuario,
  ) async {
    final row = await ctx
        .table(ConsentimentoOidc.fqtb)
        .where(ConsentimentoOidc.idClienteCol, Operator.equal, idCliente)
        .where(ConsentimentoOidc.idUsuarioCol, Operator.equal, idUsuario)
        .whereNull(ConsentimentoOidc.revogadoEmCol)
        .first();
    if (row == null) {
      return null;
    }
    return ConsentimentoOidc.fromMap(Map<String, dynamic>.from(row));
  }

  Future<ConsentimentoOidc> saveConsentimento(
    Connection ctx,
    ConsentimentoOidc consentimento,
  ) async {
    final id = consentimento.id;
    if (id == null || id <= 0) {
      final novoId = await ctx.table(ConsentimentoOidc.fqtb).insertGetId(
            consentimento.toInsertMap(),
            ConsentimentoOidc.idCol,
          ) as int;
      final row = await ctx
          .table(ConsentimentoOidc.fqtb)
          .where(ConsentimentoOidc.idCol, Operator.equal, novoId)
          .first();
      return ConsentimentoOidc.fromMap(Map<String, dynamic>.from(row!));
    }

    await ctx
        .table(ConsentimentoOidc.fqtb)
        .where(ConsentimentoOidc.idCol, Operator.equal, id)
        .update(consentimento.toUpdateMap());
    final row = await ctx
        .table(ConsentimentoOidc.fqtb)
        .where(ConsentimentoOidc.idCol, Operator.equal, id)
        .first();
    return ConsentimentoOidc.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<TokenRefreshOidc> createTokenRefresh(
    Connection ctx,
    TokenRefreshOidc token,
  ) async {
    final id = await ctx.table(TokenRefreshOidc.fqtb).insertGetId(
          token.toInsertMap(),
          TokenRefreshOidc.idCol,
        ) as int;
    final row = await ctx
        .table(TokenRefreshOidc.fqtb)
        .where(TokenRefreshOidc.idCol, Operator.equal, id)
        .first();
    return TokenRefreshOidc.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<TokenRefreshOidc?> findTokenRefreshPorHash(
    Connection ctx,
    String hashToken,
  ) async {
    final row = await ctx
        .table(TokenRefreshOidc.fqtb)
        .where(TokenRefreshOidc.hashTokenCol, Operator.equal, hashToken)
        .first();
    if (row == null) {
      return null;
    }
    return TokenRefreshOidc.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> revogarTokenRefresh(Connection ctx, int idToken) async {
    await ctx
        .table(TokenRefreshOidc.fqtb)
        .where(TokenRefreshOidc.idCol, Operator.equal, idToken)
        .update(<String, dynamic>{TokenRefreshOidc.revogadoCol: true});
  }

  Future<TokenAcessoOidc> createTokenAcesso(
    Connection ctx,
    TokenAcessoOidc token,
  ) async {
    final id = await ctx.table(TokenAcessoOidc.fqtb).insertGetId(
          token.toInsertMap(),
          TokenAcessoOidc.idCol,
        ) as int;
    final row = await ctx
        .table(TokenAcessoOidc.fqtb)
        .where(TokenAcessoOidc.idCol, Operator.equal, id)
        .first();
    return TokenAcessoOidc.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<TokenAcessoOidc?> findTokenAcessoPorHash(
    Connection ctx,
    String hashToken,
  ) async {
    final row = await ctx
        .table(TokenAcessoOidc.fqtb)
        .where(TokenAcessoOidc.hashTokenCol, Operator.equal, hashToken)
        .first();
    if (row == null) {
      return null;
    }
    return TokenAcessoOidc.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> revogarTokenAcesso(Connection ctx, int idToken) async {
    await ctx
        .table(TokenAcessoOidc.fqtb)
        .where(TokenAcessoOidc.idCol, Operator.equal, idToken)
        .update(<String, dynamic>{TokenAcessoOidc.revogadoCol: true});
  }

  Future<TokenIdOidc> createTokenId(
    Connection ctx,
    TokenIdOidc token,
  ) async {
    final id = await ctx.table(TokenIdOidc.fqtb).insertGetId(
          token.toInsertMap(),
          TokenIdOidc.idCol,
        ) as int;
    final row = await ctx
        .table(TokenIdOidc.fqtb)
        .where(TokenIdOidc.idCol, Operator.equal, id)
        .first();
    return TokenIdOidc.fromMap(Map<String, dynamic>.from(row!));
  }

  Future<IdentidadeExternaUsuario?> findIdentidadeExternaAtiva(
    Connection ctx,
    String nomeProvedor,
    String idUsuarioExterno,
  ) async {
    final row = await ctx
        .table(IdentidadeExternaUsuario.fqtb)
        .where(
          IdentidadeExternaUsuario.nomeProvedorCol,
          Operator.equal,
          nomeProvedor,
        )
        .where(
          IdentidadeExternaUsuario.idUsuarioExternoCol,
          Operator.equal,
          idUsuarioExterno,
        )
        .where(IdentidadeExternaUsuario.ativoCol, Operator.equal, true)
        .first();
    if (row == null) {
      return null;
    }
    return IdentidadeExternaUsuario.fromMap(Map<String, dynamic>.from(row));
  }
}
