import 'package:nexus_backend/src/modules/editor_fluxos/services/validador_fluxo_service.dart';
import 'package:nexus_backend/src/modules/runtime/services/avaliador_condicao_service.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:test/test.dart';

void main() {
  group('ValidadorFluxoService', () {
    final service = ValidadorFluxoService(const AvaliadorCondicaoService());

    test('valida fluxo linear suportado', () {
      final resultado = service.validar(_criarFluxoValido());

      expect(resultado.valido, isTrue);
      expect(resultado.erros, isEmpty);
    });

    test('detecta no de condicao sem saida falsa', () {
      final fluxo = _criarFluxoValido().toMap();
      final arestas = List<Map<String, dynamic>>.from(fluxo['arestas'] as List);
      arestas.removeWhere((item) => item['handle_origem'] == 'false');
      fluxo['arestas'] = arestas;

      final resultado = service.validar(FluxoDto.fromMap(fluxo));

      expect(resultado.valido, isFalse);
      expect(
        resultado.erros
            .any((item) => item.codigo == 'condicao_saidas_invalidas'),
        isTrue,
      );
    });
  });
}

FluxoDto _criarFluxoValido() {
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
        id: 'formulario',
        tipo: TipoNoFluxo.formulario,
        posicao: PosicaoXY(x: 200, y: 0),
        dados: DadosNoFormulario(
          rotulo: 'Cadastro',
          perguntas: <DefinicaoPergunta>[
            DefinicaoPergunta(
              id: 'idade',
              campo: 'idade',
              rotulo: 'Idade',
              tipo: TipoCampoFormulario.inteiro,
              obrigatorio: true,
            ),
          ],
        ),
      ),
      NoFluxoDto(
        id: 'condicao',
        tipo: TipoNoFluxo.condicao,
        posicao: PosicaoXY(x: 300, y: 0),
        dados: DadosNoCondicao(
          rotulo: 'Elegivel?',
          expressao:
              '{"tipo":"comparacao","campo":"idade","operador":"gte","valor":18}',
        ),
      ),
      NoFluxoDto(
        id: 'conteudo',
        tipo: TipoNoFluxo.conteudoDinamico,
        posicao: PosicaoXY(x: 400, y: -60),
        dados: DadosNoConteudoDinamico(
          rotulo: 'Resultado positivo',
          metodo: 'GET',
          url: 'https://example.com',
          modeloConteudo: documento,
          finalizaFluxo: true,
        ),
      ),
      NoFluxoDto(
        id: 'fim',
        tipo: TipoNoFluxo.fim,
        posicao: PosicaoXY(x: 400, y: 60),
        dados: DadosNoFim(rotulo: 'Fim'),
      ),
    ],
    arestas: <ArestaFluxoDto>[
      ArestaFluxoDto(id: 'a1', origem: 'inicio', destino: 'apresentacao'),
      ArestaFluxoDto(id: 'a2', origem: 'apresentacao', destino: 'formulario'),
      ArestaFluxoDto(id: 'a3', origem: 'formulario', destino: 'condicao'),
      ArestaFluxoDto(
          id: 'a4',
          origem: 'condicao',
          destino: 'conteudo',
          handleOrigem: 'true'),
      ArestaFluxoDto(
          id: 'a5', origem: 'condicao', destino: 'fim', handleOrigem: 'false'),
    ],
  );
}
