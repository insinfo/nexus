import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'contexto_execucao_dto.dart';

class SessaoExecucaoDto implements SerializeBase {
  static const tableName = 'sessao_execucao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const chaveFluxoAtualCol = 'chave_fluxo_atual';
  static const chaveFluxoAtualFqCol = '$fqtb.$chaveFluxoAtualCol';
  static const idNoAtualCol = 'id_no_atual';
  static const idNoAtualFqCol = '$fqtb.$idNoAtualCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const contextoCol = 'contexto';
  static const contextoFqCol = '$fqtb.$contextoCol';

  SessaoExecucaoDto({
    required this.id,
    required this.idServico,
    required this.idVersaoServico,
    required this.chaveFluxoAtual,
    required this.idNoAtual,
    required this.status,
    required this.contexto,
  });
  String id;
  String idServico;
  String idVersaoServico;
  String chaveFluxoAtual;
  String idNoAtual;
  StatusExecucao status;
  ContextoExecucaoDto contexto;
  SessaoExecucaoDto clone() {
    return SessaoExecucaoDto(
      id: id,
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      chaveFluxoAtual: chaveFluxoAtual,
      idNoAtual: idNoAtual,
      status: status,
      contexto: contexto,
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

  factory SessaoExecucaoDto.fromMap(Map<String, dynamic> mapa) {
    return SessaoExecucaoDto(
      id: mapa['id'] as String,
      idServico: mapa['id_servico'] as String,
      idVersaoServico: mapa['id_versao_servico'] as String,
      chaveFluxoAtual: mapa['chave_fluxo_atual'] as String,
      idNoAtual: mapa['id_no_atual'] as String,
      status: StatusExecucao.parse(mapa['status'] as String),
      contexto: ContextoExecucaoDto.fromMap(lerMapa(mapa['contexto'])),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'id_servico': idServico,
      'id_versao_servico': idVersaoServico,
      'chave_fluxo_atual': chaveFluxoAtual,
      'id_no_atual': idNoAtual,
      'status': status.val,
      'contexto': contexto.toMap(),
    };
  }
}
