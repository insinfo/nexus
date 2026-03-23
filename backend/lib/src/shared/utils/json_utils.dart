import 'dart:convert';

class JsonUtils {
  static Map<String, dynamic> lerMapa(dynamic valor) {
    if (valor is Map<String, dynamic>) {
      return valor;
    }
    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }
    if (valor is String && valor.isNotEmpty) {
      final decodificado = jsonDecode(valor);
      if (decodificado is Map<String, dynamic>) {
        return decodificado;
      }
      if (decodificado is Map) {
        return Map<String, dynamic>.from(decodificado);
      }
    }
    return <String, dynamic>{};
  }

  static String lerTexto(dynamic valor, {String padrao = '{}'}) {
    if (valor == null) {
      return padrao;
    }
    if (valor is String) {
      return valor;
    }
    if (valor is Map) {
      return jsonEncode(Map<String, dynamic>.from(valor));
    }
    return valor.toString();
  }
}
