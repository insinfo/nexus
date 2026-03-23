import 'package:essential_core/essential_core.dart';

DateTime? lerDataHora(dynamic valor) {
  if (valor == null) {
    return null;
  }
  if (valor is DateTime) {
    return valor;
  }
  return DateTime.parse(valor as String);
}

Map<String, dynamic> lerMapa(dynamic valor) {
  if (valor == null) {
    return <String, dynamic>{};
  }
  return Map<String, dynamic>.from(valor as Map);
}

List<String> lerListaTexto(dynamic valor) {
  List<dynamic> itens = (valor as List<dynamic>?) ?? const <dynamic>[];
  return itens.map((dynamic item) => item.toString()).toList(growable: false);
}

List<T> mapearLista<T>(
  dynamic valor,
  T Function(Map<String, dynamic> mapa) conversor,
) {
  List<dynamic> itens = (valor as List<dynamic>?) ?? const <dynamic>[];
  return itens
      .map((dynamic item) => conversor(Map<String, dynamic>.from(item as Map)))
      .toList(growable: false);
}

List<Map<String, dynamic>> serializarLista<T extends SerializeBase>(
    Iterable<T> itens) {
  return itens.map((T item) => item.toMap()).toList(growable: false);
}

Map<String, dynamic>? serializarOpcional(SerializeBase? valor) {
  return valor?.toMap();
}

double? lerDouble(dynamic valor) =>
    valor == null ? null : (valor as num).toDouble();

int? lerInt(dynamic valor) => valor == null ? null : valor as int;

bool? lerBool(dynamic valor) => valor == null ? null : valor as bool;
