import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/catalogo_servicos_controller.dart';

/// Rotas do catálogo de serviços
Handler catalogoServicosRoutes() {
  final router = Router();

  router.get('/servicos', CatalogoServicosController.listar);
  router.get('/servicos/<id>', CatalogoServicosController.buscarPorId);
  router.get(
      '/servicos/<id>/versoes', CatalogoServicosController.listarVersoes);
  router.get('/servicos/<id>/fluxos', CatalogoServicosController.listarFluxos);

  return router.call;
}
