class ResultadoNoSessao {
  static const tableName = 'resultados_nos_sessao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idSessaoExecucaoCol = 'id_sessao_execucao';
  static const idNoFluxoCol = 'id_no_fluxo';
  static const statusCol = 'status';
  static const payloadRequisicaoJsonCol = 'payload_requisicao_json';
  static const payloadRespostaJsonCol = 'payload_resposta_json';
  static const mensagemErroCol = 'mensagem_erro';
  static const executadoEmCol = 'executado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idSessaoExecucaoFqCol = '$fqtb.$idSessaoExecucaoCol';
  static const idNoFluxoFqCol = '$fqtb.$idNoFluxoCol';
  static const statusFqCol = '$fqtb.$statusCol';
  static const payloadRequisicaoJsonFqCol = '$fqtb.$payloadRequisicaoJsonCol';
  static const payloadRespostaJsonFqCol = '$fqtb.$payloadRespostaJsonCol';
  static const mensagemErroFqCol = '$fqtb.$mensagemErroCol';
  static const executadoEmFqCol = '$fqtb.$executadoEmCol';
  int id;
  int idSessaoExecucao;
  int idNoFluxo;
  String status;
  String? payloadRequisicaoJson;
  String? payloadRespostaJson;
  String? mensagemErro;
  DateTime? executadoEm;
  ResultadoNoSessao({
    required this.id,
    required this.idSessaoExecucao,
    required this.idNoFluxo,
    required this.status,
    this.payloadRequisicaoJson,
    this.payloadRespostaJson,
    this.mensagemErro,
    this.executadoEm,
  });

  factory ResultadoNoSessao.fromMap(Map<String, dynamic> map) {
    return ResultadoNoSessao(
      id: map[idCol] as int? ?? 0,
      idSessaoExecucao: map[idSessaoExecucaoCol] as int? ?? 0,
      idNoFluxo: map[idNoFluxoCol] as int? ?? 0,
      status: map[statusCol] as String? ?? '',
      payloadRequisicaoJson: map[payloadRequisicaoJsonCol]?.toString(),
      payloadRespostaJson: map[payloadRespostaJsonCol]?.toString(),
      mensagemErro: map[mensagemErroCol] as String?,
      executadoEm: map[executadoEmCol] != null
          ? DateTime.tryParse(map[executadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idSessaoExecucaoCol: idSessaoExecucao,
      idNoFluxoCol: idNoFluxo,
      statusCol: status,
      payloadRequisicaoJsonCol: payloadRequisicaoJson,
      payloadRespostaJsonCol: payloadRespostaJson,
      mensagemErroCol: mensagemErro,
      executadoEmCol: executadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(executadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idSessaoExecucaoCol)
      ..remove(idNoFluxoCol)
      ..remove(executadoEmCol);
    return map;
  }

  ResultadoNoSessao clone() {
    return ResultadoNoSessao(
      id: id,
      idSessaoExecucao: idSessaoExecucao,
      idNoFluxo: idNoFluxo,
      status: status,
      payloadRequisicaoJson: payloadRequisicaoJson,
      payloadRespostaJson: payloadRespostaJson,
      mensagemErro: mensagemErro,
      executadoEm: executadoEm,
    );
  }
}
