import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'aresta_fluxo_dto.dart';
import 'no_fluxo_dto.dart';

class FluxoDto implements SerializeBase {
  static const tableName = 'definicao_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const chaveCol = 'chave';
  static const chaveFqCol = '$fqtb.$chaveCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const nosCol = 'nos';
  static const nosFqCol = '$fqtb.$nosCol';
  static const arestasCol = 'arestas';
  static const arestasFqCol = '$fqtb.$arestasCol';

  FluxoDto({
    required this.id,
    required this.chave,
    required this.tipo,
    this.nos = const <NoFluxoDto>[],
    this.arestas = const <ArestaFluxoDto>[],
  });
  String id;
  String chave;
  TipoFluxo tipo;
  List<NoFluxoDto> nos;
  List<ArestaFluxoDto> arestas;
  FluxoDto clone() {
    return FluxoDto(
      id: id,
      chave: chave,
      tipo: tipo,
      nos: nos,
      arestas: arestas,
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

  factory FluxoDto.fromMap(Map<String, dynamic> mapa) {
    return FluxoDto(
      id: mapa['id'] as String,
      chave: mapa['chave'] as String,
      tipo: TipoFluxo.parse(mapa['tipo'] as String),
      nos: mapearLista(mapa['nos'], NoFluxoDto.fromMap),
      arestas: mapearLista(mapa['arestas'], ArestaFluxoDto.fromMap),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chave': chave,
      'tipo': tipo.val,
      'nos': serializarLista(nos),
      'arestas': serializarLista(arestas),
    };
  }
}
