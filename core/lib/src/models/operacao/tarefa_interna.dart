class TarefaInterna {
  static const tableName = 'tarefas_internas';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idSubmissaoCol = 'id_submissao';
  static const idNoFluxoCol = 'id_no_fluxo';
  static const tituloCol = 'titulo';
  static const descricaoCol = 'descricao';
  static const idOrganogramaCol = 'id_organograma';
  static const statusCol = 'status';
  static const prioridadeCol = 'prioridade';
  static const prazoEmCol = 'prazo_em';
  static const criadoPorCol = 'criado_por';
  static const criadoEmCol = 'criado_em';
  static const atualizadoEmCol = 'atualizado_em';
  static const concluidoEmCol = 'concluido_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';
  static const idNoFluxoFqCol = '$fqtb.$idNoFluxoCol';
  static const statusFqCol = '$fqtb.$statusCol';

  TarefaInterna({
    required this.id,
    this.idPublico,
    required this.idSubmissao,
    this.idNoFluxo,
    required this.titulo,
    this.descricao,
    this.idOrganograma,
    this.status = 'aberta',
    this.prioridade = 'normal',
    this.prazoEm,
    this.criadoPor,
    this.criadoEm,
    this.atualizadoEm,
    this.concluidoEm,
  });

  int id;
  String? idPublico;
  int idSubmissao;
  int? idNoFluxo;
  String titulo;
  String? descricao;
  int? idOrganograma;
  String status;
  String prioridade;
  DateTime? prazoEm;
  int? criadoPor;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  DateTime? concluidoEm;

  TarefaInterna clone() {
    return TarefaInterna(
      id: id,
      idPublico: idPublico,
      idSubmissao: idSubmissao,
      idNoFluxo: idNoFluxo,
      titulo: titulo,
      descricao: descricao,
      idOrganograma: idOrganograma,
      status: status,
      prioridade: prioridade,
      prazoEm: prazoEm,
      criadoPor: criadoPor,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
      concluidoEm: concluidoEm,
    );
  }

  factory TarefaInterna.fromMap(Map<String, dynamic> map) {
    return TarefaInterna(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idSubmissao: map[idSubmissaoCol] as int? ?? 0,
      idNoFluxo: map[idNoFluxoCol] as int?,
      titulo: map[tituloCol] as String? ?? '',
      descricao: map[descricaoCol] as String?,
      idOrganograma: map[idOrganogramaCol] as int?,
      status: map[statusCol] as String? ?? 'aberta',
      prioridade: map[prioridadeCol] as String? ?? 'normal',
      prazoEm: map[prazoEmCol] is DateTime
          ? map[prazoEmCol] as DateTime
          : DateTime.tryParse(map[prazoEmCol]?.toString() ?? ''),
      criadoPor: map[criadoPorCol] as int?,
      criadoEm: map[criadoEmCol] is DateTime
          ? map[criadoEmCol] as DateTime
          : DateTime.tryParse(map[criadoEmCol]?.toString() ?? ''),
      atualizadoEm: map[atualizadoEmCol] is DateTime
          ? map[atualizadoEmCol] as DateTime
          : DateTime.tryParse(map[atualizadoEmCol]?.toString() ?? ''),
      concluidoEm: map[concluidoEmCol] is DateTime
          ? map[concluidoEmCol] as DateTime
          : DateTime.tryParse(map[concluidoEmCol]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idPublicoCol: idPublico,
      idSubmissaoCol: idSubmissao,
      idNoFluxoCol: idNoFluxo,
      tituloCol: titulo,
      descricaoCol: descricao,
      idOrganogramaCol: idOrganograma,
      statusCol: status,
      prioridadeCol: prioridade,
      prazoEmCol: prazoEm?.toIso8601String(),
      criadoPorCol: criadoPor,
      criadoEmCol: criadoEm?.toIso8601String(),
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
      concluidoEmCol: concluidoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idPublicoCol);
    map.remove(criadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idPublicoCol);
    map.remove(idSubmissaoCol);
    return map;
  }
}
