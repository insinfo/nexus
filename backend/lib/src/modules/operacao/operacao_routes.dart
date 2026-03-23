import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/operacao_controller.dart';

Handler operacaoRoutes() {
  final router = Router();
  router.get('/operacao/submissoes', OperacaoController.listarSubmissoes);
  router.get('/operacao/submissoes/<idSubmissao>',
      OperacaoController.detalharSubmissao);
  router.post('/operacao/submissoes/transicionar',
      OperacaoController.transicionarSubmissao);
  router.post('/operacao/classificacao/executar',
      OperacaoController.executarClassificacao);
  router.get('/operacao/classificacao/<idServico>/resultados',
      OperacaoController.listarResultadosClassificacao);
  return router.call;
}
