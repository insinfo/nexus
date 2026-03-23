class Submissao {
  static const tableName = 'submissoes';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idServicoCol = 'id_servico';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const idSessaoExecucaoCol = 'id_sessao_execucao';
  static const idUsuarioCidadaoCol = 'id_usuario_cidadao';
  static const statusCol = 'status';
  static const snapshotJsonCol = 'snapshot_json';
  static const snapshotRankingJsonCol = 'snapshot_ranking_json';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const idSessaoExecucaoFqCol = '$fqtb.$idSessaoExecucaoCol';
  static const statusFqCol = '$fqtb.$statusCol';
  static const snapshotJsonFqCol = '$fqtb.$snapshotJsonCol';
  int id;
  String? idPublico;
  int idServico;
  int idVersaoServico;
  int? idVersaoConjuntoRegras;
  int idSessaoExecucao;
  int? idUsuarioCidadao;
  String status;
  String snapshotJson;
  String? snapshotRankingJson;
  Submissao({
    required this.id,
    this.idPublico,
    required this.idServico,
    required this.idVersaoServico,
    this.idVersaoConjuntoRegras,
    required this.idSessaoExecucao,
    this.idUsuarioCidadao,
    required this.status,
    required this.snapshotJson,
    this.snapshotRankingJson,
  });

  factory Submissao.fromMap(Map<String, dynamic> map) {
    return Submissao(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idServico: map[idServicoCol] as int? ?? 0,
      idVersaoServico: map[idVersaoServicoCol] as int? ?? 0,
      idVersaoConjuntoRegras: map[idVersaoConjuntoRegrasCol] as int?,
      idSessaoExecucao: map[idSessaoExecucaoCol] as int? ?? 0,
      idUsuarioCidadao: map[idUsuarioCidadaoCol] as int?,
      status: map[statusCol] as String? ?? 'submetida',
      snapshotJson: map[snapshotJsonCol]?.toString() ?? '{}',
      snapshotRankingJson: map[snapshotRankingJsonCol]?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idPublicoCol: idPublico,
      idServicoCol: idServico,
      idVersaoServicoCol: idVersaoServico,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      idSessaoExecucaoCol: idSessaoExecucao,
      idUsuarioCidadaoCol: idUsuarioCidadao,
      statusCol: status,
      snapshotJsonCol: snapshotJson,
      snapshotRankingJsonCol: snapshotRankingJson,
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
      ..remove(idServicoCol)
      ..remove(idVersaoServicoCol)
      ..remove(idSessaoExecucaoCol);
    return map;
  }

  Submissao clone() {
    return Submissao(
      id: id,
      idPublico: idPublico,
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      idSessaoExecucao: idSessaoExecucao,
      idUsuarioCidadao: idUsuarioCidadao,
      status: status,
      snapshotJson: snapshotJson,
      snapshotRankingJson: snapshotRankingJson,
    );
  }
}
