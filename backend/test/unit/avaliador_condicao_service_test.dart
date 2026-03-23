import 'dart:convert';

import 'package:nexus_backend/src/modules/runtime/services/avaliador_condicao_service.dart';
import 'package:test/test.dart';

void main() {
  group('AvaliadorCondicaoService', () {
    const service = AvaliadorCondicaoService();

    test('avalia comparacao simples de igualdade', () {
      final expressao = jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'faixa',
        'operador': 'eq',
        'valor': 'social',
      });

      final resultado = service.avaliarExpressaoJson(
        expressao,
        <String, dynamic>{'faixa': 'social'},
      );

      expect(resultado, isTrue);
    });

    test('avalia operadores compostos e numericos', () {
      final expressao = jsonEncode(<String, dynamic>{
        'tipo': 'e',
        'regras': <Map<String, dynamic>>[
          <String, dynamic>{
            'tipo': 'comparacao',
            'campo': 'idade',
            'operador': 'gte',
            'valor': 18,
          },
          <String, dynamic>{
            'tipo': 'ou',
            'regras': <Map<String, dynamic>>[
              <String, dynamic>{
                'tipo': 'comparacao',
                'campo': 'renda',
                'operador': 'lt',
                'valor': 3000,
              },
              <String, dynamic>{
                'tipo': 'comparacao',
                'campo': 'cadunico',
                'operador': 'eq',
                'valor': true,
              },
            ],
          },
        ],
      });

      final resultado = service.avaliarExpressaoJson(
        expressao,
        <String, dynamic>{
          'idade': 22,
          'renda': 2500,
          'cadunico': false,
        },
      );

      expect(resultado, isTrue);
    });

    test('identifica expressao invalida', () {
      expect(service.expressaoJsonValida('{invalido'), isFalse);
    });
  });
}
