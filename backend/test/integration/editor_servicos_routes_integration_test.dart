import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:nexus_backend/src/modules/editor_servicos/editor_servicos_routes.dart';
import 'package:nexus_backend/src/modules/editor_servicos/services/editor_servicos_port.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Rotas de editor de servicos', () {
    test('salva rascunho com formulario completo do builder', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<EditorServicosPort>(_EditorServicosPortFake());

      final servico = ServicoDto(
        id: 'servico-builder',
        codigo: 'SERVICO-BUILDER',
        metadados: MetadadosServicoDto(
          nome: 'Servico Builder',
          descricao: 'Servico para validar persistencia estrutural do builder.',
          categoria: 'teste',
          canais: <CanalServico>[CanalServico.portalCidadao],
          modoAcesso: ModoAcesso.publicoAnonimo,
        ),
        versoes: <VersaoServicoDto>[
          VersaoServicoDto(
            id: 'versao-builder',
            versao: 1,
            status: StatusVersaoServico.rascunho,
            criadoEm: DateTime.utc(2026, 3, 22),
            fluxos: <FluxoDto>[
              FluxoDto(
                id: 'fluxo-builder',
                chave: 'inscricao',
                tipo: TipoFluxo.entradaDados,
                nos: <NoFluxoDto>[
                  NoFluxoDto(
                    id: 'no-formulario',
                    tipo: TipoNoFluxo.formulario,
                    posicao: PosicaoXY(x: 120, y: 80),
                    dados: DadosNoFormulario(
                      rotulo: 'Formulario principal',
                      secoes: <SecaoFormularioDto>[
                        SecaoFormularioDto(
                          id: 'secao-identificacao',
                          chave: 'identificacao',
                          titulo: 'Identificacao',
                          ordem: 0,
                        ),
                      ],
                      perguntas: <DefinicaoPergunta>[
                        DefinicaoPergunta(
                          id: 'cpf',
                          campo: 'cpf',
                          rotulo: 'CPF',
                          tipo: TipoCampoFormulario.cpf,
                          idSecao: 'secao-identificacao',
                          obrigatorio: true,
                          validacoes: <ValidacaoCampo>[
                            ValidacaoCampo(
                              tipo: 'regex',
                              configuracao: const <String, dynamic>{
                                'expressao': r'^\\d{11}$'
                              },
                              mensagem: 'Informe 11 digitos.',
                            ),
                          ],
                          regrasVisibilidade: <RegraVisibilidadeFormulario>[
                            RegraVisibilidadeFormulario(
                              expressao: const <String, dynamic>{
                                'campo': 'tipo_pessoa',
                                'operador': 'igual',
                                'valor': 'fisica'
                              },
                            ),
                          ],
                          calculos: <CalculoCampo>[
                            CalculoCampo(
                              expressao: const <String, dynamic>{
                                'operacao': 'copiar',
                                'origem': 'cpf'
                              },
                              escopoDestino: 'contexto',
                            ),
                          ],
                        ),
                        DefinicaoPergunta(
                          id: 'tipo_pessoa',
                          campo: 'tipo_pessoa',
                          rotulo: 'Tipo de pessoa',
                          tipo: TipoCampoFormulario.selecao,
                          opcoes: <OpcaoCampo>[
                            OpcaoCampo(valor: 'fisica', rotulo: 'Fisica'),
                            OpcaoCampo(
                                valor: 'juridica',
                                rotulo: 'Juridica',
                                ordem: 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                arestas: <ArestaFluxoDto>[],
              ),
            ],
          ),
        ],
        criadoEm: DateTime.utc(2026, 3, 22),
        atualizadoEm: DateTime.utc(2026, 3, 22),
      );

      final resposta = await editorServicosRoutes().call(
        Request(
          'POST',
          Uri.parse('http://localhost/editor/servicos/salvar-rascunho'),
          body: jsonEncode(
            RequisicaoSalvarRascunhoServico(
              servico: servico,
              idVersao: 'versao-builder',
            ).toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      final versao = (corpo['versoes'] as List).first as Map<String, dynamic>;
      final fluxo = (versao['fluxos'] as List).first as Map<String, dynamic>;
      final noFormulario = (fluxo['nos'] as List).first as Map<String, dynamic>;
      final dadosFormulario = noFormulario['dados'] as Map<String, dynamic>;
      final perguntas = dadosFormulario['perguntas'] as List<dynamic>;
      final cpf = perguntas.first as Map<String, dynamic>;

      expect((dadosFormulario['secoes'] as List).length, equals(1));
      expect((cpf['validacoes'] as List).length, equals(1));
      expect((cpf['regras_visibilidade'] as List).length, equals(1));
      expect((cpf['calculos'] as List).length, equals(1));
      expect(
          (((perguntas[1] as Map<String, dynamic>)['opcoes']) as List).length,
          equals(2));
    });

    test('publica versao em rascunho', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<EditorServicosPort>(_EditorServicosPortFake());

      final resposta = await editorServicosRoutes().call(
        Request(
          'POST',
          Uri.parse('http://localhost/editor/servicos/publicar-versao'),
          body: jsonEncode(
            RequisicaoPublicarVersaoServico(
              idServico: 'servico-1',
              idVersao: 'versao-1',
            ).toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      final versoes = List<Map<String, dynamic>>.from(corpo['versoes'] as List);
      expect(versoes.first['status'], equals('publicada'));
    });
  });
}

class _EditorServicosPortFake implements EditorServicosPort {
  @override
  Future<ServicoDto> publicarVersao(
    RequisicaoPublicarVersaoServico requisicao,
  ) async {
    return ServicoDto(
      id: requisicao.idServico,
      codigo: 'SERVICO-TESTE',
      metadados: MetadadosServicoDto(
        nome: 'Servico teste',
        descricao: 'Servico para validar publicacao.',
        categoria: 'teste',
        canais: <CanalServico>[CanalServico.portalCidadao],
        modoAcesso: ModoAcesso.publicoAnonimo,
      ),
      versoes: <VersaoServicoDto>[
        VersaoServicoDto(
          id: requisicao.idVersao,
          versao: 1,
          status: StatusVersaoServico.publicada,
          criadoEm: DateTime.utc(2026, 3, 22),
        ),
      ],
      criadoEm: DateTime.utc(2026, 3, 22),
      atualizadoEm: DateTime.utc(2026, 3, 22),
    );
  }

  @override
  Future<ServicoDto> salvarRascunho(
    RequisicaoSalvarRascunhoServico requisicao,
  ) async {
    return requisicao.servico;
  }
}
