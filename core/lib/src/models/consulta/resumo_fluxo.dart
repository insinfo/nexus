import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../fluxo/fluxo_dto.dart';

class ResumoFluxo implements SerializeBase {
  static const tableName = 'resumo_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const chaveCol = 'chave';
  static const chaveFqCol = '$fqtb.$chaveCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const quantidadeNosCol = 'quantidade_nos';
  static const quantidadeNosFqCol = '$fqtb.$quantidadeNosCol';
  static const quantidadeArestasCol = 'quantidade_arestas';
  static const quantidadeArestasFqCol = '$fqtb.$quantidadeArestasCol';

  ResumoFluxo({
    required this.id,
    required this.chave,
    required this.tipo,
    required this.quantidadeNos,
    required this.quantidadeArestas,
  });
  String id;
  String chave;
  TipoFluxo tipo;
  int quantidadeNos;
  int quantidadeArestas;

  factory ResumoFluxo.fromDefinicao(FluxoDto fluxo) {
    return ResumoFluxo(
      id: fluxo.id,
      chave: fluxo.chave,
      tipo: fluxo.tipo,
      quantidadeNos: fluxo.nos.length,
      quantidadeArestas: fluxo.arestas.length,
    );
  }
  ResumoFluxo clone() {
    return ResumoFluxo(
      id: id,
      chave: chave,
      tipo: tipo,
      quantidadeNos: quantidadeNos,
      quantidadeArestas: quantidadeArestas,
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

  factory ResumoFluxo.fromMap(Map<String, dynamic> mapa) {
    return ResumoFluxo(
      id: mapa['id'] as String,
      chave: mapa['chave'] as String,
      tipo: TipoFluxo.parse(mapa['tipo'] as String),
      quantidadeNos: mapa['quantidade_nos'] as int,
      quantidadeArestas: mapa['quantidade_arestas'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chave': chave,
      'tipo': tipo.val,
      'quantidade_nos': quantidadeNos,
      'quantidade_arestas': quantidadeArestas,
    };
  }
}
