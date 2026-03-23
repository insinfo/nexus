import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class RequisicaoAvancarPasso implements SerializeBase {
  static const tableName = 'requisicao_avancar_passo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const respostasCol = 'respostas';
  static const respostasFqCol = '$fqtb.$respostasCol';

  RequisicaoAvancarPasso({
    this.respostas = const <String, dynamic>{},
  });

  Map<String, dynamic> respostas;

  RequisicaoAvancarPasso clone() {
    return RequisicaoAvancarPasso(
      respostas: respostas,
    );
  }

  factory RequisicaoAvancarPasso.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoAvancarPasso(
      respostas: lerMapa(mapa[respostasCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      respostasCol: respostas,
    };
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
}
