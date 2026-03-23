import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

import '../di/dependency_injector.dart';
import 'db_middleware.dart';
import 'app_config.dart';
import 'routes.dart';

final _log = Logger('nexus.bootstrap');

const _corsAllowHeaders =
    'accept,accept-encoding,authorization,content-type,dnt,origin,user-agent';

/// Inicializa o servidor com o número de isolados solicitado.
Future<void> configureServer(
  String address,
  int port,
  int numberOfIsolates,
) async {
  final argumentos = [address, port];
  if (numberOfIsolates > 1) {
    for (var i = 0; i < numberOfIsolates - 1; i++) {
      await Isolate.spawn(
        _startServer,
        [i, argumentos],
        debugName: i.toString(),
      );
    }
    _startServer([numberOfIsolates - 1, argumentos]);
  } else {
    _startServer([1, argumentos]);
  }
}

/// Inicializa e configura o servidor em cada isolado.
void _startServer(List args) async {
  _configurarLogging();

  final serverArgs = args[1] as List;
  final address = serverArgs[0] as String;
  final port = serverArgs[1] as int;

  final app = Router();

  // Registra singletons globais (AppConfig e DatabaseService)
  setupDependencies();

  // Monta as rotas
  routes(app);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(
        corsHeaders(
          headers: <String, String>{
            ACCESS_CONTROL_ALLOW_HEADERS: _corsAllowHeaders,
          },
        ),
      )
      .addMiddleware(withDbShelfMiddleware())
      .addHandler(app.call);

  final server = await io.serve(
    handler,
    address,
    port,
    shared: true,
  );

  server.autoCompress = true;
  server.defaultResponseHeaders.remove('X-Frame-Optioms', 'SAMEORIGIN');
  _log.info(
    'Nexus backend ouvindo em http://${server.address.host}:${server.port}${AppConfig.inst().basePath}',
  );
}

void _configurarLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord record) {
    stdout.writeln(
      '[${record.level.name}] ${record.time.toIso8601String()} ${record.loggerName}: ${record.message}',
    );
  });
}
