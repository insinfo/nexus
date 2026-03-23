class HistoricoStatusSubmissao {
  static const tableName = 'historico_status_submissao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idSubmissaoCol = 'id_submissao';
  static const statusAnteriorCol = 'status_anterior';
  static const novoStatusCol = 'novo_status';
  static const alteradoPorCol = 'alterado_por';
  static const motivoCol = 'motivo';
  static const metadadosJsonCol = 'metadados_json';
  static const criadoEmCol = 'criado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';
  static const novoStatusFqCol = '$fqtb.$novoStatusCol';

  HistoricoStatusSubmissao({
    required this.id,
    required this.idSubmissao,
    this.statusAnterior,
    required this.novoStatus,
    this.alteradoPor,
    this.motivo,
    this.metadadosJson = '{}',
    this.criadoEm,
  });

  int id;
  int idSubmissao;
  String? statusAnterior;
  String novoStatus;
  int? alteradoPor;
  String? motivo;
  String metadadosJson;
  DateTime? criadoEm;

  HistoricoStatusSubmissao clone() {
    return HistoricoStatusSubmissao(
      id: id,
      idSubmissao: idSubmissao,
      statusAnterior: statusAnterior,
      novoStatus: novoStatus,
      alteradoPor: alteradoPor,
      motivo: motivo,
      metadadosJson: metadadosJson,
      criadoEm: criadoEm,
    );
  }

  factory HistoricoStatusSubmissao.fromMap(Map<String, dynamic> map) {
    return HistoricoStatusSubmissao(
      id: map[idCol] as int? ?? 0,
      idSubmissao: map[idSubmissaoCol] as int? ?? 0,
      statusAnterior: map[statusAnteriorCol] as String?,
      novoStatus: map[novoStatusCol] as String? ?? '',
      alteradoPor: map[alteradoPorCol] as int?,
      motivo: map[motivoCol] as String?,
      metadadosJson: map[metadadosJsonCol]?.toString() ?? '{}',
      criadoEm: map[criadoEmCol] is DateTime
          ? map[criadoEmCol] as DateTime
          : DateTime.tryParse(map[criadoEmCol]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idSubmissaoCol: idSubmissao,
      statusAnteriorCol: statusAnterior,
      novoStatusCol: novoStatus,
      alteradoPorCol: alteradoPor,
      motivoCol: motivo,
      metadadosJsonCol: metadadosJson,
      criadoEmCol: criadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(criadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idSubmissaoCol);
    return map;
  }
}
