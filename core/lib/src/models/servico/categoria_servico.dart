class CategoriaServico {
  static const tableName = 'categorias_servico';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const codigoCol = 'codigo';
  static const nomeCol = 'nome';
  static const descricaoCol = 'descricao';
  static const ativoCol = 'ativo';
  static const criadoEmCol = 'criado_em';
  static const atualizadoEmCol = 'atualizado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';
  int id;
  String codigo;
  String nome;
  String? descricao;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  CategoriaServico({
    required this.id,
    required this.codigo,
    required this.nome,
    this.descricao,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory CategoriaServico.fromMap(Map<String, dynamic> map) {
    return CategoriaServico(
      id: map[idCol] as int? ?? 0,
      codigo: map[codigoCol] as String? ?? '',
      nome: map[nomeCol] as String? ?? '',
      descricao: map[descricaoCol] as String?,
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
      codigoCol: codigo,
      nomeCol: nome,
      descricaoCol: descricao,
      ativoCol: ativo,
      criadoEmCol: criadoEm?.toIso8601String(),
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(criadoEmCol)
      ..remove(atualizadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(criadoEmCol);
    return map;
  }

  CategoriaServico clone() {
    return CategoriaServico(
      id: id,
      codigo: codigo,
      nome: nome,
      descricao: descricao,
      ativo: ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }
}
