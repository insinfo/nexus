import 'dart:convert';

import 'package:nexus_backend/src/di/dependency_injector.dart';
import 'package:nexus_backend/src/shared/db_middleware.dart';
import 'package:nexus_backend/src/shared/routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

void main() {
  group('Integração real com PostgreSQL seedado', () {
    late Handler handler;

    setUpAll(() {
      final app = Router();
      setupDependencies();
      routes(app);
      handler = Pipeline()
          .addMiddleware(withDbShelfMiddleware())
          .addHandler(app.call);
    });

    test('lista fila operacional seedada e resultados auditáveis reais',
        () async {
      final filaResposta = await handler(
        Request(
            'GET', Uri.parse('http://localhost/api/v1/operacao/submissoes')),
      );

      expect(filaResposta.statusCode, equals(200));
      final filaCorpo =
          jsonDecode(await filaResposta.readAsString()) as Map<String, dynamic>;
      expect((filaCorpo['totalRecords'] as int), greaterThanOrEqualTo(4));
      final filaItems =
          List<Map<String, dynamic>>.from(filaCorpo['items'] as List);
      expect(
        filaItems.any(
            (item) => item['codigo_servico'] == 'auxilio-emergencial-salus'),
        isTrue,
      );

      final classificacaoResposta = await handler(
        Request(
          'GET',
          Uri.parse(
              'http://localhost/api/v1/operacao/classificacao/auxilio-emergencial-salus/resultados'),
        ),
      );

      expect(classificacaoResposta.statusCode, equals(200));
      final classificacaoCorpo =
          jsonDecode(await classificacaoResposta.readAsString())
              as Map<String, dynamic>;
      expect(
          (classificacaoCorpo['totalRecords'] as int), greaterThanOrEqualTo(2));
      final resultadoItems =
          List<Map<String, dynamic>>.from(classificacaoCorpo['items'] as List);
      expect(resultadoItems.first['elegivel'], isTrue);
      expect(resultadoItems.any((item) => item['elegivel'] == false), isTrue);

      final protocoloResposta = await handler(
        Request('GET',
            Uri.parse('http://localhost/api/v1/protocolos/NEXUS-SALUS-003')),
      );

      expect(protocoloResposta.statusCode, equals(200));
      final protocoloCorpo = jsonDecode(await protocoloResposta.readAsString())
          as Map<String, dynamic>;
      expect(protocoloCorpo['status'], equals('homologada'));
      expect((protocoloCorpo['andamentos'] as List).isNotEmpty, isTrue);
    });
  });
}
