import 'dart:convert';

import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class CalculoCampo implements SerializeBase {
  static const tableName = 'calculos_campo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idCampoCol = 'id_campo';
  static const expressaoJsonCol = 'expressao_json';
  static const escopoDestinoCol = 'escopo_destino';
  static const idFqCol = '$fqtb.$idCol';
  static const idCampoFqCol = '$fqtb.$idCampoCol';
  static const expressaoJsonFqCol = '$fqtb.$expressaoJsonCol';
  static const escopoDestinoFqCol = '$fqtb.$escopoDestinoCol';
  int id;
  int idCampo;
  String expressaoJson;
  String escopoDestino;

  CalculoCampo({
    this.id = 0,
    this.idCampo = 0,
    String? expressaoJson,
    Map<String, dynamic>? expressao,
    this.escopoDestino = 'campo',
  }) : expressaoJson =
            expressaoJson ?? jsonEncode(expressao ?? const <String, dynamic>{});

  Map<String, dynamic> get expressao {
    final valor = jsonDecode(expressaoJson);
    if (valor is Map) {
      return lerMapa(valor);
    }
    return <String, dynamic>{};
  }

  set expressao(Map<String, dynamic> expressao) {
    expressaoJson = jsonEncode(expressao);
  }

  factory CalculoCampo.fromMap(Map<String, dynamic> map) {
    return CalculoCampo(
      id: map[idCol] as int? ?? 0,
      idCampo: map[idCampoCol] as int? ?? 0,
      expressaoJson: map[expressaoJsonCol]?.toString() ??
          jsonEncode(lerMapa(map['expressao'])),
      escopoDestino: map[escopoDestinoCol] as String? ?? 'campo',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expressao': expressao,
      'escopo_destino': escopoDestino,
    };
  }

  Map<String, dynamic> _toPersistenciaMap() {
    return <String, dynamic>{
      idCol: id,
      idCampoCol: idCampo,
      expressaoJsonCol: expressaoJson,
      escopoDestinoCol: escopoDestino,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = _toPersistenciaMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = _toPersistenciaMap()
      ..remove(idCol)
      ..remove(idCampoCol);
    return map;
  }

  CalculoCampo clone() {
    return CalculoCampo(
      id: id,
      idCampo: idCampo,
      expressaoJson: expressaoJson,
      escopoDestino: escopoDestino,
    );
  }
}
