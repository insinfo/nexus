import 'package:nexus_core/nexus_core.dart';

abstract class RuntimePort {
  Future<EstadoPassoRuntime> iniciarSessao(
    String idServico,
    String canal,
    Map<String, dynamic> contextoInicial,
  );

  Future<EstadoPassoRuntime?> obterEstado(String idSessao);

  Future<EstadoPassoRuntime> avancarPasso(
    String idSessao,
    Map<String, dynamic> respostas,
  );
}
