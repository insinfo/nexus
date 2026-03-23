class ConjuntoRegras {
  static const tableName = 'conjuntos_regras';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;

  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idServicoCol = 'id_servico';
  static const codigoCol = 'codigo';
  static const nomeCol = 'nome';
  static const descricaoCol = 'descricao';
  static const ativoCol = 'ativo';
  static const criadoPorCol = 'criado_por';
  static const criadoEmCol = 'criado_em';
  static const atualizadoEmCol = 'atualizado_em';

  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoPorFqCol = '$fqtb.$criadoPorCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';
  ConjuntoRegras({
    required this.id,
    this.idPublico,
    required this.idServico,
    required this.codigo,
    required this.nome,
    this.descricao,
    this.ativo = true,
    this.criadoPor,
    this.criadoEm,
    this.atualizadoEm,
  });
  int id;
  String? idPublico;
  int idServico;
  String codigo;
  String nome;
  String? descricao;
  bool ativo;
  int? criadoPor;
  DateTime? criadoEm;
  DateTime? atualizadoEm;

  factory ConjuntoRegras.fromMap(Map<String, dynamic> map) {
    return ConjuntoRegras(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idServico: map[idServicoCol] as int? ?? 0,
      codigo: map[codigoCol]?.toString() ?? '',
      nome: map[nomeCol]?.toString() ?? '',
      descricao: map[descricaoCol] as String?,
      ativo: map[ativoCol] as bool? ?? true,
      criadoPor: map[criadoPorCol] as int?,
      criadoEm: map[criadoEmCol] != null
          ? DateTime.tryParse(map[criadoEmCol].toString())
          : null,
      atualizadoEm: map[atualizadoEmCol] != null
          ? DateTime.tryParse(map[atualizadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idPublicoCol: idPublico,
      idServicoCol: idServico,
      codigoCol: codigo,
      nomeCol: nome,
      descricaoCol: descricao,
      ativoCol: ativo,
      criadoPorCol: criadoPor,
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

  ConjuntoRegras clone() {
    return ConjuntoRegras(
      id: id,
      idPublico: idPublico,
      idServico: idServico,
      codigo: codigo,
      nome: nome,
      descricao: descricao,
      ativo: ativo,
      criadoPor: criadoPor,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }
}
