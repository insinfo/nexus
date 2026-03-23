import 'package:dotenv/dotenv.dart';

class AppConfig {
  static AppConfig? _instancia;

  static AppConfig inst() {
    if (_instancia == null) {
      final env = DotEnv(includePlatformEnvironment: false)..load();
      _instancia = AppConfig(env);
    }
    return _instancia!;
  }

  final DotEnv env;

  AppConfig(this.env);

  String get basePath => env['basePath'] ?? '/api/v1';

  String get problemBaseUrl => env['problem_base_url'] ?? 'about:blank';

  bool get exposeProblemDebugDetails =>
      bool.tryParse(env['expose_problem_debug_details'] ?? '') ?? false;

  bool get backendLogEnabled =>
      bool.tryParse(env['backend_log_enabled'] ?? '') ?? true;

  String get backendLogLevel => env['backend_log_level'] ?? 'INFO';

  String problemType(String slug) {
    if (problemBaseUrl == 'about:blank') {
      return problemBaseUrl;
    }
    return '$problemBaseUrl/$slug';
  }

  String get serverHost => env['server_host'] ?? '0.0.0.0';
  String get serverPort => env['server_port'] ?? '8086';
  String get urlPublicaBase =>
      env['url_publica_base'] ?? 'http://127.0.0.1:$serverPort';
  String get issuerOpenIdConnect =>
      '${_normalizarUrlBase(urlPublicaBase)}$basePath';
  String? get jwkPrivadaOidcJson => env['oidc_jwk_privada_json'];
  String get microsoftTenantId => env['microsoft_tenant_id'] ?? '';
  String get microsoftClientId => env['microsoft_client_id'] ?? '';
  String get microsoftClientSecret => env['microsoft_client_secret'] ?? '';
  String get microsoftRedirectUri => env['microsoft_redirect_uri'] ?? '';
  String get microsoftAuthorityBase =>
      env['microsoft_authority_base'] ?? 'https://login.microsoftonline.com';
  List<String> get microsoftEscopos =>
      env['microsoft_scopes']?.contains(',') == true
          ? env['microsoft_scopes']!
              .split(',')
              .map((String item) => item.trim())
              .where((String item) => item.isNotEmpty)
              .toList(growable: false)
          : <String>[
              'openid',
              'profile',
              'email',
              'offline_access',
              'User.Read',
            ];
  bool get microsoftFederacaoHabilitada =>
      microsoftTenantId.isNotEmpty &&
      microsoftClientId.isNotEmpty &&
      microsoftRedirectUri.isNotEmpty;
  String get redisHost => env['redis_host'] ?? '127.0.0.1';
  int get redisPort => int.tryParse(env['redis_port'] ?? '') ?? 6379;
  int get redisDatabase => int.tryParse(env['redis_database'] ?? '') ?? 0;
  String get redisUsername => env['redis_username'] ?? '';
  String get redisPassword => env['redis_password'] ?? '';
  bool get redisUseTls => bool.tryParse(env['redis_use_tls'] ?? '') ?? false;
  String get redisOidcSessionPrefix =>
      env['redis_oidc_session_prefix'] ?? 'nexus:oidc:session:';
  String get dbName => env['db_name']!;
  String get dbHost => env['db_host']!;
  String get dbPort => env['db_port']!;
  String get dbUser => env['db_user']!;
  String get dbPass => env['db_pass']!;
  bool get dbUsePool => bool.tryParse(env['db_use_pool'] ?? '') ?? true;
  int get dbPoolSize => int.tryParse(env['db_pool_size'] ?? '') ?? 4;

  List<String> get dbSchemas => env['db_schemas']?.contains(',') == true
      ? env['db_schemas']!.split(',')
      : [env['db_schemas'] ?? 'public'];

  String _normalizarUrlBase(String valor) {
    if (valor.endsWith('/')) {
      return valor.substring(0, valor.length - 1);
    }
    return valor;
  }
}
