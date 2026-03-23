import 'dart:io';

import 'package:nexus_backend/src/modules/editor_fluxos/services/pre_visualizacao_fluxo_service.dart';
import 'package:nexus_backend/src/modules/editor_fluxos/services/resolvedor_conteudo_dinamico_preview_service.dart';
import 'package:nexus_backend/src/modules/editor_fluxos/services/validador_fluxo_service.dart';
import 'package:nexus_backend/src/modules/runtime/services/avaliador_condicao_service.dart';
import 'package:nexus_backend/src/modules/runtime/services/executor_conteudo_dinamico_service.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_test_handler/shelf_test_handler.dart';
import 'package:test/test.dart';

void main() {
  group('PreVisualizacaoFluxoService', () {
    final avaliador = const AvaliadorCondicaoService();
    late ShelfTestServer servidor;
    late PreVisualizacaoFluxoService service;

    setUp(() async {
      servidor = await ShelfTestServer.create();
      service = PreVisualizacaoFluxoService(
        ValidadorFluxoService(avaliador),
        avaliador,
        const ResolvedorConteudoDinamicoPreviewService(
          ExecutorConteudoDinamicoService(),
        ),
      );
    });

    tearDown(() async {
      await servidor.close();
    });

    test('retorna primeiro no util ao iniciar preview', () async {
      final resultado = await service.preVisualizar(
        RequisicaoPreVisualizacaoFluxo(fluxo: _criarFluxoValido()),
      );

      expect(resultado.noAtual.id, equals('apresentacao'));
      expect(resultado.status, equals(StatusExecucao.emAndamento));
    });

    test('avanca para conteudo dinamico finalizando o fluxo', () async {
      servidor.handler.expect('GET', '/conteudo/20', (request) async {
        return shelf.Response.ok(
          '{"mensagem":"ok"}',
          headers: const <String, String>{'content-type': 'application/json'},
        );
      });

      final resultado = await service.preVisualizar(
        RequisicaoPreVisualizacaoFluxo(
          fluxo: _criarFluxoValido(
              urlConteudo: '${servidor.url}/conteudo/{{respostas.idade}}'),
          idNoAtual: 'condicao',
          contexto: const <String, dynamic>{
            'respostas': <String, dynamic>{'idade': 20},
          },
        ),
      );

      expect(resultado.noAtual.id, equals('conteudo'));
      expect(resultado.status, equals(StatusExecucao.concluida));
      final resultadosIntegracao = Map<String, dynamic>.from(
        resultado.contexto['resultados_integracao'] as Map,
      );
      final conteudo =
          Map<String, dynamic>.from(resultadosIntegracao['conteudo'] as Map);
      expect(conteudo['status_code'], HttpStatus.ok);
      expect(conteudo['sucesso'], isTrue);
      expect(
        Map<String, dynamic>.from(conteudo['corpo'] as Map),
        containsPair('mensagem', 'ok'),
      );
    });
  });
}

FluxoDto _criarFluxoValido({
  String urlConteudo = 'https://example.com',
}) {
  final documento = DocumentoConteudoRico(
    blocos: <BlocoConteudoRico>[
      BlocoConteudoRico(
          tipo: 'paragrafo', dados: <String, dynamic>{'texto': 'Conteudo'}),
    ],
  );

  return FluxoDto(
    id: 'fluxo-beneficio',
    chave: 'beneficio-social',
    tipo: TipoFluxo.entradaDados,
    nos: <NoFluxoDto>[
      NoFluxoDto(
        id: 'inicio',
        tipo: TipoNoFluxo.inicio,
        posicao: PosicaoXY(x: 0, y: 0),
        dados: DadosNoInicio(rotulo: 'Inicio'),
      ),
      NoFluxoDto(
        id: 'apresentacao',
        tipo: TipoNoFluxo.apresentacao,
        posicao: PosicaoXY(x: 100, y: 0),
        dados: DadosNoApresentacao(
          rotulo: 'Apresentacao',
          conteudoApresentacao: documento,
        ),
      ),
      NoFluxoDto(
        id: 'condicao',
        tipo: TipoNoFluxo.condicao,
        posicao: PosicaoXY(x: 200, y: 0),
        dados: DadosNoCondicao(
          rotulo: 'Elegivel?',
          expressao:
              '{"tipo":"comparacao","campo":"idade","operador":"gte","valor":18}',
        ),
      ),
      NoFluxoDto(
        id: 'conteudo',
        tipo: TipoNoFluxo.conteudoDinamico,
        posicao: PosicaoXY(x: 300, y: 0),
        dados: DadosNoConteudoDinamico(
          rotulo: 'Resultado positivo',
          metodo: 'GET',
          url: urlConteudo,
          modeloConteudo: documento,
          finalizaFluxo: true,
        ),
      ),
      NoFluxoDto(
        id: 'fim',
        tipo: TipoNoFluxo.fim,
        posicao: PosicaoXY(x: 300, y: 80),
        dados: DadosNoFim(rotulo: 'Fim'),
      ),
    ],
    arestas: <ArestaFluxoDto>[
      ArestaFluxoDto(id: 'a1', origem: 'inicio', destino: 'apresentacao'),
      ArestaFluxoDto(id: 'a2', origem: 'apresentacao', destino: 'condicao'),
      ArestaFluxoDto(
          id: 'a3',
          origem: 'condicao',
          destino: 'conteudo',
          handleOrigem: 'true'),
      ArestaFluxoDto(
          id: 'a4', origem: 'condicao', destino: 'fim', handleOrigem: 'false'),
    ],
  );
}
