class RespostaSessao {
  static const tableName = 'respostas_sessao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idSessaoExecucaoCol = 'id_sessao_execucao';
  static const idCampoCol = 'id_campo';
  static const chaveCampoCol = 'chave_campo';
  static const indiceRepeticaoCol = 'indice_repeticao';
  static const valorJsonCol = 'valor_json';
  static const idNoOrigemCol = 'id_no_origem';
  static const atualizadoEmCol = 'atualizado_em';
  static const idFqCol = '$fqtb.$idCol';
  static const idSessaoExecucaoFqCol = '$fqtb.$idSessaoExecucaoCol';
  static const idCampoFqCol = '$fqtb.$idCampoCol';
  static const chaveCampoFqCol = '$fqtb.$chaveCampoCol';
  static const indiceRepeticaoFqCol = '$fqtb.$indiceRepeticaoCol';
  static const valorJsonFqCol = '$fqtb.$valorJsonCol';
  static const idNoOrigemFqCol = '$fqtb.$idNoOrigemCol';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';
  int id;
  int idSessaoExecucao;
  int idCampo;
  String chaveCampo;
  int indiceRepeticao;
  String? valorJson;
  int? idNoOrigem;
  DateTime? atualizadoEm;
  RespostaSessao({
    required this.id,
    required this.idSessaoExecucao,
    required this.idCampo,
    required this.chaveCampo,
    this.indiceRepeticao = 0,
    this.valorJson,
    this.idNoOrigem,
    this.atualizadoEm,
  });

  factory RespostaSessao.fromMap(Map<String, dynamic> map) {
    return RespostaSessao(
      id: map[idCol] as int? ?? 0,
      idSessaoExecucao: map[idSessaoExecucaoCol] as int? ?? 0,
      idCampo: map[idCampoCol] as int? ?? 0,
      chaveCampo: map[chaveCampoCol] as String? ?? '',
      indiceRepeticao: map[indiceRepeticaoCol] as int? ?? 0,
      valorJson: map[valorJsonCol]?.toString(),
      idNoOrigem: map[idNoOrigemCol] as int?,
      atualizadoEm: map[atualizadoEmCol] != null
          ? DateTime.tryParse(map[atualizadoEmCol].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idSessaoExecucaoCol: idSessaoExecucao,
      idCampoCol: idCampo,
      chaveCampoCol: chaveCampo,
      indiceRepeticaoCol: indiceRepeticao,
      valorJsonCol: valorJson,
      idNoOrigemCol: idNoOrigem,
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(atualizadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idSessaoExecucaoCol)
      ..remove(idCampoCol)
      ..remove(chaveCampoCol)
      ..remove(indiceRepeticaoCol)
      ..remove(idNoOrigemCol);
    return map;
  }

  RespostaSessao clone() {
    return RespostaSessao(
      id: id,
      idSessaoExecucao: idSessaoExecucao,
      idCampo: idCampo,
      chaveCampo: chaveCampo,
      indiceRepeticao: indiceRepeticao,
      valorJson: valorJson,
      idNoOrigem: idNoOrigem,
      atualizadoEm: atualizadoEm,
    );
  }
}
