import 'package:essential_core/essential_core.dart';

import '../editorial/publicacao_oficial.dart';
import '../suporte/modelo_utils.dart';
import 'card_metrica.dart';
import 'item_fila_trabalho.dart';
import 'resumo_no_canvas_builder.dart';

class DadosPainelRetaguarda implements SerializeBase {
  static const tableName = 'dados_painel_retarguarda';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const subtituloCol = 'subtitulo';
  static const subtituloFqCol = '$fqtb.$subtituloCol';
  static const metricasCol = 'metricas';
  static const metricasFqCol = '$fqtb.$metricasCol';
  static const filaTrabalhoCol = 'fila_trabalho';
  static const filaTrabalhoFqCol = '$fqtb.$filaTrabalhoCol';
  static const nosBuilderCol = 'nos_builder';
  static const nosBuilderFqCol = '$fqtb.$nosBuilderCol';
  static const publicacoesPendentesCol = 'publicacoes_pendentes';
  static const publicacoesPendentesFqCol = '$fqtb.$publicacoesPendentesCol';

  DadosPainelRetaguarda({
    required this.titulo,
    required this.subtitulo,
    this.metricas = const <CardMetrica>[],
    this.filaTrabalho = const <ItemFilaTrabalho>[],
    this.nosBuilder = const <ResumoNoCanvasBuilder>[],
    this.publicacoesPendentes = const <PublicacaoOficial>[],
  });
  String titulo;
  String subtitulo;
  List<CardMetrica> metricas;
  List<ItemFilaTrabalho> filaTrabalho;
  List<ResumoNoCanvasBuilder> nosBuilder;
  List<PublicacaoOficial> publicacoesPendentes;
  DadosPainelRetaguarda clone() {
    return DadosPainelRetaguarda(
      titulo: titulo,
      subtitulo: subtitulo,
      metricas: metricas,
      filaTrabalho: filaTrabalho,
      nosBuilder: nosBuilder,
      publicacoesPendentes: publicacoesPendentes,
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

  factory DadosPainelRetaguarda.fromMap(Map<String, dynamic> mapa) {
    return DadosPainelRetaguarda(
      titulo: mapa['titulo'] as String,
      subtitulo: mapa['subtitulo'] as String,
      metricas: mapearLista(mapa['metricas'], CardMetrica.fromMap),
      filaTrabalho: mapearLista(mapa['filaTrabalho'], ItemFilaTrabalho.fromMap),
      nosBuilder:
          mapearLista(mapa['nosBuilder'], ResumoNoCanvasBuilder.fromMap),
      publicacoesPendentes: mapearLista(
        mapa['publicacoesPendentes'],
        PublicacaoOficial.fromMap,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titulo': titulo,
      'subtitulo': subtitulo,
      'metricas': serializarLista(metricas),
      'filaTrabalho': serializarLista(filaTrabalho),
      'nosBuilder': serializarLista(nosBuilder),
      'publicacoesPendentes': serializarLista(publicacoesPendentes),
    };
  }
}
