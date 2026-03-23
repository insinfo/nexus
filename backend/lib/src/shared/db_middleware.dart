import 'package:eloquent/eloquent.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';

import '../di/dependency_injector.dart';
import 'db_service.dart';

/// Middleware que gerencia o ciclo de vida da conexão usando escopos do GetIt.
///
/// O [DatabaseService] decide se a conexão vem de um pool ou se uma nova
/// conexão física será criada para a requisição atual.
Middleware withDbShelfMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final dbService = ioc.get<DatabaseService>();
      final requestIoc = GetIt.asNewInstance();
      Connection? conn;

      try {
        setupDependencies(requestIoc);

        conn = await dbService.connect();
        requestIoc.registerSingleton<Connection>(conn);

        final newRequest = request.change(
          context: {
            ...request.context,
            'db_connection': conn,
            'ioc': requestIoc,
          },
        );

        return await innerHandler(newRequest);
      } finally {
        if (conn != null && !dbService.appConfig.dbUsePool) {
          await conn.disconnect();
        }
        await requestIoc.reset(dispose: true);
      }
    };
  };
}
