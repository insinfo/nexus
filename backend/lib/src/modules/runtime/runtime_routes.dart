import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/runtime_controller.dart';

/// Rotas do módulo de runtime de execução de fluxos
Handler runtimeRoutes() {
  final router = Router();

  router.post('/runtime/sessoes', RuntimeController.iniciarSessao);
  router.get('/runtime/sessoes/<id>', RuntimeController.obterEstado);
  router.post('/runtime/sessoes/<id>/avancar', RuntimeController.avancarPasso);

  return router.call;
}
