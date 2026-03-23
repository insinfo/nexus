class EtiquetaServico {
  static const tableName = 'etiquetas_servico';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const codigoCol = 'codigo';
  static const nomeCol = 'nome';
  static const criadoEmCol = 'criado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  int id;
  String codigo;
  String nome;
  DateTime? criadoEm;
  EtiquetaServico({
    required this.id,
    required this.codigo,
    required this.nome,
    this.criadoEm,
  });

  factory EtiquetaServico.fromMap(Map<String, dynamic> map) {
    return EtiquetaServico(
      id: map[idCol] as int? ?? 0,
      codigo: map[codigoCol] as String? ?? '',
      nome: map[nomeCol] as String? ?? '',
      criadoEm: map[criadoEmCol] != null
          ? DateTime.tryParse(map[criadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      codigoCol: codigo,
      nomeCol: nome,
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
      ..remove(criadoEmCol);
    return map;
  }

  EtiquetaServico clone() {
    return EtiquetaServico(
      id: id,
      codigo: codigo,
      nome: nome,
      criadoEm: criadoEm,
    );
  }
}
