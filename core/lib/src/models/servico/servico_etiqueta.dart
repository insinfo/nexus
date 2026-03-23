class ServicoEtiqueta {
  static const tableName = 'servicos_etiquetas';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idServicoCol = 'id_servico';
  static const idEtiquetaCol = 'id_etiqueta';
  static const criadoEmCol = 'criado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idEtiquetaFqCol = '$fqtb.$idEtiquetaCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  int id;
  int idServico;
  int idEtiqueta;
  DateTime? criadoEm;
  ServicoEtiqueta({
    required this.id,
    required this.idServico,
    required this.idEtiqueta,
    this.criadoEm,
  });

  factory ServicoEtiqueta.fromMap(Map<String, dynamic> map) {
    return ServicoEtiqueta(
      id: map[idCol] as int? ?? 0,
      idServico: map[idServicoCol] as int? ?? 0,
      idEtiqueta: map[idEtiquetaCol] as int? ?? 0,
      criadoEm: map[criadoEmCol] != null
          ? DateTime.tryParse(map[criadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idServicoCol: idServico,
      idEtiquetaCol: idEtiqueta,
      criadoEmCol: criadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(criadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idServicoCol)
      ..remove(idEtiquetaCol)
      ..remove(criadoEmCol);
    return map;
  }

  ServicoEtiqueta clone() {
    return ServicoEtiqueta(
      id: id,
      idServico: idServico,
      idEtiqueta: idEtiqueta,
      criadoEm: criadoEm,
    );
  }
}
