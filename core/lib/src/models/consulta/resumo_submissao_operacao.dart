import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ResumoSubmissaoOperacao implements SerializeBase {
  static const tableName = 'resumo_submissao_operacao';
  static const fqtb = 'public.$tableName';
  static const idSubmissaoCol = 'id_submissao';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const codigoServicoCol = 'codigo_servico';
  static const codigoServicoFqCol = '$fqtb.$codigoServicoCol';
  static const nomeServicoCol = 'nome_servico';
  static const nomeServicoFqCol = '$fqtb.$nomeServicoCol';
  static const numeroProtocoloCol = 'numero_protocolo';
  static const numeroProtocoloFqCol = '$fqtb.$numeroProtocoloCol';
  static const codigoPublicoCol = 'codigo_publico';
  static const codigoPublicoFqCol = '$fqtb.$codigoPublicoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';
  static const pontuacaoFinalCol = 'pontuacao_final';
  static const pontuacaoFinalFqCol = '$fqtb.$pontuacaoFinalCol';
  static const posicaoFinalCol = 'posicao_final';
  static const posicaoFinalFqCol = '$fqtb.$posicaoFinalCol';
  static const elegivelCol = 'elegivel';
  static const elegivelFqCol = '$fqtb.$elegivelCol';
  static const possuiTarefaAbertaCol = 'possui_tarefa_aberta';
  static const possuiTarefaAbertaFqCol = '$fqtb.$possuiTarefaAbertaCol';

  ResumoSubmissaoOperacao({
    required this.idSubmissao,
    required this.idServico,
    required this.codigoServico,
    required this.nomeServico,
    required this.numeroProtocolo,
    required this.codigoPublico,
    required this.status,
    required this.criadoEm,
    this.atualizadoEm,
    this.pontuacaoFinal,
    this.posicaoFinal,
    this.elegivel,
    this.possuiTarefaAberta = false,
  });

  String idSubmissao;
  String idServico;
  String codigoServico;
  String nomeServico;
  String numeroProtocolo;
  String codigoPublico;
  String status;
  DateTime criadoEm;
  DateTime? atualizadoEm;
  double? pontuacaoFinal;
  int? posicaoFinal;
  bool? elegivel;
  bool possuiTarefaAberta;

  ResumoSubmissaoOperacao clone() {
    return ResumoSubmissaoOperacao(
      idSubmissao: idSubmissao,
      idServico: idServico,
      codigoServico: codigoServico,
      nomeServico: nomeServico,
      numeroProtocolo: numeroProtocolo,
      codigoPublico: codigoPublico,
      status: status,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
      pontuacaoFinal: pontuacaoFinal,
      posicaoFinal: posicaoFinal,
      elegivel: elegivel,
      possuiTarefaAberta: possuiTarefaAberta,
    );
  }

  Map<String, dynamic> toInsertMap() => toMap();

  Map<String, dynamic> toUpdateMap() => toMap();

  factory ResumoSubmissaoOperacao.fromMap(Map<String, dynamic> mapa) {
    return ResumoSubmissaoOperacao(
      idSubmissao: mapa[idSubmissaoCol] as String? ?? '',
      idServico: mapa[idServicoCol] as String? ?? '',
      codigoServico: mapa[codigoServicoCol] as String? ?? '',
      nomeServico: mapa[nomeServicoCol] as String? ?? '',
      numeroProtocolo: mapa[numeroProtocoloCol] as String? ?? '',
      codigoPublico: mapa[codigoPublicoCol] as String? ?? '',
      status: mapa[statusCol] as String? ?? 'submetida',
      criadoEm: lerDataHora(mapa[criadoEmCol]) ?? DateTime.now(),
      atualizadoEm: lerDataHora(mapa[atualizadoEmCol]),
      pontuacaoFinal: lerDouble(mapa[pontuacaoFinalCol]),
      posicaoFinal: lerInt(mapa[posicaoFinalCol]),
      elegivel: lerBool(mapa[elegivelCol]),
      possuiTarefaAberta: (mapa[possuiTarefaAbertaCol] as bool?) ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idSubmissaoCol: idSubmissao,
      idServicoCol: idServico,
      codigoServicoCol: codigoServico,
      nomeServicoCol: nomeServico,
      numeroProtocoloCol: numeroProtocolo,
      codigoPublicoCol: codigoPublico,
      statusCol: status,
      criadoEmCol: criadoEm.toIso8601String(),
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
      pontuacaoFinalCol: pontuacaoFinal,
      posicaoFinalCol: posicaoFinal,
      elegivelCol: elegivel,
      possuiTarefaAbertaCol: possuiTarefaAberta,
    };
  }
}
