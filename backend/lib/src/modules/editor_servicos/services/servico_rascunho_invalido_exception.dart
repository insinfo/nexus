class ServicoRascunhoInvalidoException implements Exception {
  const ServicoRascunhoInvalidoException(this.errosFluxos);

  final List<Map<String, dynamic>> errosFluxos;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'valido': false,
      'erros_fluxos': errosFluxos,
    };
  }

  @override
  String toString() {
    return 'ServicoRascunhoInvalidoException(errosFluxos: ${errosFluxos.length})';
  }
}
