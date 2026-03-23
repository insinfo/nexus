import 'package:nexus_core/nexus_core.dart';

abstract class ConsultaProtocolosPort {
  Future<ConsultaPublicaProtocolo?> buscarPorCodigo(String codigo);
}
