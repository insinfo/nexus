class ExecucaoClassificacao {
  static const tableName = 'execucoes_classificacao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const statusCol = 'status';
  static const snapshotDatasetJsonCol = 'snapshot_dataset_json';
  static const iniciadoEmCol = 'iniciado_em';
  static const finalizadoEmCol = 'finalizado_em';
  static const notasCol = 'notas';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const idVersaoConjuntoRegrasFqCol = '$fqtb.$idVersaoConjuntoRegrasCol';
  static const statusFqCol = '$fqtb.$statusCol';

  ExecucaoClassificacao({
    required this.id,
    this.idPublico,
    required this.idVersaoServico,
    required this.idVersaoConjuntoRegras,
    required this.status,
    this.snapshotDatasetJson = '{}',
    this.iniciadoEm,
    this.finalizadoEm,
    this.notas,
  });

  int id;
  String? idPublico;
  int idVersaoServico;
  int idVersaoConjuntoRegras;
  String status;
  String snapshotDatasetJson;
  DateTime? iniciadoEm;
  DateTime? finalizadoEm;
  String? notas;

  ExecucaoClassificacao clone() {
    return ExecucaoClassificacao(
      id: id,
      idPublico: idPublico,
      idVersaoServico: idVersaoServico,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      status: status,
      snapshotDatasetJson: snapshotDatasetJson,
      iniciadoEm: iniciadoEm,
      finalizadoEm: finalizadoEm,
      notas: notas,
    );
  }

  factory ExecucaoClassificacao.fromMap(Map<String, dynamic> map) {
    return ExecucaoClassificacao(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idVersaoServico: map[idVersaoServicoCol] as int? ?? 0,
      idVersaoConjuntoRegras: map[idVersaoConjuntoRegrasCol] as int? ?? 0,
      status: map[statusCol] as String? ?? 'pendente',
      snapshotDatasetJson: map[snapshotDatasetJsonCol]?.toString() ?? '{}',
      iniciadoEm: map[iniciadoEmCol] is DateTime
          ? map[iniciadoEmCol] as DateTime
          : DateTime.tryParse(map[iniciadoEmCol]?.toString() ?? ''),
      finalizadoEm: map[finalizadoEmCol] is DateTime
          ? map[finalizadoEmCol] as DateTime
          : DateTime.tryParse(map[finalizadoEmCol]?.toString() ?? ''),
      notas: map[notasCol] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idPublicoCol: idPublico,
      idVersaoServicoCol: idVersaoServico,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      statusCol: status,
      snapshotDatasetJsonCol: snapshotDatasetJson,
      iniciadoEmCol: iniciadoEm?.toIso8601String(),
      finalizadoEmCol: finalizadoEm?.toIso8601String(),
      notasCol: notas,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idPublicoCol);
    map.remove(iniciadoEmCol);
    map.remove(finalizadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idPublicoCol);
    map.remove(idVersaoServicoCol);
    map.remove(idVersaoConjuntoRegrasCol);
    return map;
  }
}
