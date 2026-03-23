class IdentificadorBindingUtils {
  static String? uuidOuNull(String? valor) {
    final normalizado = valor?.trim();
    if (normalizado == null || normalizado.isEmpty) {
      return null;
    }
    return _regexUuid.hasMatch(normalizado) ? normalizado : null;
  }

  static int? inteiroOuNull(String? valor) {
    final normalizado = valor?.trim();
    if (normalizado == null || normalizado.isEmpty) {
      return null;
    }
    return int.tryParse(normalizado);
  }

  static final RegExp _regexUuid = RegExp(
    r'^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[1-5][0-9a-fA-F]{3}\-[89abAB][0-9a-fA-F]{3}\-[0-9a-fA-F]{12}$',
  );
}
