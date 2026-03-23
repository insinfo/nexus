import 'dart:convert';

import 'package:nexus_backend/src/shared/routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

void main() {
  group('Rotas de health', () {
    test('responde status ok no caminho montado da API', () async {
      final app = Router();
      routes(app);

      final resposta = await app.call(
        Request('GET', Uri.parse('http://localhost/api/v1/health')),
      );

      expect(resposta.statusCode, equals(200));
      expect(
        resposta.headers['content-type'],
        contains('application/json'),
      );

      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      expect(corpo, containsPair('status', 'ok'));
    });
  });
}
