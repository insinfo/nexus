import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'controllers/autenticacao_controller.dart';
import 'controllers/provedor_open_id_connect_controller.dart';

Handler autenticacaoRoutes() {
  final router = Router();
  router.get(
    '/.well-known/openid-configuration',
    ProvedorOpenIdConnectController.discovery,
  );
  router.get('/oidc/jwks', ProvedorOpenIdConnectController.jwks);
  router.get('/oidc/authorize', ProvedorOpenIdConnectController.authorize);
  router.post('/oidc/authorize', ProvedorOpenIdConnectController.authorize);
  router.post('/oidc/token', ProvedorOpenIdConnectController.token);
  router.get('/oidc/userinfo', ProvedorOpenIdConnectController.userInfo);
  router.post('/oidc/logout', ProvedorOpenIdConnectController.logout);
  router.post(
    '/oidc/federacao/microsoft/iniciar',
    ProvedorOpenIdConnectController.iniciarFederacaoMicrosoft,
  );
  router.post('/acesso/cadastro', AutenticacaoController.cadastrar);
  router.post('/acesso/login', AutenticacaoController.login);
  router.post(
    '/acesso/redefinicao/solicitar',
    AutenticacaoController.solicitarRedefinicaoSenha,
  );
  router.post(
    '/acesso/redefinicao/confirmar',
    AutenticacaoController.redefinirSenha,
  );
  return router.call;
}
