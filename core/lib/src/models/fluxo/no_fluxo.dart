class NoFluxo {
  static const tableName = 'nos_fluxo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idDefinicaoFluxoCol = 'id_definicao_fluxo';
  static const chaveNoCol = 'chave_no';
  static const tipoNoCol = 'tipo_no';
  static const rotuloCol = 'rotulo';
  static const posicaoXCol = 'posicao_x';
  static const posicaoYCol = 'posicao_y';
  static const larguraCol = 'largura';
  static const alturaCol = 'altura';
  static const dadosJsonCol = 'dados_json';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idDefinicaoFluxoFqCol = '$fqtb.$idDefinicaoFluxoCol';
  static const chaveNoFqCol = '$fqtb.$chaveNoCol';
  static const tipoNoFqCol = '$fqtb.$tipoNoCol';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const posicaoXFqCol = '$fqtb.$posicaoXCol';
  static const posicaoYFqCol = '$fqtb.$posicaoYCol';
  static const larguraFqCol = '$fqtb.$larguraCol';
  static const alturaFqCol = '$fqtb.$alturaCol';
  static const dadosJsonFqCol = '$fqtb.$dadosJsonCol';
  int id;
  String? idPublico;
  int idDefinicaoFluxo;
  String chaveNo;
  String tipoNo;
  String? rotulo;
  double posicaoX;
  double posicaoY;
  double? largura;
  double? altura;
  String dadosJson;
  NoFluxo({
    required this.id,
    this.idPublico,
    required this.idDefinicaoFluxo,
    required this.chaveNo,
    required this.tipoNo,
    this.rotulo,
    required this.posicaoX,
    required this.posicaoY,
    this.largura,
    this.altura,
    this.dadosJson = '{}',
  });

  factory NoFluxo.fromMap(Map<String, dynamic> map) {
    return NoFluxo(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idDefinicaoFluxo: map[idDefinicaoFluxoCol] as int? ?? 0,
      chaveNo: map[chaveNoCol] as String? ?? '',
      tipoNo: map[tipoNoCol] as String? ?? '',
      rotulo: map[rotuloCol] as String?,
      posicaoX: (map[posicaoXCol] as num?)?.toDouble() ?? 0,
      posicaoY: (map[posicaoYCol] as num?)?.toDouble() ?? 0,
      largura: (map[larguraCol] as num?)?.toDouble(),
      altura: (map[alturaCol] as num?)?.toDouble(),
      dadosJson: map[dadosJsonCol]?.toString() ?? '{}',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idPublicoCol: idPublico,
      idDefinicaoFluxoCol: idDefinicaoFluxo,
      chaveNoCol: chaveNo,
      tipoNoCol: tipoNo,
      rotuloCol: rotulo,
      posicaoXCol: posicaoX,
      posicaoYCol: posicaoY,
      larguraCol: largura,
      alturaCol: altura,
      dadosJsonCol: dadosJson,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idPublicoCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idPublicoCol)
      ..remove(idDefinicaoFluxoCol);
    return map;
  }

  NoFluxo clone() {
    return NoFluxo(
      id: id,
      idPublico: idPublico,
      idDefinicaoFluxo: idDefinicaoFluxo,
      chaveNo: chaveNo,
      tipoNo: tipoNo,
      rotulo: rotulo,
      posicaoX: posicaoX,
      posicaoY: posicaoY,
      largura: largura,
      altura: altura,
      dadosJson: dadosJson,
    );
  }
}
