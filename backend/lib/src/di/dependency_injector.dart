import 'package:eloquent/eloquent.dart';
import 'package:get_it/get_it.dart';

import '../modules/autenticacao/repositories/autenticacao_repository.dart';
import '../modules/autenticacao/repositories/provedor_oidc_repository.dart';
import '../modules/autenticacao/services/autenticacao_port.dart';
import '../modules/autenticacao/services/autenticacao_service.dart';
import '../modules/autenticacao/services/assinador_token_oidc_service.dart';
import '../modules/autenticacao/services/federacao_microsoft_service.dart';
import '../modules/autenticacao/services/oidc_session_redis_service.dart';
import '../modules/autenticacao/services/provedor_open_id_connect_port.dart';
import '../modules/autenticacao/services/provedor_open_id_connect_service.dart';
import '../modules/catalogo_servicos/repositories/catalogo_servicos_repository.dart';
import '../modules/consulta_protocolos/repositories/consulta_protocolos_repository.dart';
import '../modules/consulta_protocolos/services/consulta_protocolos_port.dart';
import '../modules/consulta_protocolos/services/consulta_protocolos_service.dart';
import '../modules/editor_fluxos/services/resolvedor_conteudo_dinamico_preview_service.dart';
import '../modules/editor_fluxos/services/pre_visualizacao_fluxo_service.dart';
import '../modules/editor_fluxos/services/validador_fluxo_service.dart';
import '../modules/editorial/repositories/editorial_repository.dart';
import '../modules/editor_servicos/repositories/editor_servicos_repository.dart';
import '../modules/editor_servicos/services/editor_servicos_port.dart';
import '../modules/editor_servicos/services/editor_servicos_service.dart';
import '../modules/operacao/repositories/operacao_repository.dart';
import '../modules/operacao/services/operacao_port.dart';
import '../modules/operacao/services/operacao_service.dart';
import '../modules/portal_publico/repositories/portal_publico_repository.dart';
import '../modules/runtime/repositories/runtime_repository.dart';
import '../modules/runtime/services/avaliador_condicao_service.dart';
import '../modules/runtime/services/executor_conteudo_dinamico_service.dart';
import '../modules/runtime/services/runtime_port.dart';
import '../shared/app_config.dart';
import '../shared/db_service.dart';
import '../shared/services/reconstrutor_formulario_persistido_service.dart';

final ioc = GetIt.instance;

/// Configura e injeta as dependências da aplicação.
///
/// Quando chamada pelo bootstrap (sem argumento), registra [AppConfig] e
/// [DatabaseService] como singletons globais.
/// Quando chamada pelo middleware por requisição, registra os repositórios
/// como factories no escopo isolado passado em [locator].
void setupDependencies([GetIt? locator]) {
  final di = locator ?? ioc;
  final cfg = AppConfig.inst();

  if (!di.isRegistered<AppConfig>()) {
    di.registerSingleton<AppConfig>(cfg);
  }
  if (!di.isRegistered<DatabaseService>()) {
    di.registerSingleton<DatabaseService>(DatabaseService(cfg));
  }
  if (!di.isRegistered<OidcSessionRedisService>()) {
    di.registerLazySingleton<OidcSessionRedisService>(
      () => OidcSessionRedisService(di.get<AppConfig>()),
    );
  }

  void regFactory<T extends Object>(T Function() factory) {
    if (!di.isRegistered<T>()) {
      di.registerFactory<T>(factory);
    }
  }

  regFactory<CatalogoServicosRepository>(
    () => CatalogoServicosRepository(
      di.get<Connection>(),
      di.get<ReconstrutorFormularioPersistidoService>(),
    ),
  );
  regFactory<AutenticacaoRepository>(
    () => AutenticacaoRepository(di.get<Connection>()),
  );
  regFactory<AutenticacaoPort>(
    () => AutenticacaoService(
      di.get<Connection>(),
      di.get<AutenticacaoRepository>(),
    ),
  );
  regFactory<ProvedorOidcRepository>(
    () => ProvedorOidcRepository(di.get<Connection>()),
  );
  regFactory<AssinadorTokenOidcService>(
    () => AssinadorTokenOidcService(di.get<AppConfig>()),
  );
  regFactory<FederacaoMicrosoftService>(
    () => FederacaoMicrosoftService(di.get<AppConfig>()),
  );
  regFactory<ProvedorOpenIdConnectPort>(
    () => ProvedorOpenIdConnectService(
      di.get<Connection>(),
      di.get<AppConfig>(),
      di.get<AutenticacaoRepository>(),
      di.get<ProvedorOidcRepository>(),
      di.get<AssinadorTokenOidcService>(),
      di.get<OidcSessionRedisService>(),
      di.get<FederacaoMicrosoftService>(),
    ),
  );
  regFactory<ReconstrutorFormularioPersistidoService>(
    () => ReconstrutorFormularioPersistidoService(di.get<Connection>()),
  );
  regFactory<ConsultaProtocolosRepository>(
    () => ConsultaProtocolosRepository(di.get<Connection>()),
  );
  regFactory<ConsultaProtocolosPort>(
    () => ConsultaProtocolosService(di.get<ConsultaProtocolosRepository>()),
  );
  regFactory<AvaliadorCondicaoService>(
    () => const AvaliadorCondicaoService(),
  );
  regFactory<ExecutorConteudoDinamicoService>(
    () => const ExecutorConteudoDinamicoService(),
  );
  regFactory<ValidadorFluxoService>(
    () => ValidadorFluxoService(di.get<AvaliadorCondicaoService>()),
  );
  regFactory<ResolvedorConteudoDinamicoPreviewService>(
    () => ResolvedorConteudoDinamicoPreviewService(
      di.get<ExecutorConteudoDinamicoService>(),
    ),
  );
  regFactory<PreVisualizacaoFluxoService>(
    () => PreVisualizacaoFluxoService(
      di.get<ValidadorFluxoService>(),
      di.get<AvaliadorCondicaoService>(),
      di.get<ResolvedorConteudoDinamicoPreviewService>(),
    ),
  );
  regFactory<EditorServicosRepository>(
    () => EditorServicosRepository(di.get<Connection>()),
  );
  regFactory<EditorialRepository>(
    () => EditorialRepository(di.get<Connection>()),
  );
  regFactory<EditorServicosPort>(
    () => EditorServicosService(
      di.get<EditorServicosRepository>(),
      di.get<CatalogoServicosRepository>(),
      di.get<ValidadorFluxoService>(),
    ),
  );
  regFactory<OperacaoRepository>(
    () => OperacaoRepository(
      di.get<Connection>(),
      di.get<AvaliadorCondicaoService>(),
    ),
  );
  regFactory<OperacaoPort>(
    () => OperacaoService(di.get<OperacaoRepository>()),
  );
  regFactory<PortalPublicoRepository>(
    () => PortalPublicoRepository(
      di.get<Connection>(),
      di.get<CatalogoServicosRepository>(),
    ),
  );
  regFactory<RuntimeRepository>(
    () => RuntimeRepository(
      di.get<Connection>(),
      di.get<AvaliadorCondicaoService>(),
      di.get<ExecutorConteudoDinamicoService>(),
      di.get<ReconstrutorFormularioPersistidoService>(),
      di.get<OperacaoPort>(),
    ),
  );
  regFactory<RuntimePort>(
    () => di.get<RuntimeRepository>(),
  );
}
