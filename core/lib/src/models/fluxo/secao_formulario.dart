class SecaoFormulario {
  static const tableName = 'secoes_formulario';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idNoFluxoCol = 'id_no_fluxo';
  static const chaveSecaoCol = 'chave_secao';
  static const tituloCol = 'titulo';
  static const descricaoCol = 'descricao';
  static const ordemCol = 'ordem';
  static const repetivelCol = 'repetivel';
  static const idFqCol = '$fqtb.$idCol';
  static const idNoFluxoFqCol = '$fqtb.$idNoFluxoCol';
  static const chaveSecaoFqCol = '$fqtb.$chaveSecaoCol';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const ordemFqCol = '$fqtb.$ordemCol';
  static const repetivelFqCol = '$fqtb.$repetivelCol';
  int id;
  int idNoFluxo;
  String chaveSecao;
  String titulo;
  String? descricao;
  int ordem;
  bool repetivel;
  SecaoFormulario({
    required this.id,
    required this.idNoFluxo,
    required this.chaveSecao,
    required this.titulo,
    this.descricao,
    this.ordem = 0,
    this.repetivel = false,
  });

  factory SecaoFormulario.fromMap(Map<String, dynamic> map) {
    return SecaoFormulario(
      id: map[idCol] as int? ?? 0,
      idNoFluxo: map[idNoFluxoCol] as int? ?? 0,
      chaveSecao: map[chaveSecaoCol] as String? ?? '',
      titulo: map[tituloCol] as String? ?? '',
      descricao: map[descricaoCol] as String?,
      ordem: map[ordemCol] as int? ?? 0,
      repetivel: map[repetivelCol] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idNoFluxoCol: idNoFluxo,
      chaveSecaoCol: chaveSecao,
      tituloCol: titulo,
      descricaoCol: descricao,
      ordemCol: ordem,
      repetivelCol: repetivel,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idNoFluxoCol);
    return map;
  }

  SecaoFormulario clone() {
    return SecaoFormulario(
      id: id,
      idNoFluxo: idNoFluxo,
      chaveSecao: chaveSecao,
      titulo: titulo,
      descricao: descricao,
      ordem: ordem,
      repetivel: repetivel,
    );
  }
}
