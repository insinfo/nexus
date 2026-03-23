import 'dart:convert';

import 'package:essential_core/essential_core.dart';
import 'package:get_it/get_it.dart';
import 'package:nexus_backend/src/modules/operacao/operacao_routes.dart';
import 'package:nexus_backend/src/modules/operacao/services/operacao_port.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Rotas de operação institucional', () {
    test('lista fila operacional em DataFrame', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<OperacaoPort>(_OperacaoPortFake());

      final resposta = await operacaoRoutes().call(
        Request(
          'GET',
          Uri.parse('http://localhost/operacao/submissoes'),
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      expect(corpo['totalRecords'], equals(1));
      final item = (corpo['items'] as List).first as Map<String, dynamic>;
      expect(item['numero_protocolo'], equals('202603220001'));
      expect(item['possui_tarefa_aberta'], isTrue);
    });

    test('transiciona submissão operacional', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<OperacaoPort>(_OperacaoPortFake());

      final resposta = await operacaoRoutes().call(
        Request(
          'POST',
          Uri.parse('http://localhost/operacao/submissoes/transicionar'),
          body: jsonEncode(
            RequisicaoTransicaoSubmissao(
              idSubmissao: 'submissao-1',
              novoStatus: 'em_analise',
              motivo: 'Triagem institucional iniciada.',
            ).toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      expect(corpo['status'], equals('em_analise'));
    });

    test('executa classificação auditável e lista resultados', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<OperacaoPort>(_OperacaoPortFake());

      final respostaExecucao = await operacaoRoutes().call(
        Request(
          'POST',
          Uri.parse('http://localhost/operacao/classificacao/executar'),
          body: jsonEncode(
            RequisicaoExecutarClassificacao(idServico: 'servico-1').toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(respostaExecucao.statusCode, equals(201));
      final corpoExecucao = jsonDecode(await respostaExecucao.readAsString())
          as Map<String, dynamic>;
      expect(corpoExecucao['status'], equals('concluida'));

      final respostaResultados = await operacaoRoutes().call(
        Request(
          'GET',
          Uri.parse(
              'http://localhost/operacao/classificacao/servico-1/resultados'),
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(respostaResultados.statusCode, equals(200));
      final corpoResultados =
          jsonDecode(await respostaResultados.readAsString())
              as Map<String, dynamic>;
      expect(corpoResultados['totalRecords'], equals(1));
      final primeiro =
          (corpoResultados['items'] as List).first as Map<String, dynamic>;
      expect(primeiro['pontuacao_final'], equals(87.5));
      expect(primeiro['elegivel'], isTrue);
    });
  });
}

class _OperacaoPortFake implements OperacaoPort {
  @override
  Future<Map<String, dynamic>?> detalharSubmissao(String idSubmissao) async {
    return <String, dynamic>{
      'submissao': _resumo('submetida').toMap(),
      'tarefas': <Map<String, dynamic>>[
        <String, dynamic>{'titulo': 'Analisar submissão', 'status': 'aberta'},
      ],
      'historico_status': <Map<String, dynamic>>[
        <String, dynamic>{'novo_status': 'submetida'},
      ],
      'resultado_classificacao': null,
    };
  }

  @override
  Future<ResumoExecucaoClassificacao> executarClassificacao(
    RequisicaoExecutarClassificacao requisicao,
  ) async {
    return ResumoExecucaoClassificacao(
      idExecucao: 'execucao-1',
      idServico: requisicao.idServico,
      idVersaoServico: 'versao-1',
      idVersaoConjuntoRegras: 'regras-1',
      status: 'concluida',
      quantidadeProcessada: 1,
      iniciadoEm: DateTime.utc(2026, 3, 22, 10),
      finalizadoEm: DateTime.utc(2026, 3, 22, 10, 1),
      notas: requisicao.notas,
    );
  }

  @override
  Future<DataFrame<ResumoResultadoClassificacao>> listarResultadosClassificacao(
    String idServico,
  ) async {
    return DataFrame<ResumoResultadoClassificacao>(
      items: <ResumoResultadoClassificacao>[
        ResumoResultadoClassificacao(
          idSubmissao: 'submissao-1',
          numeroProtocolo: '202603220001',
          codigoPublico: 'NEXUS-ABC-123',
          nomeServico: 'Auxilio emergencial',
          pontuacaoFinal: 87.5,
          posicaoFinal: 1,
          elegivel: true,
          justificativa: const <String, dynamic>{
            'pontuacoes_aplicadas': <dynamic>[]
          },
        ),
      ],
      totalRecords: 1,
    );
  }

  @override
  Future<DataFrame<ResumoSubmissaoOperacao>> listarSubmissoes() async {
    return DataFrame<ResumoSubmissaoOperacao>(
      items: <ResumoSubmissaoOperacao>[
        _resumo('submetida'),
      ],
      totalRecords: 1,
    );
  }

  @override
  Future<ResumoSubmissaoOperacao> transicionarSubmissao(
    RequisicaoTransicaoSubmissao requisicao,
  ) async {
    return _resumo(requisicao.novoStatus);
  }

  ResumoSubmissaoOperacao _resumo(String status) {
    return ResumoSubmissaoOperacao(
      idSubmissao: 'submissao-1',
      idServico: 'servico-1',
      codigoServico: 'SALUS-AUXILIO',
      nomeServico: 'Auxilio emergencial',
      numeroProtocolo: '202603220001',
      codigoPublico: 'NEXUS-ABC-123',
      status: status,
      criadoEm: DateTime.utc(2026, 3, 22, 14),
      atualizadoEm: DateTime.utc(2026, 3, 22, 15),
      pontuacaoFinal: 87.5,
      posicaoFinal: 1,
      elegivel: true,
      possuiTarefaAberta: true,
    );
  }
}
