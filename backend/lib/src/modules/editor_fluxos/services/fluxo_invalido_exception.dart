import 'package:nexus_core/nexus_core.dart';

class FluxoInvalidoException implements Exception {
  const FluxoInvalidoException(this.resultado);

  final ResultadoValidacaoFluxo resultado;

  @override
  String toString() {
    return 'FluxoInvalidoException(valido: ${resultado.valido}, erros: ${resultado.erros.length})';
  }
}
