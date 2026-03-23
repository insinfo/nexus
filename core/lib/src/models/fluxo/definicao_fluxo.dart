class DefinicaoFluxo {
  static const tableName = 'definicoes_fluxo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const chaveFluxoCol = 'chave_fluxo';
  static const tipoFluxoCol = 'tipo_fluxo';
  static const tituloCol = 'titulo';
  static const pontoEntradaCol = 'ponto_entrada';
  static const metadadosJsonCol = 'metadados_json';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const chaveFluxoFqCol = '$fqtb.$chaveFluxoCol';
  static const tipoFluxoFqCol = '$fqtb.$tipoFluxoCol';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const pontoEntradaFqCol = '$fqtb.$pontoEntradaCol';
  static const metadadosJsonFqCol = '$fqtb.$metadadosJsonCol';
  int id;
  String? idPublico;
  int idVersaoServico;
  String chaveFluxo;
  String tipoFluxo;
  String? titulo;
  bool pontoEntrada;
  String metadadosJson;
  DefinicaoFluxo({
    required this.id,
    this.idPublico,
    required this.idVersaoServico,
    required this.chaveFluxo,
    required this.tipoFluxo,
    this.titulo,
    this.pontoEntrada = false,
    this.metadadosJson = '{}',
  });

  factory DefinicaoFluxo.fromMap(Map<String, dynamic> map) {
    return DefinicaoFluxo(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idVersaoServico: map[idVersaoServicoCol] as int? ?? 0,
      chaveFluxo: map[chaveFluxoCol] as String? ?? '',
      tipoFluxo: map[tipoFluxoCol] as String? ?? '',
      titulo: map[tituloCol] as String?,
      pontoEntrada: map[pontoEntradaCol] as bool? ?? false,
      metadadosJson: map[metadadosJsonCol]?.toString() ?? '{}',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idPublicoCol: idPublico,
      idVersaoServicoCol: idVersaoServico,
      chaveFluxoCol: chaveFluxo,
      tipoFluxoCol: tipoFluxo,
      tituloCol: titulo,
      pontoEntradaCol: pontoEntrada,
      metadadosJsonCol: metadadosJson,
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
      ..remove(idVersaoServicoCol);
    return map;
  }

  DefinicaoFluxo clone() {
    return DefinicaoFluxo(
      id: id,
      idPublico: idPublico,
      idVersaoServico: idVersaoServico,
      chaveFluxo: chaveFluxo,
      tipoFluxo: tipoFluxo,
      titulo: titulo,
      pontoEntrada: pontoEntrada,
      metadadosJson: metadadosJson,
    );
  }
}
