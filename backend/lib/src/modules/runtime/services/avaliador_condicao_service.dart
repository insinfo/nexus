import 'dart:convert';

class AvaliadorCondicaoService {
  const AvaliadorCondicaoService();

  bool avaliarExpressaoJson(
    String expressaoJson,
    Map<String, dynamic> contexto,
  ) {
    try {
      final expressao = jsonDecode(expressaoJson);
      if (expressao is! Map) {
        return false;
      }

      return avaliarExpressao(
        Map<String, dynamic>.from(expressao),
        contexto,
      );
    } catch (_) {
      return false;
    }
  }

  bool expressaoJsonValida(String expressaoJson) {
    try {
      final expressao = jsonDecode(expressaoJson);
      if (expressao is! Map) {
        return false;
      }
      return _expressaoValida(Map<String, dynamic>.from(expressao));
    } catch (_) {
      return false;
    }
  }

  bool avaliarExpressao(
    Map<String, dynamic> expressao,
    Map<String, dynamic> contexto,
  ) {
    final tipo = expressao['tipo'] as String? ?? '';
    switch (tipo) {
      case 'e':
        final regras = _lerRegras(expressao['regras']);
        return regras.isNotEmpty &&
            regras.every((regra) => avaliarExpressao(regra, contexto));
      case 'ou':
        final regras = _lerRegras(expressao['regras']);
        return regras.isNotEmpty &&
            regras.any((regra) => avaliarExpressao(regra, contexto));
      case 'comparacao':
        final campo = expressao['campo'] as String? ?? '';
        final operador = expressao['operador'] as String? ?? 'eq';
        final valorEsperado = expressao['valor'];
        final valorAtual = contexto[campo];
        return _comparar(valorAtual, operador, valorEsperado);
      default:
        return false;
    }
  }

  bool _expressaoValida(Map<String, dynamic> expressao) {
    final tipo = expressao['tipo'] as String? ?? '';
    switch (tipo) {
      case 'e':
      case 'ou':
        final regras = _lerRegras(expressao['regras']);
        return regras.isNotEmpty && regras.every(_expressaoValida);
      case 'comparacao':
        final campo = expressao['campo'] as String? ?? '';
        final operador = expressao['operador'] as String? ?? '';
        return campo.isNotEmpty && _operadoresSuportados.contains(operador);
      default:
        return false;
    }
  }

  List<Map<String, dynamic>> _lerRegras(dynamic valor) {
    final itens = (valor as List?) ?? const <dynamic>[];
    return itens
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  bool _comparar(dynamic atual, String operador, dynamic esperado) {
    switch (operador) {
      case 'eq':
        return atual == esperado;
      case 'neq':
        return atual != esperado;
      case 'vazio':
        return atual == null || atual.toString().isEmpty;
      case 'nao_vazio':
        return atual != null && atual.toString().isNotEmpty;
      case 'lt':
      case 'lte':
      case 'gt':
      case 'gte':
        final valorAtual = _paraDouble(atual);
        final valorEsperado = _paraDouble(esperado);
        if (valorAtual == null || valorEsperado == null) {
          return false;
        }
        switch (operador) {
          case 'lt':
            return valorAtual < valorEsperado;
          case 'lte':
            return valorAtual <= valorEsperado;
          case 'gt':
            return valorAtual > valorEsperado;
          case 'gte':
            return valorAtual >= valorEsperado;
        }
    }
    return false;
  }

  double? _paraDouble(dynamic valor) {
    if (valor is num) {
      return valor.toDouble();
    }
    if (valor is String) {
      return double.tryParse(valor);
    }
    return null;
  }

  static const Set<String> _operadoresSuportados = <String>{
    'eq',
    'neq',
    'vazio',
    'nao_vazio',
    'lt',
    'lte',
    'gt',
    'gte',
  };
}
