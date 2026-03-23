import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ResumoExecucaoClassificacao implements SerializeBase {
  static const tableName = 'resumo_execucao_classificacao';
  static const fqtb = 'public.$tableName';
  static const idExecucaoCol = 'id_execucao';
  static const idExecucaoFqCol = '$fqtb.$idExecucaoCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const idVersaoConjuntoRegrasFqCol = '$fqtb.$idVersaoConjuntoRegrasCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const quantidadeProcessadaCol = 'quantidade_processada';
  static const quantidadeProcessadaFqCol = '$fqtb.$quantidadeProcessadaCol';
  static const iniciadoEmCol = 'iniciado_em';
  static const iniciadoEmFqCol = '$fqtb.$iniciadoEmCol';
  static const finalizadoEmCol = 'finalizado_em';
  static const finalizadoEmFqCol = '$fqtb.$finalizadoEmCol';
  static const notasCol = 'notas';
  static const notasFqCol = '$fqtb.$notasCol';

  ResumoExecucaoClassificacao({
    required this.idExecucao,
    required this.idServico,
    required this.idVersaoServico,
    required this.idVersaoConjuntoRegras,
    required this.status,
    required this.quantidadeProcessada,
    required this.iniciadoEm,
    this.finalizadoEm,
    this.notas,
  });

  String idExecucao;
  String idServico;
  String idVersaoServico;
  String idVersaoConjuntoRegras;
  String status;
  int quantidadeProcessada;
  DateTime iniciadoEm;
  DateTime? finalizadoEm;
  String? notas;

  ResumoExecucaoClassificacao clone() {
    return ResumoExecucaoClassificacao(
      idExecucao: idExecucao,
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      status: status,
      quantidadeProcessada: quantidadeProcessada,
      iniciadoEm: iniciadoEm,
      finalizadoEm: finalizadoEm,
      notas: notas,
    );
  }

  Map<String, dynamic> toInsertMap() => toMap();

  Map<String, dynamic> toUpdateMap() => toMap();

  factory ResumoExecucaoClassificacao.fromMap(Map<String, dynamic> mapa) {
    return ResumoExecucaoClassificacao(
      idExecucao: mapa[idExecucaoCol] as String? ?? '',
      idServico: mapa[idServicoCol] as String? ?? '',
      idVersaoServico: mapa[idVersaoServicoCol] as String? ?? '',
      idVersaoConjuntoRegras: mapa[idVersaoConjuntoRegrasCol] as String? ?? '',
      status: mapa[statusCol] as String? ?? 'pendente',
      quantidadeProcessada: mapa[quantidadeProcessadaCol] as int? ?? 0,
      iniciadoEm: lerDataHora(mapa[iniciadoEmCol]) ?? DateTime.now(),
      finalizadoEm: lerDataHora(mapa[finalizadoEmCol]),
      notas: mapa[notasCol] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idExecucaoCol: idExecucao,
      idServicoCol: idServico,
      idVersaoServicoCol: idVersaoServico,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      statusCol: status,
      quantidadeProcessadaCol: quantidadeProcessada,
      iniciadoEmCol: iniciadoEm.toIso8601String(),
      finalizadoEmCol: finalizadoEm?.toIso8601String(),
      notasCol: notas,
    };
  }
}
