class RegraVisibilidadeCampo {
  static const tableName = 'regras_visibilidade_campo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idCampoCol = 'id_campo';
  static const expressaoJsonCol = 'expressao_json';
  static const idFqCol = '$fqtb.$idCol';
  static const idCampoFqCol = '$fqtb.$idCampoCol';
  static const expressaoJsonFqCol = '$fqtb.$expressaoJsonCol';
  int id;
  int idCampo;
  String expressaoJson;
  RegraVisibilidadeCampo({
    required this.id,
    required this.idCampo,
    required this.expressaoJson,
  });

  factory RegraVisibilidadeCampo.fromMap(Map<String, dynamic> map) {
    return RegraVisibilidadeCampo(
      id: map[idCol] as int? ?? 0,
      idCampo: map[idCampoCol] as int? ?? 0,
      expressaoJson: map[expressaoJsonCol]?.toString() ?? '{}',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idCampoCol: idCampo,
      expressaoJsonCol: expressaoJson,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idCampoCol);
    return map;
  }

  RegraVisibilidadeCampo clone() {
    return RegraVisibilidadeCampo(
      id: id,
      idCampo: idCampo,
      expressaoJson: expressaoJson,
    );
  }
}
