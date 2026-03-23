class TextoUtils {
  static String slugificar(String valor) {
    final textoBase = valor.trim().toLowerCase();
    final buffer = StringBuffer();
    var ultimoFoiSeparador = false;

    for (final rune in textoBase.runes) {
      final caractere = String.fromCharCode(rune);
      final normalizado = _substituicoes[caractere] ?? caractere;
      if (_regexAlfanumerico.hasMatch(normalizado)) {
        buffer.write(normalizado);
        ultimoFoiSeparador = false;
        continue;
      }

      if (!ultimoFoiSeparador && buffer.isNotEmpty) {
        buffer.write('-');
        ultimoFoiSeparador = true;
      }
    }

    return buffer.toString().replaceAll(_regexSeparadoresLaterais, '');
  }

  static const Map<String, String> _substituicoes = <String, String>{
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'õ': 'o',
    'ô': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };

  static final RegExp _regexAlfanumerico = RegExp(r'[a-z0-9]');
  static final RegExp _regexSeparadoresLaterais = RegExp(r'^-+|-+$');
}
