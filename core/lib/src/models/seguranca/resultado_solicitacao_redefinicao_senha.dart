import 'package:essential_core/essential_core.dart';

class ResultadoSolicitacaoRedefinicaoSenha implements SerializeBase {
  static const tableName = 'resultado_solicitacao_redefinicao_senha';
  static const fqtb = 'public.$tableName';
  static const mensagemCol = 'mensagem';
  static const tokenCol = 'token';
  static const expiraEmCol = 'expira_em';

  ResultadoSolicitacaoRedefinicaoSenha({
    this.mensagem = '',
    this.token,
    this.expiraEm,
  });

  String mensagem;
  String? token;
  DateTime? expiraEm;

  ResultadoSolicitacaoRedefinicaoSenha clone() {
    return ResultadoSolicitacaoRedefinicaoSenha(
      mensagem: mensagem,
      token: token,
      expiraEm: expiraEm,
    );
  }

  factory ResultadoSolicitacaoRedefinicaoSenha.fromMap(
    Map<String, dynamic> mapa,
  ) {
    return ResultadoSolicitacaoRedefinicaoSenha(
      mensagem: mapa[mensagemCol]?.toString() ?? '',
      token: mapa[tokenCol]?.toString(),
      expiraEm: mapa[expiraEmCol] == null
          ? null
          : DateTime.tryParse(mapa[expiraEmCol].toString()),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      mensagemCol: mensagem,
      tokenCol: token,
      expiraEmCol: expiraEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }
}