import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ResumoResultadoClassificacao implements SerializeBase {
  static const tableName = 'resumo_resultado_classificacao';
  static const fqtb = 'public.$tableName';
  static const idSubmissaoCol = 'id_submissao';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';
  static const numeroProtocoloCol = 'numero_protocolo';
  static const numeroProtocoloFqCol = '$fqtb.$numeroProtocoloCol';
  static const codigoPublicoCol = 'codigo_publico';
  static const codigoPublicoFqCol = '$fqtb.$codigoPublicoCol';
  static const nomeServicoCol = 'nome_servico';
  static const nomeServicoFqCol = '$fqtb.$nomeServicoCol';
  static const pontuacaoFinalCol = 'pontuacao_final';
  static const pontuacaoFinalFqCol = '$fqtb.$pontuacaoFinalCol';
  static const posicaoFinalCol = 'posicao_final';
  static const posicaoFinalFqCol = '$fqtb.$posicaoFinalCol';
  static const elegivelCol = 'elegivel';
  static const elegivelFqCol = '$fqtb.$elegivelCol';
  static const justificativaCol = 'justificativa';
  static const justificativaFqCol = '$fqtb.$justificativaCol';

  ResumoResultadoClassificacao({
    required this.idSubmissao,
    required this.numeroProtocolo,
    required this.codigoPublico,
    required this.nomeServico,
    required this.pontuacaoFinal,
    this.posicaoFinal,
    required this.elegivel,
    this.justificativa = const <String, dynamic>{},
  });

  String idSubmissao;
  String numeroProtocolo;
  String codigoPublico;
  String nomeServico;
  double pontuacaoFinal;
  int? posicaoFinal;
  bool elegivel;
  Map<String, dynamic> justificativa;

  ResumoResultadoClassificacao clone() {
    return ResumoResultadoClassificacao(
      idSubmissao: idSubmissao,
      numeroProtocolo: numeroProtocolo,
      codigoPublico: codigoPublico,
      nomeServico: nomeServico,
      pontuacaoFinal: pontuacaoFinal,
      posicaoFinal: posicaoFinal,
      elegivel: elegivel,
      justificativa: justificativa,
    );
  }

  Map<String, dynamic> toInsertMap() => toMap();

  Map<String, dynamic> toUpdateMap() => toMap();

  factory ResumoResultadoClassificacao.fromMap(Map<String, dynamic> mapa) {
    return ResumoResultadoClassificacao(
      idSubmissao: mapa[idSubmissaoCol] as String? ?? '',
      numeroProtocolo: mapa[numeroProtocoloCol] as String? ?? '',
      codigoPublico: mapa[codigoPublicoCol] as String? ?? '',
      nomeServico: mapa[nomeServicoCol] as String? ?? '',
      pontuacaoFinal: lerDouble(mapa[pontuacaoFinalCol]) ?? 0,
      posicaoFinal: lerInt(mapa[posicaoFinalCol]),
      elegivel: (mapa[elegivelCol] as bool?) ?? false,
      justificativa: lerMapa(mapa[justificativaCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idSubmissaoCol: idSubmissao,
      numeroProtocoloCol: numeroProtocolo,
      codigoPublicoCol: codigoPublico,
      nomeServicoCol: nomeServico,
      pontuacaoFinalCol: pontuacaoFinal,
      posicaoFinalCol: posicaoFinal,
      elegivelCol: elegivel,
      justificativaCol: justificativa,
    };
  }
}
