class ResultadoClassificacao {
  static const tableName = 'resultados_classificacao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idExecucaoClassificacaoCol = 'id_execucao_classificacao';
  static const idSubmissaoCol = 'id_submissao';
  static const pontuacaoFinalCol = 'pontuacao_final';
  static const posicaoFinalCol = 'posicao_final';
  static const elegivelCol = 'elegivel';
  static const snapshotDesempateJsonCol = 'snapshot_desempate_json';
  static const justificativaJsonCol = 'justificativa_json';
  static const criadoEmCol = 'criado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idExecucaoClassificacaoFqCol =
      '$fqtb.$idExecucaoClassificacaoCol';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';

  ResultadoClassificacao({
    required this.id,
    required this.idExecucaoClassificacao,
    required this.idSubmissao,
    this.pontuacaoFinal = 0,
    this.posicaoFinal,
    this.elegivel = true,
    this.snapshotDesempateJson,
    this.justificativaJson,
    this.criadoEm,
  });

  int id;
  int idExecucaoClassificacao;
  int idSubmissao;
  double pontuacaoFinal;
  int? posicaoFinal;
  bool elegivel;
  String? snapshotDesempateJson;
  String? justificativaJson;
  DateTime? criadoEm;

  ResultadoClassificacao clone() {
    return ResultadoClassificacao(
      id: id,
      idExecucaoClassificacao: idExecucaoClassificacao,
      idSubmissao: idSubmissao,
      pontuacaoFinal: pontuacaoFinal,
      posicaoFinal: posicaoFinal,
      elegivel: elegivel,
      snapshotDesempateJson: snapshotDesempateJson,
      justificativaJson: justificativaJson,
      criadoEm: criadoEm,
    );
  }

  factory ResultadoClassificacao.fromMap(Map<String, dynamic> map) {
    return ResultadoClassificacao(
      id: map[idCol] as int? ?? 0,
      idExecucaoClassificacao: map[idExecucaoClassificacaoCol] as int? ?? 0,
      idSubmissao: map[idSubmissaoCol] as int? ?? 0,
      pontuacaoFinal: map[pontuacaoFinalCol] is num
          ? (map[pontuacaoFinalCol] as num).toDouble()
          : 0,
      posicaoFinal: map[posicaoFinalCol] as int?,
      elegivel: (map[elegivelCol] as bool?) ?? true,
      snapshotDesempateJson: map[snapshotDesempateJsonCol]?.toString(),
      justificativaJson: map[justificativaJsonCol]?.toString(),
      criadoEm: map[criadoEmCol] is DateTime
          ? map[criadoEmCol] as DateTime
          : DateTime.tryParse(map[criadoEmCol]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idExecucaoClassificacaoCol: idExecucaoClassificacao,
      idSubmissaoCol: idSubmissao,
      pontuacaoFinalCol: pontuacaoFinal,
      posicaoFinalCol: posicaoFinal,
      elegivelCol: elegivel,
      snapshotDesempateJsonCol: snapshotDesempateJson,
      justificativaJsonCol: justificativaJson,
      criadoEmCol: criadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(criadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idExecucaoClassificacaoCol);
    map.remove(idSubmissaoCol);
    return map;
  }
}
