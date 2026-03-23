class TransicaoTarefa {
  static const tableName = 'transicoes_tarefa';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idTarefaCol = 'id_tarefa';
  static const statusAnteriorCol = 'status_anterior';
  static const novoStatusCol = 'novo_status';
  static const transitadoPorCol = 'transitado_por';
  static const motivoCol = 'motivo';
  static const criadoEmCol = 'criado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idTarefaFqCol = '$fqtb.$idTarefaCol';

  TransicaoTarefa({
    required this.id,
    required this.idTarefa,
    this.statusAnterior,
    required this.novoStatus,
    this.transitadoPor,
    this.motivo,
    this.criadoEm,
  });

  int id;
  int idTarefa;
  String? statusAnterior;
  String novoStatus;
  int? transitadoPor;
  String? motivo;
  DateTime? criadoEm;

  TransicaoTarefa clone() {
    return TransicaoTarefa(
      id: id,
      idTarefa: idTarefa,
      statusAnterior: statusAnterior,
      novoStatus: novoStatus,
      transitadoPor: transitadoPor,
      motivo: motivo,
      criadoEm: criadoEm,
    );
  }

  factory TransicaoTarefa.fromMap(Map<String, dynamic> map) {
    return TransicaoTarefa(
      id: map[idCol] as int? ?? 0,
      idTarefa: map[idTarefaCol] as int? ?? 0,
      statusAnterior: map[statusAnteriorCol] as String?,
      novoStatus: map[novoStatusCol] as String? ?? '',
      transitadoPor: map[transitadoPorCol] as int?,
      motivo: map[motivoCol] as String?,
      criadoEm: map[criadoEmCol] is DateTime
          ? map[criadoEmCol] as DateTime
          : DateTime.tryParse(map[criadoEmCol]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idTarefaCol: idTarefa,
      statusAnteriorCol: statusAnterior,
      novoStatusCol: novoStatus,
      transitadoPorCol: transitadoPor,
      motivoCol: motivo,
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
    map.remove(idTarefaCol);
    return map;
  }
}
