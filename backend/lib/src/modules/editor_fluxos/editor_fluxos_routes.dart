import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/editor_fluxos_controller.dart';

Handler editorFluxosRoutes() {
  final router = Router();

  router.post('/editor/fluxos/validar', EditorFluxosController.validarFluxo);
  router.post(
    '/editor/fluxos/pre-visualizar',
    EditorFluxosController.preVisualizarFluxo,
  );

  return router.call;
}
