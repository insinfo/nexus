import 'package:ngdart/angular.dart';
import 'package:nexus_core/nexus_core.dart';

import 'servico_http_base.dart';

@Injectable()
class PortalPublicoService {
  PortalPublicoService(this._servicoHttpBase);

  final ServicoHttpBase _servicoHttpBase;

  Future<DadosPaginaInicialPortal> carregarPaginaInicial() async {
    final jsonMap = await _servicoHttpBase.getJsonMap('/portal/pagina-inicial');
    return DadosPaginaInicialPortal.fromMap(jsonMap);
  }

  Future<ConsultaPublicaProtocolo> consultarProtocolo(String codigo) async {
    final codigoNormalizado = Uri.encodeComponent(codigo.trim());
    final jsonMap = await _servicoHttpBase.getJsonMap(
      '/protocolos/$codigoNormalizado',
    );
    return ConsultaPublicaProtocolo.fromMap(jsonMap);
  }
}