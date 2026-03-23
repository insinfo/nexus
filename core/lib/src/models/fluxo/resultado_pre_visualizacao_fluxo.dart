import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import 'no_fluxo_dto.dart';

class ResultadoPreVisualizacaoFluxo implements SerializeBase {
  static const tableName = 'resultado_pre_visualizacao_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idNoOrigemCol = 'id_no_origem';
  static const idNoOrigemFqCol = '$fqtb.$idNoOrigemCol';
  static const noAtualCol = 'no_atual';
  static const noAtualFqCol = '$fqtb.$noAtualCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const contextoCol = 'contexto';
  static const contextoFqCol = '$fqtb.$contextoCol';

  ResultadoPreVisualizacaoFluxo({
    required this.noAtual,
    required this.status,
    required this.contexto,
    this.idNoOrigem,
  });
  String? idNoOrigem;
  NoFluxoDto noAtual;
  StatusExecucao status;
  Map<String, dynamic> contexto;
  ResultadoPreVisualizacaoFluxo clone() {
    return ResultadoPreVisualizacaoFluxo(
      idNoOrigem: idNoOrigem,
      noAtual: noAtual,
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

  factory ResultadoPreVisualizacaoFluxo.fromMap(Map<String, dynamic> mapa) {
    return ResultadoPreVisualizacaoFluxo(
      idNoOrigem: mapa['id_no_origem'] as String?,
      noAtual: NoFluxoDto.fromMap(
        Map<String, dynamic>.from(mapa['no_atual'] as Map),
      ),
      status: StatusExecucao.parse(mapa['status'] as String),
      contexto: Map<String, dynamic>.from(mapa['contexto'] as Map),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_no_origem': idNoOrigem,
      'no_atual': noAtual.toMap(),
      'status': status.val,
      'contexto': contexto,
    };
  }
}
