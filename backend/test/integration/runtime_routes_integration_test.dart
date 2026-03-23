import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:nexus_backend/src/modules/runtime/runtime_routes.dart';
import 'package:nexus_backend/src/modules/runtime/services/runtime_port.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Rotas de runtime', () {
    test('inicia sessao publicada e consulta estado atual', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<RuntimePort>(_RuntimePortFake());

      final iniciarResposta = await runtimeRoutes().call(
        Request(
          'POST',
          Uri.parse('http://localhost/runtime/sessoes'),
          body: jsonEncode(
            RequisicaoIniciarSessao(idServico: 'servico-1').toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(iniciarResposta.statusCode, equals(201));
      final iniciarCorpo = jsonDecode(await iniciarResposta.readAsString())
          as Map<String, dynamic>;
      expect(iniciarCorpo['id_sessao'], equals('sessao-1'));
      expect((iniciarCorpo['no_atual'] as Map<String, dynamic>)['id'],
          equals('no-inicial'));

      final estadoResposta = await runtimeRoutes().call(
        Request(
          'GET',
          Uri.parse('http://localhost/runtime/sessoes/sessao-1'),
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(estadoResposta.statusCode, equals(200));
      final estadoCorpo = jsonDecode(await estadoResposta.readAsString())
          as Map<String, dynamic>;
      expect(estadoCorpo['status'], equals('em_andamento'));
    });

    test('avanca sessao e devolve protocolo quando conclui', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<RuntimePort>(_RuntimePortFake());

      final resposta = await runtimeRoutes().call(
        Request(
          'POST',
          Uri.parse('http://localhost/runtime/sessoes/sessao-1/avancar'),
          body: jsonEncode(
            RequisicaoAvancarPasso(
              respostas: const <String, dynamic>{'cpf': '00000000000'},
            ).toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      expect(corpo['status'], equals('concluida'));
      expect(
          (corpo['registro_submissao']
              as Map<String, dynamic>)['numero_protocolo'],
          equals('202603220001'));
    });
  });
}

class _RuntimePortFake implements RuntimePort {
  @override
  Future<EstadoPassoRuntime> avancarPasso(
      String idSessao, Map<String, dynamic> respostas) async {
    return EstadoPassoRuntime(
      idSessao: idSessao,
      idServico: 'servico-1',
      idVersaoServico: 'versao-1',
      chaveFluxoAtual: 'inscricao',
      noAtual: NoFluxoDto(
        id: 'no-final',
        tipo: TipoNoFluxo.fim,
        posicao: PosicaoXY(x: 200, y: 80),
        dados: DadosNoFim(rotulo: 'Finalizacao'),
      ),
      status: StatusExecucao.concluida,
      contexto: ContextoExecucaoDto(respostas: respostas),
      registroSubmissao: RegistroSubmissao(
        id: 'submissao-1',
        idServico: 'servico-1',
        idVersaoServico: 'versao-1',
        numeroProtocolo: '202603220001',
        criadoEm: DateTime.utc(2026, 3, 22, 14),
        snapshot: <String, dynamic>{'respostas': respostas},
      ),
    );
  }

  @override
  Future<EstadoPassoRuntime> iniciarSessao(
    String idServico,
    String canal,
    Map<String, dynamic> contextoInicial,
  ) async {
    return EstadoPassoRuntime(
      idSessao: 'sessao-1',
      idServico: idServico,
      idVersaoServico: 'versao-1',
      chaveFluxoAtual: 'inscricao',
      noAtual: NoFluxoDto(
        id: 'no-inicial',
        tipo: TipoNoFluxo.apresentacao,
        posicao: PosicaoXY(x: 0, y: 0),
        dados: DadosNoApresentacao(
          rotulo: 'Boas-vindas',
          conteudoApresentacao: DocumentoConteudoRico(
            blocos: <BlocoConteudoRico>[
              BlocoConteudoRico(
                  tipo: 'paragrafo',
                  dados: <String, dynamic>{'texto': 'Inicio do fluxo'}),
            ],
          ),
        ),
      ),
      status: StatusExecucao.emAndamento,
      contexto: ContextoExecucaoDto(variaveis: contextoInicial),
    );
  }

  @override
  Future<EstadoPassoRuntime?> obterEstado(String idSessao) async {
    return EstadoPassoRuntime(
      idSessao: idSessao,
      idServico: 'servico-1',
      idVersaoServico: 'versao-1',
      chaveFluxoAtual: 'inscricao',
      noAtual: NoFluxoDto(
        id: 'no-inicial',
        tipo: TipoNoFluxo.apresentacao,
        posicao: PosicaoXY(x: 0, y: 0),
        dados: DadosNoApresentacao(
          rotulo: 'Boas-vindas',
          conteudoApresentacao: DocumentoConteudoRico(
            blocos: <BlocoConteudoRico>[
              BlocoConteudoRico(
                  tipo: 'paragrafo',
                  dados: <String, dynamic>{'texto': 'Inicio do fluxo'}),
            ],
          ),
        ),
      ),
      status: StatusExecucao.emAndamento,
      contexto: ContextoExecucaoDto(),
    );
  }
}
