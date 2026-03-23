import 'package:essential_core/essential_core.dart';

class RequisicaoSolicitarRedefinicaoSenha implements SerializeBase {
  static const tableName = 'requisicao_solicitar_redefinicao_senha';
  static const fqtb = 'public.$tableName';
  static const identificadorCol = 'identificador';

  RequisicaoSolicitarRedefinicaoSenha({
    this.identificador = '',
  });

  String identificador;

  RequisicaoSolicitarRedefinicaoSenha clone() {
    return RequisicaoSolicitarRedefinicaoSenha(
      identificador: identificador,
    );
  }

  factory RequisicaoSolicitarRedefinicaoSenha.fromMap(
    Map<String, dynamic> mapa,
  ) {
    return RequisicaoSolicitarRedefinicaoSenha(
      identificador: mapa[identificadorCol]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      identificadorCol: identificador,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }
}