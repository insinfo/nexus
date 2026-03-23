class VersaoServico {
  static const tableName = 'versoes_servico';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idServicoCol = 'id_servico';
  static const numeroVersaoCol = 'numero_versao';
  static const statusCol = 'status';
  static const notasCol = 'notas';
  static const snapshotMetadadosJsonCol = 'snapshot_metadados_json';
  static const publicadoEmCol = 'publicado_em';
  static const criadoEmCol = 'criado_em';
  static const atualizadoEmCol = 'atualizado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const numeroVersaoFqCol = '$fqtb.$numeroVersaoCol';
  static const statusFqCol = '$fqtb.$statusCol';
  static const notasFqCol = '$fqtb.$notasCol';
  static const snapshotMetadadosJsonFqCol = '$fqtb.$snapshotMetadadosJsonCol';
  static const publicadoEmFqCol = '$fqtb.$publicadoEmCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';
  int id;
  String? idPublico;
  int idServico;
  int numeroVersao;
  String status;
  String? notas;
  String snapshotMetadadosJson;
  DateTime? publicadoEm;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  VersaoServico({
    required this.id,
    this.idPublico,
    required this.idServico,
    required this.numeroVersao,
    required this.status,
    this.notas,
    this.snapshotMetadadosJson = '{}',
    this.publicadoEm,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory VersaoServico.fromMap(Map<String, dynamic> map) {
    return VersaoServico(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idServico: map[idServicoCol] as int? ?? 0,
      numeroVersao: map[numeroVersaoCol] as int? ?? 0,
      status: map[statusCol] as String? ?? '',
      notas: map[notasCol] as String?,
      snapshotMetadadosJson: map[snapshotMetadadosJsonCol]?.toString() ?? '{}',
      publicadoEm: map[publicadoEmCol] != null
          ? DateTime.tryParse(map[publicadoEmCol].toString())
          : null,
      criadoEm: map[criadoEmCol] != null
          ? DateTime.tryParse(map[criadoEmCol].toString())
          : null,
      atualizadoEm: map[atualizadoEmCol] != null
          ? DateTime.tryParse(map[atualizadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idPublicoCol: idPublico,
      idServicoCol: idServico,
      numeroVersaoCol: numeroVersao,
      statusCol: status,
      notasCol: notas,
      snapshotMetadadosJsonCol: snapshotMetadadosJson,
      publicadoEmCol: publicadoEm?.toIso8601String(),
      criadoEmCol: criadoEm?.toIso8601String(),
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idPublicoCol)
      ..remove(criadoEmCol)
      ..remove(atualizadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idPublicoCol)
      ..remove(idServicoCol)
      ..remove(criadoEmCol);
    return map;
  }

  VersaoServico clone() {
    return VersaoServico(
      id: id,
      idPublico: idPublico,
      idServico: idServico,
      numeroVersao: numeroVersao,
      status: status,
      notas: notas,
      snapshotMetadadosJson: snapshotMetadadosJson,
      publicadoEm: publicadoEm,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }
}
