class Servico {
  static const tableName = 'servicos';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const codigoCol = 'codigo';
  static const nomeCol = 'nome';
  static const slugCol = 'slug';
  static const descricaoCol = 'descricao';
  static const idCategoriaCol = 'id_categoria';
  static const modoAcessoCol = 'modo_acesso';
  static const responsavelServicoCol = 'responsavel_servico';
  static const exibirResponsavelServicoCol = 'exibir_responsavel_servico';
  static const ativoCol = 'ativo';
  static const criadoEmCol = 'criado_em';
  static const atualizadoEmCol = 'atualizado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const slugFqCol = '$fqtb.$slugCol';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const idCategoriaFqCol = '$fqtb.$idCategoriaCol';
  static const modoAcessoFqCol = '$fqtb.$modoAcessoCol';
  static const responsavelServicoFqCol = '$fqtb.$responsavelServicoCol';
  static const exibirResponsavelServicoFqCol =
      '$fqtb.$exibirResponsavelServicoCol';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';
  int id;
  String? idPublico;
  String codigo;
  String nome;
  String slug;
  String descricao;
  int? idCategoria;
  String modoAcesso;
  String? responsavelServico;
  bool exibirResponsavelServico;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  Servico({
    required this.id,
    this.idPublico,
    required this.codigo,
    required this.nome,
    required this.slug,
    required this.descricao,
    this.idCategoria,
    required this.modoAcesso,
    this.responsavelServico,
    this.exibirResponsavelServico = false,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      codigo: map[codigoCol] as String? ?? '',
      nome: map[nomeCol] as String? ?? '',
      slug: map[slugCol] as String? ?? '',
      descricao: map[descricaoCol] as String? ?? '',
      idCategoria: map[idCategoriaCol] as int?,
      modoAcesso: map[modoAcessoCol] as String? ?? '',
      responsavelServico: map[responsavelServicoCol] as String?,
      exibirResponsavelServico:
          map[exibirResponsavelServicoCol] as bool? ?? false,
      ativo: map[ativoCol] as bool? ?? true,
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
      codigoCol: codigo,
      nomeCol: nome,
      slugCol: slug,
      descricaoCol: descricao,
      idCategoriaCol: idCategoria,
      modoAcessoCol: modoAcesso,
      responsavelServicoCol: responsavelServico,
      exibirResponsavelServicoCol: exibirResponsavelServico,
      ativoCol: ativo,
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
      ..remove(criadoEmCol);
    return map;
  }

  Servico clone() {
    return Servico(
      id: id,
      idPublico: idPublico,
      codigo: codigo,
      nome: nome,
      slug: slug,
      descricao: descricao,
      idCategoria: idCategoria,
      modoAcesso: modoAcesso,
      responsavelServico: responsavelServico,
      exibirResponsavelServico: exibirResponsavelServico,
      ativo: ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }
}
