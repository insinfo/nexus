class ConjuntoChavesJsonWeb {
  ConjuntoChavesJsonWeb({
    this.chaves = const <Map<String, dynamic>>[],
  });

  List<Map<String, dynamic>> chaves;

  factory ConjuntoChavesJsonWeb.fromMap(Map<String, dynamic> map) {
    final valor = map['keys'];
    final chaves = <Map<String, dynamic>>[];
    if (valor is List) {
      for (final item in valor) {
        if (item is Map) {
          chaves.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return ConjuntoChavesJsonWeb(chaves: chaves);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'keys': chaves,
    };
  }

  ConjuntoChavesJsonWeb clone() {
    return ConjuntoChavesJsonWeb.fromMap(toMap());
  }
}
