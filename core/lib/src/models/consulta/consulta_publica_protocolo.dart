import 'package:essential_core/essential_core.dart';

import 'andamento_consulta_publica_protocolo.dart';
import 'resumo_resposta_protocolo.dart';
import '../suporte/modelo_utils.dart';

class ConsultaPublicaProtocolo implements SerializeBase {
  static const tableName = 'consulta_publica_protocolo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idSubmissaoCol = 'id_submissao';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const codigoServicoCol = 'codigo_servico';
  static const codigoServicoFqCol = '$fqtb.$codigoServicoCol';
  static const nomeServicoCol = 'nome_servico';
  static const nomeServicoFqCol = '$fqtb.$nomeServicoCol';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const numeroVersaoServicoCol = 'numero_versao_servico';
  static const numeroVersaoServicoFqCol = '$fqtb.$numeroVersaoServicoCol';
  static const numeroProtocoloCol = 'numero_protocolo';
  static const numeroProtocoloFqCol = '$fqtb.$numeroProtocoloCol';
  static const codigoPublicoCol = 'codigo_publico';
  static const codigoPublicoFqCol = '$fqtb.$codigoPublicoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const descricaoStatusCol = 'descricao_status';
  static const descricaoStatusFqCol = '$fqtb.$descricaoStatusCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const totalRespostasCol = 'total_respostas';
  static const totalRespostasFqCol = '$fqtb.$totalRespostasCol';
  static const snapshotCol = 'snapshot';
  static const snapshotFqCol = '$fqtb.$snapshotCol';
  static const respostasResumoCol = 'respostas_resumo';
  static const respostasResumoFqCol = '$fqtb.$respostasResumoCol';
  static const andamentosCol = 'andamentos';
  static const andamentosFqCol = '$fqtb.$andamentosCol';

  ConsultaPublicaProtocolo({
    required this.idSubmissao,
    required this.idServico,
    required this.codigoServico,
    required this.nomeServico,
    required this.idVersaoServico,
    required this.numeroVersaoServico,
    required this.numeroProtocolo,
    required this.codigoPublico,
    required this.status,
    this.descricaoStatus,
    required this.criadoEm,
    this.totalRespostas = 0,
    this.snapshot = const <String, dynamic>{},
    this.respostasResumo = const <ResumoRespostaProtocolo>[],
    this.andamentos = const <AndamentoConsultaPublicaProtocolo>[],
  });

  String idSubmissao;
  String idServico;
  String codigoServico;
  String nomeServico;
  String idVersaoServico;
  int numeroVersaoServico;
  String numeroProtocolo;
  String codigoPublico;
  String status;
  String? descricaoStatus;
  DateTime criadoEm;
  int totalRespostas;
  Map<String, dynamic> snapshot;
  List<ResumoRespostaProtocolo> respostasResumo;
  List<AndamentoConsultaPublicaProtocolo> andamentos;

  ConsultaPublicaProtocolo clone() {
    return ConsultaPublicaProtocolo(
      idSubmissao: idSubmissao,
      idServico: idServico,
      codigoServico: codigoServico,
      nomeServico: nomeServico,
      idVersaoServico: idVersaoServico,
      numeroVersaoServico: numeroVersaoServico,
      numeroProtocolo: numeroProtocolo,
      codigoPublico: codigoPublico,
      status: status,
      descricaoStatus: descricaoStatus,
      criadoEm: criadoEm,
      totalRespostas: totalRespostas,
      snapshot: snapshot,
      respostasResumo: respostasResumo,
      andamentos: andamentos,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  factory ConsultaPublicaProtocolo.fromMap(Map<String, dynamic> mapa) {
    return ConsultaPublicaProtocolo(
      idSubmissao: mapa[idSubmissaoCol] as String? ?? '',
      idServico: mapa[idServicoCol] as String? ?? '',
      codigoServico: mapa[codigoServicoCol] as String? ?? '',
      nomeServico: mapa[nomeServicoCol] as String? ?? '',
      idVersaoServico: mapa[idVersaoServicoCol] as String? ?? '',
      numeroVersaoServico: mapa[numeroVersaoServicoCol] as int? ?? 0,
      numeroProtocolo: mapa[numeroProtocoloCol] as String? ?? '',
      codigoPublico: mapa[codigoPublicoCol] as String? ?? '',
      status: mapa[statusCol] as String? ?? '',
      descricaoStatus: mapa[descricaoStatusCol] as String?,
      criadoEm: lerDataHora(mapa[criadoEmCol]) ?? DateTime.now(),
      totalRespostas: mapa[totalRespostasCol] as int? ?? 0,
      snapshot: lerMapa(mapa[snapshotCol]),
      respostasResumo: mapearLista(
          mapa[respostasResumoCol], ResumoRespostaProtocolo.fromMap),
      andamentos: mapearLista(
          mapa[andamentosCol], AndamentoConsultaPublicaProtocolo.fromMap),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_submissao': idSubmissao,
      'id_servico': idServico,
      'codigo_servico': codigoServico,
      'nome_servico': nomeServico,
      'id_versao_servico': idVersaoServico,
      'numero_versao_servico': numeroVersaoServico,
      'numero_protocolo': numeroProtocolo,
      'codigo_publico': codigoPublico,
      'status': status,
      'descricao_status': descricaoStatus,
      'criado_em': criadoEm.toIso8601String(),
      'total_respostas': totalRespostas,
      'snapshot': snapshot,
      'respostas_resumo':
          respostasResumo.map((item) => item.toMap()).toList(growable: false),
      'andamentos':
          andamentos.map((item) => item.toMap()).toList(growable: false),
    };
  }
}
