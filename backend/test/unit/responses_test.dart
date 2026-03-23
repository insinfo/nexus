import 'dart:convert';

import 'package:essential_core/essential_core.dart';
import 'package:nexus_backend/src/shared/responses.dart';
import 'package:test/test.dart';

void main() {
  group('responseDataFrame', () {
    test('serializa items e totalRecords com header padronizado', () async {
      final data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'nome': 'Teste'},
        ],
        totalRecords: 10,
      );

      final resposta = responseDataFrame(data);
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;

      expect(resposta.statusCode, equals(200));
      expect(resposta.headers['total-records'], equals('10'));
      expect(corpo['totalRecords'], equals(10));
      expect(corpo['items'], hasLength(1));
      expect((corpo['items'] as List).first, containsPair('nome', 'Teste'));
    });
  });
}
