import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/editorial_controller.dart';

Handler editorialRoutes() {
  final router = Router();

  router.get('/editorial/noticias', EditorialController.listarNoticias);
  router.post('/editorial/noticias', EditorialController.salvarNoticia);
  router.put('/editorial/noticias/<id>', EditorialController.atualizarNoticia);
  router.delete('/editorial/noticias/<id>', EditorialController.excluirNoticia);

  router.get(
    '/editorial/publicacoes-oficiais',
    EditorialController.listarPublicacoesOficiais,
  );
  router.post(
    '/editorial/publicacoes-oficiais',
    EditorialController.salvarPublicacaoOficial,
  );
  router.put(
    '/editorial/publicacoes-oficiais/<id>',
    EditorialController.atualizarPublicacaoOficial,
  );
  router.delete(
    '/editorial/publicacoes-oficiais/<id>',
    EditorialController.excluirPublicacaoOficial,
  );

  router.get(
    '/editorial/paginas-institucionais',
    EditorialController.listarPaginasInstitucionais,
  );
  router.post(
    '/editorial/paginas-institucionais',
    EditorialController.salvarPaginaInstitucional,
  );
  router.put(
    '/editorial/paginas-institucionais/<id>',
    EditorialController.atualizarPaginaInstitucional,
  );
  router.delete(
    '/editorial/paginas-institucionais/<id>',
    EditorialController.excluirPaginaInstitucional,
  );

  return router.call;
}
