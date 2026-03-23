import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';
import 'fluxo_dto.dart';

class RequisicaoPreVisualizacaoFluxo implements SerializeBase {
  static const tableName = 'requisicao_pre_visualizacao_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const fluxoCol = 'fluxo';
  static const fluxoFqCol = '$fqtb.$fluxoCol';
  static const idNoAtualCol = 'id_no_atual';
  static const idNoAtualFqCol = '$fqtb.$idNoAtualCol';
  static const contextoCol = 'contexto';
  static const contextoFqCol = '$fqtb.$contextoCol';
  static const respostasCol = 'respostas';
  static const respostasFqCol = '$fqtb.$respostasCol';

  RequisicaoPreVisualizacaoFluxo({
    required this.fluxo,
    this.idNoAtual,
    this.contexto = const <String, dynamic>{},
    this.respostas = const <String, dynamic>{},
  });
  FluxoDto fluxo;
  String? idNoAtual;
  Map<String, dynamic> contexto;
  Map<String, dynamic> respostas;
  RequisicaoPreVisualizacaoFluxo clone() {
    return RequisicaoPreVisualizacaoFluxo(
      fluxo: fluxo,
      idNoAtual: idNoAtual,
      contexto: contexto,
      respostas: respostas,
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

  factory RequisicaoPreVisualizacaoFluxo.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoPreVisualizacaoFluxo(
      fluxo: FluxoDto.fromMap(lerMapa(mapa['fluxo'])),
      idNoAtual: mapa['id_no_atual'] as String?,
      contexto: lerMapa(mapa['contexto']),
      respostas: lerMapa(mapa['respostas']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fluxo': fluxo.toMap(),
      'id_no_atual': idNoAtual,
      'contexto': contexto,
      'respostas': respostas,
    };
  }
}
