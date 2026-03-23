import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';
import 'erro_validacao_fluxo.dart';

class ResultadoValidacaoFluxo implements SerializeBase {
  static const tableName = 'resultado_validacao_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const validoCol = 'valido';
  static const validoFqCol = '$fqtb.$validoCol';
  static const errosCol = 'erros';
  static const errosFqCol = '$fqtb.$errosCol';

  ResultadoValidacaoFluxo({
    required this.valido,
    this.erros = const <ErroValidacaoFluxo>[],
  });
  bool valido;
  List<ErroValidacaoFluxo> erros;
  ResultadoValidacaoFluxo clone() {
    return ResultadoValidacaoFluxo(
      valido: valido,
      erros: erros,
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

  factory ResultadoValidacaoFluxo.fromMap(Map<String, dynamic> mapa) {
    return ResultadoValidacaoFluxo(
      valido: mapa['valido'] as bool,
      erros: mapearLista(mapa['erros'], ErroValidacaoFluxo.fromMap),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'valido': valido,
      'erros': serializarLista(erros),
    };
  }
}
