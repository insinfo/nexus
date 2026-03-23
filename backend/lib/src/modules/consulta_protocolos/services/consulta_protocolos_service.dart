import 'package:nexus_core/nexus_core.dart';

import '../repositories/consulta_protocolos_repository.dart';
import 'consulta_protocolos_port.dart';

class ConsultaProtocolosService implements ConsultaProtocolosPort {
  ConsultaProtocolosService(this._repository);

  final ConsultaProtocolosRepository _repository;

  @override
  Future<ConsultaPublicaProtocolo?> buscarPorCodigo(String codigo) {
    return _repository.findByCodigo(codigo);
  }
}
