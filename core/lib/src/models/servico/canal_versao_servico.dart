class CanalVersaoServico {
  static const tableName = 'canais_servico';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const canalCol = 'canal';
  static const visivelCol = 'visivel';
  static const configuracaoJsonCol = 'configuracao_json';
  static const criadoEmCol = 'criado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const canalFqCol = '$fqtb.$canalCol';
  static const visivelFqCol = '$fqtb.$visivelCol';
  static const configuracaoJsonFqCol = '$fqtb.$configuracaoJsonCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  int id;
  int idVersaoServico;
  String canal;
  bool visivel;
  String? configuracaoJson;
  DateTime? criadoEm;
  CanalVersaoServico({
    required this.id,
    required this.idVersaoServico,
    required this.canal,
    this.visivel = true,
    this.configuracaoJson,
    this.criadoEm,
  });

  factory CanalVersaoServico.fromMap(Map<String, dynamic> map) {
    return CanalVersaoServico(
      id: map[idCol] as int? ?? 0,
      idVersaoServico: map[idVersaoServicoCol] as int? ?? 0,
      canal: map[canalCol] as String? ?? '',
      visivel: map[visivelCol] as bool? ?? true,
      configuracaoJson: map[configuracaoJsonCol]?.toString(),
      criadoEm: map[criadoEmCol] != null
          ? DateTime.tryParse(map[criadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idVersaoServicoCol: idVersaoServico,
      canalCol: canal,
      visivelCol: visivel,
      configuracaoJsonCol: configuracaoJson,
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
      ..remove(idVersaoServicoCol)
      ..remove(criadoEmCol);
    return map;
  }

  CanalVersaoServico clone() {
    return CanalVersaoServico(
      id: id,
      idVersaoServico: idVersaoServico,
      canal: canal,
      visivel: visivel,
      configuracaoJson: configuracaoJson,
      criadoEm: criadoEm,
    );
  }
}
