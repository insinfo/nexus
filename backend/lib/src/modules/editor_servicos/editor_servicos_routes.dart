import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/editor_servicos_controller.dart';

Handler editorServicosRoutes() {
  final router = Router();
  router.post('/editor/servicos/salvar-rascunho',
      EditorServicosController.salvarRascunho);
  router.post('/editor/servicos/publicar-versao',
      EditorServicosController.publicarVersao);
  return router.call;
}
