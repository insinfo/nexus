class SessaoExecucao {
  static const tableName = 'sessoes_execucao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idServicoCol = 'id_servico';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idFluxoAtualCol = 'id_fluxo_atual';
  static const idNoAtualCol = 'id_no_atual';
  static const canalCol = 'canal';
  static const statusCol = 'status';
  static const contextoJsonCol = 'contexto_json';
  static const snapshotFluxoJsonCol = 'snapshot_fluxo_json';
  static const finalizadaEmCol = 'finalizada_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const idFluxoAtualFqCol = '$fqtb.$idFluxoAtualCol';
  static const idNoAtualFqCol = '$fqtb.$idNoAtualCol';
  static const canalFqCol = '$fqtb.$canalCol';
  static const statusFqCol = '$fqtb.$statusCol';
  static const contextoJsonFqCol = '$fqtb.$contextoJsonCol';
  static const snapshotFluxoJsonFqCol = '$fqtb.$snapshotFluxoJsonCol';
  static const finalizadaEmFqCol = '$fqtb.$finalizadaEmCol';
  int id;
  String? idPublico;
  int idServico;
  int idVersaoServico;
  int? idFluxoAtual;
  int? idNoAtual;
  String canal;
  String status;
  String contextoJson;
  String snapshotFluxoJson;
  DateTime? finalizadaEm;
  SessaoExecucao({
    required this.id,
    this.idPublico,
    required this.idServico,
    required this.idVersaoServico,
    this.idFluxoAtual,
    this.idNoAtual,
    required this.canal,
    required this.status,
    required this.contextoJson,
    this.snapshotFluxoJson = '{}',
    this.finalizadaEm,
  });

  factory SessaoExecucao.fromMap(Map<String, dynamic> map) {
    return SessaoExecucao(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idServico: map[idServicoCol] as int? ?? 0,
      idVersaoServico: map[idVersaoServicoCol] as int? ?? 0,
      idFluxoAtual: map[idFluxoAtualCol] as int?,
      idNoAtual: map[idNoAtualCol] as int?,
      canal: map[canalCol] as String? ?? '',
      status: map[statusCol] as String? ?? '',
      contextoJson: map[contextoJsonCol]?.toString() ?? '{}',
      snapshotFluxoJson: map[snapshotFluxoJsonCol]?.toString() ?? '{}',
      finalizadaEm: map[finalizadaEmCol] != null
          ? DateTime.tryParse(map[finalizadaEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idPublicoCol: idPublico,
      idServicoCol: idServico,
      idVersaoServicoCol: idVersaoServico,
      idFluxoAtualCol: idFluxoAtual,
      idNoAtualCol: idNoAtual,
      canalCol: canal,
      statusCol: status,
      contextoJsonCol: contextoJson,
      snapshotFluxoJsonCol: snapshotFluxoJson,
      finalizadaEmCol: finalizadaEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idPublicoCol)
      ..remove(finalizadaEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idPublicoCol)
      ..remove(idServicoCol)
      ..remove(idVersaoServicoCol);
    return map;
  }

  SessaoExecucao clone() {
    return SessaoExecucao(
      id: id,
      idPublico: idPublico,
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      idFluxoAtual: idFluxoAtual,
      idNoAtual: idNoAtual,
      canal: canal,
      status: status,
      contextoJson: contextoJson,
      snapshotFluxoJson: snapshotFluxoJson,
      finalizadaEm: finalizadaEm,
    );
  }
}
