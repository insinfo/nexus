import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/consulta_protocolos_controller.dart';

Handler consultaProtocolosRoutes() {
  final router = Router();

  router.get(
      '/protocolos/<codigo>', ConsultaProtocolosController.buscarPorCodigo);

  return router.call;
}
