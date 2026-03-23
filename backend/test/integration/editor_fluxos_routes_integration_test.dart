import 'dart:convert';

import 'package:nexus_backend/src/di/dependency_injector.dart';
import 'package:nexus_backend/src/shared/routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

void main() {
  group('Rotas de editor de fluxos', () {
    setUpAll(setupDependencies);

    test('valida fluxo valido no caminho montado da API', () async {
      final app = Router();
      routes(app);

      final resposta = await app.call(
        Request(
          'POST',
          Uri.parse('http://localhost/api/v1/editor/fluxos/validar'),
          body: jsonEncode(_payloadFluxoValido()),
          headers: const <String, String>{'content-type': 'application/json'},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      expect(corpo['valido'], isTrue);
    });

    test('pre-visualiza proximo no com condicao falsa', () async {
      final app = Router();
      routes(app);

      final resposta = await app.call(
        Request(
          'POST',
          Uri.parse('http://localhost/api/v1/editor/fluxos/pre-visualizar'),
          body: jsonEncode(<String, dynamic>{
            'fluxo': _payloadFluxoValido(),
            'id_no_atual': 'condicao',
            'contexto': <String, dynamic>{
              'respostas': <String, dynamic>{'idade': 15},
            },
          }),
          headers: const <String, String>{'content-type': 'application/json'},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      final noAtual = Map<String, dynamic>.from(corpo['no_atual'] as Map);
      expect(noAtual['id'], equals('fim'));
      expect(corpo['status'], equals('concluida'));
    });
  });
}

Map<String, dynamic> _payloadFluxoValido() {
  return <String, dynamic>{
    'id': 'fluxo-beneficio',
    'chave': 'beneficio-social',
    'tipo': 'entrada_dados',
    'nos': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'inicio',
        'tipo': 'inicio',
        'posicao': <String, dynamic>{'x': 0, 'y': 0},
        'dados': <String, dynamic>{'rotulo': 'Inicio'},
      },
      <String, dynamic>{
        'id': 'apresentacao',
        'tipo': 'apresentacao',
        'posicao': <String, dynamic>{'x': 100, 'y': 0},
        'dados': <String, dynamic>{
          'rotulo': 'Apresentacao',
          'conteudo_apresentacao': <String, dynamic>{
            'blocos': <Map<String, dynamic>>[
              <String, dynamic>{
                'tipo': 'paragrafo',
                'dados': <String, dynamic>{'texto': 'Conteudo'},
              },
            ],
          },
        },
      },
      <String, dynamic>{
        'id': 'condicao',
        'tipo': 'condicao',
        'posicao': <String, dynamic>{'x': 200, 'y': 0},
        'dados': <String, dynamic>{
          'rotulo': 'Elegivel?',
          'expressao':
              '{"tipo":"comparacao","campo":"idade","operador":"gte","valor":18}',
          'handle_verdadeiro': 'true',
          'handle_falso': 'false',
        },
      },
      <String, dynamic>{
        'id': 'conteudo',
        'tipo': 'conteudo_dinamico',
        'posicao': <String, dynamic>{'x': 300, 'y': 0},
        'dados': <String, dynamic>{
          'rotulo': 'Resultado positivo',
          'metodo': 'GET',
          'url': 'https://example.com',
          'finaliza_fluxo': true,
          'modelo_conteudo': <String, dynamic>{
            'blocos': <Map<String, dynamic>>[
              <String, dynamic>{
                'tipo': 'paragrafo',
                'dados': <String, dynamic>{'texto': 'Conteudo'},
              },
            ],
          },
        },
      },
      <String, dynamic>{
        'id': 'fim',
        'tipo': 'fim',
        'posicao': <String, dynamic>{'x': 300, 'y': 80},
        'dados': <String, dynamic>{'rotulo': 'Fim'},
      },
    ],
    'arestas': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'a1',
        'origem': 'inicio',
        'destino': 'apresentacao'
      },
      <String, dynamic>{
        'id': 'a2',
        'origem': 'apresentacao',
        'destino': 'condicao'
      },
      <String, dynamic>{
        'id': 'a3',
        'origem': 'condicao',
        'destino': 'conteudo',
        'handle_origem': 'true'
      },
      <String, dynamic>{
        'id': 'a4',
        'origem': 'condicao',
        'destino': 'fim',
        'handle_origem': 'false'
      },
    ],
  };
}
