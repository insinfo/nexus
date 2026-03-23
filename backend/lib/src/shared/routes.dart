import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../modules/autenticacao/autenticacao_routes.dart';
import '../modules/catalogo_servicos/catalogo_servicos_routes.dart';
import '../modules/consulta_protocolos/consulta_protocolos_routes.dart';
import '../modules/editorial/editorial_routes.dart';
import '../modules/editor_fluxos/editor_fluxos_routes.dart';
import '../modules/editor_servicos/editor_servicos_routes.dart';

import '../modules/operacao/operacao_routes.dart';
import '../modules/portal_publico/portal_publico_routes.dart';
import '../modules/runtime/runtime_routes.dart';
import '../modules/health/health_routes.dart';
import 'app_config.dart';

/// Registra todas as rotas da API no roteador principal.
void routes(Router app) {
  app.get('/', (Request request) => Response.ok('nexus'));

  app.mount(AppConfig.inst().basePath, catalogoServicosRoutes());
  app.mount(AppConfig.inst().basePath, autenticacaoRoutes());
  app.mount(AppConfig.inst().basePath, consultaProtocolosRoutes());
  app.mount(AppConfig.inst().basePath, editorialRoutes());
  app.mount(AppConfig.inst().basePath, editorFluxosRoutes());
  app.mount(AppConfig.inst().basePath, editorServicosRoutes());
  app.mount(AppConfig.inst().basePath, operacaoRoutes());
  app.mount(AppConfig.inst().basePath, portalPublicoRoutes());
  app.mount(AppConfig.inst().basePath, runtimeRoutes());
  app.mount(AppConfig.inst().basePath, healthRoutes());
}
