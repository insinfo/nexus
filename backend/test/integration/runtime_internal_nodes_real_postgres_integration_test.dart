import 'dart:convert';

import 'package:eloquent/eloquent.dart';
import 'package:nexus_backend/src/di/dependency_injector.dart';
import 'package:nexus_backend/src/shared/db_middleware.dart';
import 'package:nexus_backend/src/shared/db_service.dart';
import 'package:nexus_backend/src/shared/extensions/eloquent.dart';
import 'package:nexus_backend/src/shared/routes.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

class _AmbienteFluxoInterno {
  const _AmbienteFluxoInterno({
    required this.idServico,
    required this.codigoServico,
  });

  final int idServico;
  final String codigoServico;
}

void main() {
  group('Integração real do runtime com nós internos', () {
    late Handler handler;
    late Connection db;

    setUpAll(() async {
      final app = Router();
      setupDependencies();
      routes(app);
      handler = Pipeline()
          .addMiddleware(withDbShelfMiddleware())
          .addHandler(app.call);
      db = await ioc.get<DatabaseService>().connect();
    });

    test(
        'executa tarefa interna, status, pontuação e classificação no mesmo fluxo',
        () async {
      final codigoServico =
          'runtime-interno-${DateTime.now().millisecondsSinceEpoch}';
      final ambiente = await _criarServicoFluxoInterno(db, codigoServico);
      addTearDown(() async {
        await _limparServicoFluxoInterno(db, ambiente.idServico);
      });

      final iniciarResposta = await handler(
        Request(
          'POST',
          Uri.parse('http://localhost/api/v1/runtime/sessoes'),
          body: jsonEncode(
            RequisicaoIniciarSessao(
              idServico: ambiente.codigoServico,
              contextoInicial: <String, dynamic>{
                'renda_familiar': 1200,
                'prioridade_social': true,
              },
            ).toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
        ),
      );

      expect(iniciarResposta.statusCode, equals(201));
      final iniciarCorpo = jsonDecode(await iniciarResposta.readAsString())
          as Map<String, dynamic>;
      expect(iniciarCorpo['status'], equals('em_andamento'));
      expect(
        (iniciarCorpo['no_atual'] as Map<String, dynamic>)['tipo'],
        equals(TipoNoFluxo.apresentacao.val),
      );

      final sessaoId = iniciarCorpo['id_sessao'] as String;
      final avancarResposta = await handler(
        Request(
          'POST',
          Uri.parse(
              'http://localhost/api/v1/runtime/sessoes/$sessaoId/avancar'),
          body: jsonEncode(
            RequisicaoAvancarPasso(respostas: const <String, dynamic>{})
                .toMap(),
          ),
          headers: const <String, String>{'content-type': 'application/json'},
        ),
      );

      expect(avancarResposta.statusCode, equals(200));
      final avancarCorpo = jsonDecode(await avancarResposta.readAsString())
          as Map<String, dynamic>;
      expect(avancarCorpo['status'], equals('concluida'));
      final registro =
          Map<String, dynamic>.from(avancarCorpo['registro_submissao'] as Map);
      expect(registro['numero_protocolo'], isNotEmpty);

      final contexto =
          Map<String, dynamic>.from(avancarCorpo['contexto'] as Map);
      final contextoEdicao = Map<String, dynamic>.from(
          contexto['contexto_edicao'] as Map? ?? <String, dynamic>{});
      expect(contextoEdicao.containsKey('pontuacao'), isTrue);
      expect(contextoEdicao.containsKey('classificacao'), isTrue);
      final pontuacao =
          Map<String, dynamic>.from(contextoEdicao['pontuacao'] as Map);
      expect(pontuacao['elegivel'], isTrue);
      expect((pontuacao['pontuacao_final'] as num).toDouble(), equals(25));

      final protocoloResposta = await handler(
        Request(
          'GET',
          Uri.parse(
              'http://localhost/api/v1/protocolos/${registro['numero_protocolo']}'),
        ),
      );

      expect(protocoloResposta.statusCode, equals(200));
      final protocoloCorpo = jsonDecode(await protocoloResposta.readAsString())
          as Map<String, dynamic>;
      expect(protocoloCorpo['status'], equals('ranqueada'));
      expect((protocoloCorpo['andamentos'] as List).length,
          greaterThanOrEqualTo(2));

      final rowSubmissao = await db
          .table(Submissao.fqtn)
          .select([Submissao.idFqCol])
          .join(
            Protocolo.fqtn,
            Protocolo.idSubmissaoFqCol,
            '=',
            Submissao.idFqCol,
          )
          .where(Protocolo.numeroProtocoloFqCol, Operator.equal,
              registro['numero_protocolo'])
          .first();
      expect(rowSubmissao, isNotNull);
      final idSubmissao = rowSubmissao![Submissao.idCol] as int;

      final tarefas = await db
          .table(TarefaInterna.fqtn)
          .where(TarefaInterna.idSubmissaoCol, Operator.equal, idSubmissao)
          .get();
      expect(tarefas.length, equals(1));
      expect(tarefas.first[TarefaInterna.statusCol], equals('aberta'));

      final historico = await db
          .table(HistoricoStatusSubmissao.fqtn)
          .where(HistoricoStatusSubmissao.idSubmissaoCol, Operator.equal,
              idSubmissao)
          .orderBy(HistoricoStatusSubmissao.idCol, OrderDir.asc)
          .get();
      final novosStatus = historico
          .map((item) => item[HistoricoStatusSubmissao.novoStatusCol] as String)
          .toList(growable: false);
      expect(novosStatus, contains('em_analise'));
      expect(novosStatus, contains('ranqueada'));

      final resultados = await db
          .table(ResultadoClassificacao.fqtn)
          .where(ResultadoClassificacao.idSubmissaoCol, Operator.equal,
              idSubmissao)
          .get();
      expect(resultados.length, equals(1));
      expect(resultados.first[ResultadoClassificacao.elegivelCol], isTrue);
    });
  });
}

Future<_AmbienteFluxoInterno> _criarServicoFluxoInterno(
  Connection db,
  String codigoServico,
) async {
  final idServico = await db.table(Servico.fqtn).insertGetId(
        Servico(
          id: 0,
          codigo: codigoServico,
          nome: 'Serviço de runtime interno',
          slug: codigoServico,
          descricao:
              'Fluxo real de teste para runtime com operação institucional.',
          modoAcesso: 'publico_anonimo',
        ).toInsertMap(),
        Servico.idCol,
      ) as int;

  final idVersaoServico = await db.table(VersaoServico.fqtn).insertGetId(
        VersaoServico(
          id: 0,
          idServico: idServico,
          numeroVersao: 1,
          status: StatusVersaoServico.publicada.val,
          notas: 'Versão de teste para runtime com nós internos.',
        ).toInsertMap(),
        VersaoServico.idCol,
      ) as int;

  await db.table(CanalVersaoServico.fqtn).insert(
        CanalVersaoServico(
          id: 0,
          idVersaoServico: idVersaoServico,
          canal: 'portal_cidadao',
          visivel: true,
          configuracaoJson: '{}',
        ).toInsertMap(),
      );

  final idFluxo = await db.table(DefinicaoFluxo.fqtn).insertGetId(
        DefinicaoFluxo(
          id: 0,
          idVersaoServico: idVersaoServico,
          chaveFluxo: 'entrada_principal',
          tipoFluxo: 'entrada_dados',
          titulo: 'Fluxo principal',
          pontoEntrada: true,
        ).toInsertMap(),
        DefinicaoFluxo.idCol,
      ) as int;

  final idInicio = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'inicio_1',
      tipoNo: 'inicio',
      rotulo: 'Início',
      posicaoX: 0,
      posicaoY: 0,
      dadosJson: jsonEncode(DadosNoInicio(rotulo: 'Início').toMap()),
    ),
  );
  final idApresentacao = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'apresentacao_1',
      tipoNo: 'apresentacao',
      rotulo: 'Boas-vindas',
      posicaoX: 240,
      posicaoY: 0,
      dadosJson: jsonEncode(
        DadosNoApresentacao(
          rotulo: 'Boas-vindas',
          conteudoApresentacao: DocumentoConteudoRico(
            blocos: <BlocoConteudoRico>[
              BlocoConteudoRico(
                tipo: 'paragrafo',
                dados: <String, dynamic>{
                  'texto': 'Fluxo de teste com operação institucional.'
                },
              ),
            ],
          ),
        ).toMap(),
      ),
    ),
  );
  final idTarefa = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'tarefa_1',
      tipoNo: 'tarefa_interna',
      rotulo: 'Criar tarefa',
      posicaoX: 480,
      posicaoY: 0,
      dadosJson: jsonEncode(
        DadosNoTarefaInterna(
          rotulo: 'Criar tarefa',
          titulo: 'Analisar documentação',
          descricao: 'Tarefa criada automaticamente pelo runtime no teste.',
          prioridade: 'alta',
        ).toMap(),
      ),
    ),
  );
  final idStatus = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'status_1',
      tipoNo: 'atualizacao_status',
      rotulo: 'Colocar em análise',
      posicaoX: 720,
      posicaoY: 0,
      dadosJson: jsonEncode(
        DadosNoAtualizacaoStatus(
          rotulo: 'Colocar em análise',
          novoStatus: 'em_analise',
          motivo: 'Triagem iniciada automaticamente no fluxo.',
        ).toMap(),
      ),
    ),
  );
  final idPontuacao = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'pontuacao_1',
      tipoNo: 'pontuacao',
      rotulo: 'Pontuar submissão',
      posicaoX: 960,
      posicaoY: 0,
      dadosJson: jsonEncode(
        DadosNoPontuacao(
          rotulo: 'Pontuar submissão',
          chaveResultado: 'pontuacao',
        ).toMap(),
      ),
    ),
  );
  final idClassificacao = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'classificacao_1',
      tipoNo: 'classificacao',
      rotulo: 'Classificar',
      posicaoX: 1200,
      posicaoY: 0,
      dadosJson: jsonEncode(
        DadosNoClassificacao(
          rotulo: 'Classificar',
          notas: 'Execução automática do teste de integração.',
        ).toMap(),
      ),
    ),
  );
  final idFim = await _inserirNo(
    db,
    NoFluxo(
      id: 0,
      idDefinicaoFluxo: idFluxo,
      chaveNo: 'fim_1',
      tipoNo: 'fim',
      rotulo: 'Concluir',
      posicaoX: 1440,
      posicaoY: 0,
      dadosJson: jsonEncode(DadosNoFim(rotulo: 'Concluir').toMap()),
    ),
  );

  await _inserirAresta(
      db, idFluxo, 'aresta_inicio_apresentacao', idInicio, idApresentacao);
  await _inserirAresta(
      db, idFluxo, 'aresta_apresentacao_tarefa', idApresentacao, idTarefa);
  await _inserirAresta(db, idFluxo, 'aresta_tarefa_status', idTarefa, idStatus);
  await _inserirAresta(
      db, idFluxo, 'aresta_status_pontuacao', idStatus, idPontuacao);
  await _inserirAresta(db, idFluxo, 'aresta_pontuacao_classificacao',
      idPontuacao, idClassificacao);
  await _inserirAresta(
      db, idFluxo, 'aresta_classificacao_fim', idClassificacao, idFim);

  final idConjuntoRegras =
      await db.table('public.conjuntos_regras').insertGetId(
    <String, dynamic>{
      'id_servico': idServico,
      'codigo': 'regras-runtime',
      'nome': 'Regras do runtime',
      'descricao': 'Conjunto usado pelo teste de integração do runtime.',
      'ativo': true,
    },
    'id',
  ) as int;

  final idVersaoConjuntoRegras =
      await db.table(VersaoConjuntoRegras.fqtn).insertGetId(
            VersaoConjuntoRegras(
              id: 0,
              idConjuntoRegras: idConjuntoRegras,
              numeroVersao: 1,
              status: StatusVersaoConjuntoRegras.publicada.val,
              descricao: 'Versão publicada do teste de integração.',
            ).toInsertMap(),
            VersaoConjuntoRegras.idCol,
          ) as int;

  await db.table(RegraElegibilidade.fqtn).insert(
        RegraElegibilidade(
          id: 0,
          idVersaoConjuntoRegras: idVersaoConjuntoRegras,
          chaveRegra: 'renda_limite',
          titulo: 'Renda até 2500',
          expressaoJson: jsonEncode(<String, dynamic>{
            'tipo': 'comparacao',
            'campo': 'renda_familiar',
            'operador': 'lte',
            'valor': 2500,
          }),
          motivoFalha: 'Renda acima do limite permitido.',
          ordem: 0,
        ).toInsertMap(),
      );
  await db.table(RegraPontuacao.fqtn).insert(
        RegraPontuacao(
          id: 0,
          idVersaoConjuntoRegras: idVersaoConjuntoRegras,
          chaveRegra: 'prioridade_social',
          titulo: 'Prioridade social',
          expressaoJson: jsonEncode(<String, dynamic>{
            'tipo': 'comparacao',
            'campo': 'prioridade_social',
            'operador': 'eq',
            'valor': true,
          }),
          valorPontuacao: 25,
          ordem: 0,
        ).toInsertMap(),
      );

  return _AmbienteFluxoInterno(
    idServico: idServico,
    codigoServico: codigoServico,
  );
}

Future<int> _inserirNo(Connection db, NoFluxo no) async {
  return await db.table(NoFluxo.fqtn).insertGetId(
        no.toInsertMap(),
        NoFluxo.idCol,
      ) as int;
}

Future<void> _inserirAresta(
  Connection db,
  int idFluxo,
  String chave,
  int origem,
  int destino,
) async {
  await db.table(ArestaFluxo.fqtn).insert(
        ArestaFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveAresta: chave,
          idNoOrigem: origem,
          idNoDestino: destino,
          handleOrigem: 'saida',
          handleDestino: 'entrada',
        ).toInsertMap(),
      );
}

Future<void> _limparServicoFluxoInterno(Connection db, int idServico) async {
  final versoes = await db
      .table(VersaoServico.fqtn)
      .select([VersaoServico.idFqCol])
      .where(VersaoServico.idServicoCol, Operator.equal, idServico)
      .get();
  final idsVersao = versoes
      .map((item) => item[VersaoServico.idCol] as int)
      .toList(growable: false);

  if (idsVersao.isNotEmpty) {
    await db
        .table(ExecucaoClassificacao.fqtn)
        .whereIn(ExecucaoClassificacao.idVersaoServicoCol, idsVersao)
        .delete();
  }

  await db
      .table(Submissao.fqtn)
      .where(Submissao.idServicoCol, Operator.equal, idServico)
      .delete();
  await db
      .table(SessaoExecucao.fqtn)
      .where(SessaoExecucao.idServicoCol, Operator.equal, idServico)
      .delete();
  await db
      .table(Servico.fqtn)
      .where(Servico.idCol, Operator.equal, idServico)
      .delete();
}
