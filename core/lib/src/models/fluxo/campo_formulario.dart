class CampoFormulario {
  static const tableName = 'campos_formulario';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idNoFluxoCol = 'id_no_fluxo';
  static const idSecaoCol = 'id_secao';
  static const chaveCampoCol = 'chave_campo';
  static const rotuloCol = 'rotulo';
  static const tipoCampoCol = 'tipo_campo';
  static const descricaoCol = 'descricao';
  static const placeholderCol = 'placeholder';
  static const mascaraCol = 'mascara';
  static const valorPadraoJsonCol = 'valor_padrao_json';
  static const origemDadosJsonCol = 'origem_dados_json';
  static const participaRankingCol = 'participa_ranking';
  static const obrigatorioCol = 'obrigatorio';
  static const ordemCol = 'ordem';
  static const idFqCol = '$fqtb.$idCol';
  static const idNoFluxoFqCol = '$fqtb.$idNoFluxoCol';
  static const idSecaoFqCol = '$fqtb.$idSecaoCol';
  static const chaveCampoFqCol = '$fqtb.$chaveCampoCol';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const tipoCampoFqCol = '$fqtb.$tipoCampoCol';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const placeholderFqCol = '$fqtb.$placeholderCol';
  static const mascaraFqCol = '$fqtb.$mascaraCol';
  static const valorPadraoJsonFqCol = '$fqtb.$valorPadraoJsonCol';
  static const origemDadosJsonFqCol = '$fqtb.$origemDadosJsonCol';
  static const participaRankingFqCol = '$fqtb.$participaRankingCol';
  static const obrigatorioFqCol = '$fqtb.$obrigatorioCol';
  static const ordemFqCol = '$fqtb.$ordemCol';
  int id;
  int idNoFluxo;
  int? idSecao;
  String chaveCampo;
  String rotulo;
  String tipoCampo;
  String? descricao;
  String? placeholder;
  String? mascara;
  String? valorPadraoJson;
  String? origemDadosJson;
  bool participaRanking;
  bool obrigatorio;
  int ordem;
  CampoFormulario({
    required this.id,
    required this.idNoFluxo,
    this.idSecao,
    required this.chaveCampo,
    required this.rotulo,
    required this.tipoCampo,
    this.descricao,
    this.placeholder,
    this.mascara,
    this.valorPadraoJson,
    this.origemDadosJson,
    this.participaRanking = false,
    this.obrigatorio = false,
    this.ordem = 0,
  });

  factory CampoFormulario.fromMap(Map<String, dynamic> map) {
    return CampoFormulario(
      id: map[idCol] as int? ?? 0,
      idNoFluxo: map[idNoFluxoCol] as int? ?? 0,
      idSecao: map[idSecaoCol] as int?,
      chaveCampo: map[chaveCampoCol] as String? ?? '',
      rotulo: map[rotuloCol] as String? ?? '',
      tipoCampo: map[tipoCampoCol] as String? ?? '',
      descricao: map[descricaoCol] as String?,
      placeholder: map[placeholderCol] as String?,
      mascara: map[mascaraCol] as String?,
      valorPadraoJson: map[valorPadraoJsonCol]?.toString(),
      origemDadosJson: map[origemDadosJsonCol]?.toString(),
      participaRanking: map[participaRankingCol] as bool? ?? false,
      obrigatorio: map[obrigatorioCol] as bool? ?? false,
      ordem: map[ordemCol] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idNoFluxoCol: idNoFluxo,
      idSecaoCol: idSecao,
      chaveCampoCol: chaveCampo,
      rotuloCol: rotulo,
      tipoCampoCol: tipoCampo,
      descricaoCol: descricao,
      placeholderCol: placeholder,
      mascaraCol: mascara,
      valorPadraoJsonCol: valorPadraoJson,
      origemDadosJsonCol: origemDadosJson,
      participaRankingCol: participaRanking,
      obrigatorioCol: obrigatorio,
      ordemCol: ordem,
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

  CampoFormulario clone() {
    return CampoFormulario(
      id: id,
      idNoFluxo: idNoFluxo,
      idSecao: idSecao,
      chaveCampo: chaveCampo,
      rotulo: rotulo,
      tipoCampo: tipoCampo,
      descricao: descricao,
      placeholder: placeholder,
      mascara: mascara,
      valorPadraoJson: valorPadraoJson,
      origemDadosJson: origemDadosJson,
      participaRanking: participaRanking,
      obrigatorio: obrigatorio,
      ordem: ordem,
    );
  }
}
