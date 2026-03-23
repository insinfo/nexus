import 'package:eloquent/eloquent.dart';

import 'app_config.dart';

class DatabaseService {
  final AppConfig appConfig;

  late final Manager _manager = Manager()
    ..addConnection(_baseConfig, 'default');

  DatabaseService(this.appConfig);

  Map<String, dynamic> get _baseConfig => {
        'driver': 'pgsql',
        'driver_implementation': 'postgres',
        'host': appConfig.dbHost,
        'port': appConfig.dbPort,
        'database': appConfig.dbName,
        'username': appConfig.dbUser,
        'password': appConfig.dbPass,
        'charset': 'utf8',
        'schema': appConfig.dbSchemas,
        'pool': appConfig.dbUsePool,
        'poolsize': appConfig.dbPoolSize,
        'timezone': 'America/Sao_Paulo',
        'application_name': 'nexus',
      };

  Future<Connection> connect([String name = 'default']) async {
    if (appConfig.dbUsePool) {
      return _manager.getConnection(name);
    }

    final mgr = Manager()..addConnection(_baseConfig, name);
    return mgr.getConnection(name);
  }
}
