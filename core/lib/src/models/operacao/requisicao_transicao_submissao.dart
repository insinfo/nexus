import 'package:essential_core/essential_core.dart';

class RequisicaoTransicaoSubmissao implements SerializeBase {
  static const tableName = 'requisicao_transicao_submissao';
  static const fqtb = 'public.$tableName';
  static const idSubmissaoCol = 'id_submissao';
  static const novoStatusCol = 'novo_status';
  static const motivoCol = 'motivo';

  RequisicaoTransicaoSubmissao({
    required this.idSubmissao,
    required this.novoStatus,
    this.motivo,
  });

  String idSubmissao;
  String novoStatus;
  String? motivo;

  RequisicaoTransicaoSubmissao clone() {
    return RequisicaoTransicaoSubmissao(
      idSubmissao: idSubmissao,
      novoStatus: novoStatus,
      motivo: motivo,
    );
  }

  Map<String, dynamic> toInsertMap() => toMap();

  Map<String, dynamic> toUpdateMap() => toMap();

  factory RequisicaoTransicaoSubmissao.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoTransicaoSubmissao(
      idSubmissao: mapa[idSubmissaoCol] as String? ?? '',
      novoStatus: mapa[novoStatusCol] as String? ?? '',
      motivo: mapa[motivoCol] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idSubmissaoCol: idSubmissao,
      novoStatusCol: novoStatus,
      motivoCol: motivo,
    };
  }
}
