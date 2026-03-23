class ArestaFluxo {
  static const tableName = 'arestas_fluxo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idDefinicaoFluxoCol = 'id_definicao_fluxo';
  static const chaveArestaCol = 'chave_aresta';
  static const idNoOrigemCol = 'id_no_origem';
  static const idNoDestinoCol = 'id_no_destino';
  static const handleOrigemCol = 'handle_origem';
  static const handleDestinoCol = 'handle_destino';
  static const rotuloCol = 'rotulo';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idDefinicaoFluxoFqCol = '$fqtb.$idDefinicaoFluxoCol';
  static const chaveArestaFqCol = '$fqtb.$chaveArestaCol';
  static const idNoOrigemFqCol = '$fqtb.$idNoOrigemCol';
  static const idNoDestinoFqCol = '$fqtb.$idNoDestinoCol';
  static const handleOrigemFqCol = '$fqtb.$handleOrigemCol';
  static const handleDestinoFqCol = '$fqtb.$handleDestinoCol';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  int id;
  String? idPublico;
  int idDefinicaoFluxo;
  String chaveAresta;
  int idNoOrigem;
  int idNoDestino;
  String? handleOrigem;
  String? handleDestino;
  String? rotulo;
  ArestaFluxo({
    required this.id,
    this.idPublico,
    required this.idDefinicaoFluxo,
    required this.chaveAresta,
    required this.idNoOrigem,
    required this.idNoDestino,
    this.handleOrigem,
    this.handleDestino,
    this.rotulo,
  });

  factory ArestaFluxo.fromMap(Map<String, dynamic> map) {
    return ArestaFluxo(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idDefinicaoFluxo: map[idDefinicaoFluxoCol] as int? ?? 0,
      chaveAresta: map[chaveArestaCol] as String? ?? '',
      idNoOrigem: map[idNoOrigemCol] as int? ?? 0,
      idNoDestino: map[idNoDestinoCol] as int? ?? 0,
      handleOrigem: map[handleOrigemCol] as String?,
      handleDestino: map[handleDestinoCol] as String?,
      rotulo: map[rotuloCol] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idPublicoCol: idPublico,
      idDefinicaoFluxoCol: idDefinicaoFluxo,
      chaveArestaCol: chaveAresta,
      idNoOrigemCol: idNoOrigem,
      idNoDestinoCol: idNoDestino,
      handleOrigemCol: handleOrigem,
      handleDestinoCol: handleDestino,
      rotuloCol: rotulo,
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

  ArestaFluxo clone() {
    return ArestaFluxo(
      id: id,
      idPublico: idPublico,
      idDefinicaoFluxo: idDefinicaoFluxo,
      chaveAresta: chaveAresta,
      idNoOrigem: idNoOrigem,
      idNoDestino: idNoDestino,
      handleOrigem: handleOrigem,
      handleDestino: handleDestino,
      rotulo: rotulo,
    );
  }
}
