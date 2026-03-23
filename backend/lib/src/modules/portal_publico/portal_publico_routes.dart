import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/portal_publico_controller.dart';

Handler portalPublicoRoutes() {
  final router = Router();

  router.get(
      '/portal/pagina-inicial', PortalPublicoController.buscarPaginaInicial);
  router.get('/portal/noticias', PortalPublicoController.listarNoticias);
  router.get('/portal/publicacoes-oficiais',
      PortalPublicoController.listarPublicacoesOficiais);
  router.get('/portal/paginas-institucionais',
      PortalPublicoController.listarPaginasInstitucionais);

  return router.call;
}
