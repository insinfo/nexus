import 'dart:convert';

import 'package:eloquent/eloquent.dart';
import 'package:essential_core/essential_core.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';
import '../../../shared/utils/identificador_binding_utils.dart';
import '../../../shared/utils/json_utils.dart';
import '../../runtime/services/avaliador_condicao_service.dart';

class OperacaoRepository {
  OperacaoRepository(this.db, this._avaliadorCondicaoService);

  final Connection db;
  final AvaliadorCondicaoService _avaliadorCondicaoService;

  static const List<String> _statusSubmissaoValidos = <String>[
    'submetida',
    'em_analise',
    'pendente_documentos',
    'elegivel',
    'inelegivel',
    'ranqueada',
    'homologada',
    'arquivada',
  ];
  static const List<String> _statusTarefaAbertos = <String>[
    'aberta',
    'em_andamento',
    'bloqueada',
  ];

  Future<DataFrame<ResumoSubmissaoOperacao>> listSubmissoes() async {
    final rows = await db
        .table(Submissao.fqtn)
        .select([
          '${Submissao.idFqCol} as pk',
          '${Submissao.idPublicoFqCol} as id_submissao',
          '${Submissao.statusFqCol} as status',
          '${Submissao.fqtn}.submetida_em as criado_em',
          '${Submissao.fqtn}.atualizado_em as atualizado_em',
          '${Servico.idPublicoFqCol} as id_servico',
          '${Servico.codigoFqCol} as codigo_servico',
          '${Servico.nomeFqCol} as nome_servico',
          '${Protocolo.numeroProtocoloFqCol} as numero_protocolo',
          '${Protocolo.codigoPublicoFqCol} as codigo_publico',
        ])
        .join(
          Servico.fqtn,
          Servico.idFqCol,
          '=',
          Submissao.idServicoFqCol,
        )
        .join(
          Protocolo.fqtn,
          Protocolo.idSubmissaoFqCol,
          '=',
          Submissao.idFqCol,
        )
        .orderBy('${Submissao.fqtn}.submetida_em', OrderDir.desc)
        .get();

    if (rows.isEmpty) {
      return DataFrame<ResumoSubmissaoOperacao>.newClear();
    }

    final idsSubmissao =
        rows.map((row) => row['pk'] as int).toList(growable: false);
    final possuiTarefas = await _carregarPossuiTarefaAberta(idsSubmissao);
    final resultados = await _carregarUltimosResultados(idsSubmissao);

    final itens = rows.map((row) {
      final pk = row['pk'] as int;
      final resultado = resultados[pk];
      return ResumoSubmissaoOperacao(
        idSubmissao: row['id_submissao'].toString(),
        idServico: row['id_servico'].toString(),
        codigoServico: row['codigo_servico'] as String? ?? '',
        nomeServico: row['nome_servico'] as String? ?? '',
        numeroProtocolo: row['numero_protocolo'] as String? ?? '',
        codigoPublico: row['codigo_publico'] as String? ?? '',
        status: row['status'] as String? ?? 'submetida',
        criadoEm: _lerDataHora(row['criado_em']) ?? DateTime.now(),
        atualizadoEm: _lerDataHora(row['atualizado_em']),
        pontuacaoFinal: _lerDouble(resultado?['pontuacao_final']),
        posicaoFinal: _lerInt(resultado?['posicao_final']),
        elegivel: _lerBool(resultado?['elegivel']),
        possuiTarefaAberta: possuiTarefas.contains(pk),
      );
    }).toList(growable: false);

    return DataFrame<ResumoSubmissaoOperacao>(
      items: itens,
      totalRecords: itens.length,
    );
  }

  Future<Map<String, dynamic>?> findSubmissaoById(String idSubmissao) async {
    final base = await _buscarSubmissaoBase(idSubmissao);
    if (base == null) {
      return null;
    }

    final pk = base['pk'] as int;
    final resumo = (await _montarResumosPorPk(<int>[pk]))[pk];
    final tarefas = await db
        .table('public.tarefas_internas')
        .select([
          'id',
          'id_publico',
          'titulo',
          'descricao',
          'status',
          'prioridade',
          'prazo_em',
          'criado_em',
          'atualizado_em',
          'concluido_em',
        ])
        .where('id_submissao', Operator.equal, pk)
        .orderBy('criado_em', OrderDir.desc)
        .get();
    final historico = await db
        .table(HistoricoStatusSubmissao.fqtn)
        .where(HistoricoStatusSubmissao.idSubmissaoCol, Operator.equal, pk)
        .orderBy(HistoricoStatusSubmissao.criadoEmCol, OrderDir.desc)
        .get();
    final resultado = (await _carregarUltimosResultados(<int>[pk]))[pk];

    return <String, dynamic>{
      'submissao': resumo?.toMap(),
      'tarefas': tarefas
          .map((item) => <String, dynamic>{
                'id': item['id'],
                'id_publico': item['id_publico']?.toString(),
                'titulo': item['titulo'],
                'descricao': item['descricao'],
                'status': item['status'],
                'prioridade': item['prioridade'],
                'prazo_em': _lerDataHora(item['prazo_em'])?.toIso8601String(),
                'criado_em': _lerDataHora(item['criado_em'])?.toIso8601String(),
                'atualizado_em':
                    _lerDataHora(item['atualizado_em'])?.toIso8601String(),
                'concluido_em':
                    _lerDataHora(item['concluido_em'])?.toIso8601String(),
              })
          .toList(growable: false),
      'historico_status': historico
          .map((item) => <String, dynamic>{
                'status_anterior':
                    item[HistoricoStatusSubmissao.statusAnteriorCol],
                'novo_status': item[HistoricoStatusSubmissao.novoStatusCol],
                'motivo': item[HistoricoStatusSubmissao.motivoCol],
                'metadados_json': JsonUtils.lerMapa(
                    item[HistoricoStatusSubmissao.metadadosJsonCol]),
                'criado_em':
                    _lerDataHora(item[HistoricoStatusSubmissao.criadoEmCol])
                        ?.toIso8601String(),
              })
          .toList(growable: false),
      'resultado_classificacao': resultado == null
          ? null
          : <String, dynamic>{
              'pontuacao_final': _lerDouble(resultado['pontuacao_final']),
              'posicao_final': _lerInt(resultado['posicao_final']),
              'elegivel': _lerBool(resultado['elegivel']),
              'justificativa_json':
                  JsonUtils.lerMapa(resultado['justificativa_json']),
              'id_execucao': resultado['id_execucao']?.toString(),
            },
    };
  }

  Future<ResumoSubmissaoOperacao> transitionSubmissao(
    RequisicaoTransicaoSubmissao requisicao,
  ) async {
    if (!_statusSubmissaoValidos.contains(requisicao.novoStatus)) {
      throw StateError(
          'Status inválido para submissão: ${requisicao.novoStatus}');
    }

    final base = await _buscarSubmissaoBase(requisicao.idSubmissao);
    if (base == null) {
      throw StateError('Submissão não encontrada: ${requisicao.idSubmissao}');
    }

    final pk = base['pk'] as int;
    final statusAtual = base['status'] as String? ?? 'submetida';
    if (statusAtual == requisicao.novoStatus) {
      final resumoAtual = (await _montarResumosPorPk(<int>[pk]))[pk];
      if (resumoAtual == null) {
        throw StateError('Submissão encontrada sem resumo operacional.');
      }
      return resumoAtual;
    }

    await db.transaction((Connection ctx) async {
      await ctx
          .table(Submissao.fqtn)
          .where(Submissao.idCol, Operator.equal, pk)
          .update(<String, dynamic>{
        Submissao.statusCol: requisicao.novoStatus,
        'atualizado_em': DateTime.now().toIso8601String(),
      });

      await ctx.table(HistoricoStatusSubmissao.fqtn).insert(
            HistoricoStatusSubmissao(
              id: 0,
              idSubmissao: pk,
              statusAnterior: statusAtual,
              novoStatus: requisicao.novoStatus,
              motivo: requisicao.motivo,
              metadadosJson:
                  jsonEncode(<String, dynamic>{'origem': 'operacao_manual'}),
            ).toInsertMap(),
          );

      if (requisicao.novoStatus == 'em_analise') {
        await _garantirTarefaAnalise(ctx, pk, base);
      }

      if (requisicao.novoStatus == 'homologada' ||
          requisicao.novoStatus == 'arquivada') {
        await _encerrarTarefasAbertas(
          ctx,
          pk,
          novoStatusTarefa:
              requisicao.novoStatus == 'homologada' ? 'concluida' : 'cancelada',
          motivo: requisicao.motivo,
        );
      }
    });

    final resumo = (await _montarResumosPorPk(<int>[pk]))[pk];
    if (resumo == null) {
      throw StateError('Falha ao recarregar a submissão após transição.');
    }
    return resumo;
  }

  Future<ResumoExecucaoClassificacao> runClassificacao(
    RequisicaoExecutarClassificacao requisicao,
  ) async {
    final servico = await _buscarServico(requisicao.idServico);
    if (servico == null) {
      throw StateError('Serviço não encontrado: ${requisicao.idServico}');
    }

    final versaoServico =
        await _buscarVersaoServico(servico.id, requisicao.idVersaoServico);
    if (versaoServico == null) {
      throw StateError(
          'Versão de serviço não encontrada para ${requisicao.idServico}');
    }

    final versaoConjuntoRegras = await _buscarVersaoConjuntoRegras(
      idServicoPk: servico.id,
      idVersaoConjuntoRegras: requisicao.idVersaoConjuntoRegras,
    );
    if (versaoConjuntoRegras == null) {
      throw StateError('Serviço sem versão publicada de conjunto de regras.');
    }

    final regrasPontuacaoRows = await db
        .table(RegraPontuacao.fqtn)
        .where(
          RegraPontuacao.idVersaoConjuntoRegrasCol,
          '=',
          versaoConjuntoRegras.id,
        )
        .orderBy(RegraPontuacao.ordemCol, OrderDir.asc)
        .get();
    final regrasElegibilidadeRows = await db
        .table(RegraElegibilidade.fqtn)
        .where(
          RegraElegibilidade.idVersaoConjuntoRegrasCol,
          '=',
          versaoConjuntoRegras.id,
        )
        .orderBy(RegraElegibilidade.ordemCol, OrderDir.asc)
        .get();

    final regrasPontuacao = regrasPontuacaoRows
        .map((row) => RegraPontuacao.fromMap(row))
        .toList(growable: false);
    final regrasElegibilidade = regrasElegibilidadeRows
        .map((row) => RegraElegibilidade.fromMap(row))
        .toList(growable: false);

    final submissoesRows = await db
        .table(Submissao.fqtn)
        .select([
          '${Submissao.idFqCol} as pk',
          '${Submissao.idPublicoFqCol} as id_submissao',
          '${Submissao.snapshotJsonFqCol} as snapshot_json',
          '${Submissao.statusFqCol} as status',
          '${Protocolo.numeroProtocoloFqCol} as numero_protocolo',
          '${Protocolo.codigoPublicoFqCol} as codigo_publico',
        ])
        .join(
          Protocolo.fqtn,
          Protocolo.idSubmissaoFqCol,
          '=',
          Submissao.idFqCol,
        )
        .where(Submissao.idServicoCol, Operator.equal, servico.id)
        .whereIn(Submissao.statusCol, <String>[
          'submetida',
          'em_analise',
          'pendente_documentos',
          'elegivel',
          'inelegivel',
          'ranqueada',
          'homologada',
        ])
        .orderBy('${Submissao.fqtn}.submetida_em', OrderDir.asc)
        .get();

    final snapshotExecucao = <String, dynamic>{
      'id_servico': servico.idPublico,
      'id_versao_servico': versaoServico.idPublico,
      'id_versao_conjunto_regras': versaoConjuntoRegras.idPublico,
      'quantidade_submissoes': submissoesRows.length,
      'regras_pontuacao':
          regrasPontuacao.map((item) => item.toMap()).toList(growable: false),
      'regras_elegibilidade': regrasElegibilidade
          .map((item) => item.toMap())
          .toList(growable: false),
    };

    return await db.transaction((Connection ctx) async {
      final execucaoId =
          await ctx.table(ExecucaoClassificacao.fqtn).insertGetId(
                ExecucaoClassificacao(
                  id: 0,
                  idVersaoServico: versaoServico.id,
                  idVersaoConjuntoRegras: versaoConjuntoRegras.id,
                  status: 'executando',
                  snapshotDatasetJson: jsonEncode(snapshotExecucao),
                  notas: requisicao.notas,
                ).toInsertMap(),
                ExecucaoClassificacao.idCol,
              ) as int;

      final avaliados = submissoesRows.map((row) {
        final contexto = _normalizarContextoClassificacao(
            JsonUtils.lerMapa(row['snapshot_json']));
        final falhasElegibilidade = <Map<String, dynamic>>[];
        for (final regra in regrasElegibilidade) {
          final expressao = JsonUtils.lerMapa(regra.expressaoJson);
          final passou =
              _avaliadorCondicaoService.avaliarExpressao(expressao, contexto);
          if (!passou) {
            falhasElegibilidade.add(<String, dynamic>{
              'chave_regra': regra.chaveRegra,
              'titulo': regra.titulo,
              'motivo_falha': regra.motivoFalha,
            });
          }
        }

        var pontuacao = 0.0;
        final pontuacoesAplicadas = <Map<String, dynamic>>[];
        if (falhasElegibilidade.isEmpty) {
          for (final regra in regrasPontuacao) {
            final expressao = JsonUtils.lerMapa(regra.expressaoJson);
            final aplica =
                _avaliadorCondicaoService.avaliarExpressao(expressao, contexto);
            if (!aplica) {
              continue;
            }
            final valor = regra.valorPontuacao ?? 0;
            pontuacao += valor;
            pontuacoesAplicadas.add(<String, dynamic>{
              'chave_regra': regra.chaveRegra,
              'titulo': regra.titulo,
              'valor_pontuacao': valor,
            });
          }
        }

        return <String, dynamic>{
          'pk': row['pk'] as int,
          'id_submissao': row['id_submissao'].toString(),
          'numero_protocolo': row['numero_protocolo'] as String? ?? '',
          'codigo_publico': row['codigo_publico'] as String? ?? '',
          'status_anterior': row['status'] as String? ?? 'submetida',
          'pontuacao_final': pontuacao,
          'elegivel': falhasElegibilidade.isEmpty,
          'falhas_elegibilidade': falhasElegibilidade,
          'pontuacoes_aplicadas': pontuacoesAplicadas,
        };
      }).toList(growable: false);

      final elegiveis = avaliados
          .where((item) => item['elegivel'] == true)
          .toList(growable: false)
        ..sort((a, b) {
          final score = (_lerDouble(b['pontuacao_final']) ?? 0)
              .compareTo(_lerDouble(a['pontuacao_final']) ?? 0);
          if (score != 0) {
            return score;
          }
          return (a['numero_protocolo'] as String)
              .compareTo(b['numero_protocolo'] as String);
        });
      for (var i = 0; i < elegiveis.length; i++) {
        elegiveis[i]['posicao_final'] = i + 1;
      }
      final posicoes = <int, int>{
        for (final item in elegiveis)
          item['pk'] as int: item['posicao_final'] as int,
      };

      for (final item in avaliados) {
        final pk = item['pk'] as int;
        final elegivel = item['elegivel'] as bool;
        final novoStatus = elegivel ? 'ranqueada' : 'inelegivel';
        final justificativa = <String, dynamic>{
          'pontuacoes_aplicadas': item['pontuacoes_aplicadas'],
          'falhas_elegibilidade': item['falhas_elegibilidade'],
          'id_execucao': execucaoId,
        };
        final snapshotRanking = <String, dynamic>{
          'pontuacao_final': item['pontuacao_final'],
          'posicao_final': posicoes[pk],
          'elegivel': elegivel,
          'justificativa': justificativa,
        };

        await ctx.table(ResultadoClassificacao.fqtn).insert(
              ResultadoClassificacao(
                id: 0,
                idExecucaoClassificacao: execucaoId,
                idSubmissao: pk,
                pontuacaoFinal: (_lerDouble(item['pontuacao_final']) ?? 0),
                posicaoFinal: posicoes[pk],
                elegivel: elegivel,
                justificativaJson: jsonEncode(justificativa),
                snapshotDesempateJson: jsonEncode(<String, dynamic>{
                  'numero_protocolo': item['numero_protocolo'],
                }),
              ).toInsertMap(),
            );

        await ctx
            .table(Submissao.fqtn)
            .where(Submissao.idCol, Operator.equal, pk)
            .update(<String, dynamic>{
          Submissao.idVersaoConjuntoRegrasCol: versaoConjuntoRegras.id,
          Submissao.statusCol: novoStatus,
          Submissao.snapshotRankingJsonCol: jsonEncode(snapshotRanking),
          'atualizado_em': DateTime.now().toIso8601String(),
        });

        await ctx.table(HistoricoStatusSubmissao.fqtn).insert(
              HistoricoStatusSubmissao(
                id: 0,
                idSubmissao: pk,
                statusAnterior: item['status_anterior'] as String?,
                novoStatus: novoStatus,
                motivo: elegivel
                    ? 'Classificação auditável concluída com enquadramento elegível.'
                    : 'Classificação auditável concluiu inelegibilidade.',
                metadadosJson: jsonEncode(<String, dynamic>{
                  'id_execucao': execucaoId,
                  'pontuacao_final': item['pontuacao_final'],
                  'elegivel': elegivel,
                }),
              ).toInsertMap(),
            );
      }

      await ctx
          .table(ExecucaoClassificacao.fqtn)
          .where(ExecucaoClassificacao.idCol, Operator.equal, execucaoId)
          .update(<String, dynamic>{
        ExecucaoClassificacao.statusCol: 'concluida',
        'finalizado_em': DateTime.now().toIso8601String(),
      });

      final rowExecucao = await ctx
          .table(ExecucaoClassificacao.fqtn)
          .where(ExecucaoClassificacao.idCol, Operator.equal, execucaoId)
          .first();
      final execucao = ExecucaoClassificacao.fromMap(rowExecucao!);
      return ResumoExecucaoClassificacao(
        idExecucao: execucao.idPublico ?? '$execucaoId',
        idServico: servico.idPublico ?? '${servico.id}',
        idVersaoServico: versaoServico.idPublico ?? '${versaoServico.id}',
        idVersaoConjuntoRegras:
            versaoConjuntoRegras.idPublico ?? '${versaoConjuntoRegras.id}',
        status: execucao.status,
        quantidadeProcessada: submissoesRows.length,
        iniciadoEm: execucao.iniciadoEm ?? DateTime.now(),
        finalizadoEm: execucao.finalizadoEm,
        notas: execucao.notas,
      );
    });
  }

  Future<DataFrame<ResumoResultadoClassificacao>> listResultadosClassificacao(
    String idServico,
  ) async {
    final servico = await _buscarServico(idServico);
    if (servico == null) {
      return DataFrame<ResumoResultadoClassificacao>.newClear();
    }

    final execucaoMaisRecente = await db
        .table(ExecucaoClassificacao.fqtn)
        .select([
          '${ExecucaoClassificacao.idFqCol} as id_execucao',
          '${ExecucaoClassificacao.idPublicoFqCol} as id_execucao_publico',
        ])
        .join(
          VersaoServico.fqtn,
          VersaoServico.idFqCol,
          '=',
          ExecucaoClassificacao.idVersaoServicoFqCol,
        )
        .where(VersaoServico.idServicoCol, Operator.equal, servico.id)
        .orderBy(ExecucaoClassificacao.idFqCol, OrderDir.desc)
        .first();
    if (execucaoMaisRecente == null) {
      return DataFrame<ResumoResultadoClassificacao>.newClear();
    }

    final rows = await db
        .table(ResultadoClassificacao.fqtn)
        .select([
          '${Submissao.idPublicoFqCol} as id_submissao',
          '${Protocolo.numeroProtocoloFqCol} as numero_protocolo',
          '${Protocolo.codigoPublicoFqCol} as codigo_publico',
          '${Servico.nomeFqCol} as nome_servico',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.pontuacaoFinalCol} as pontuacao_final',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.posicaoFinalCol} as posicao_final',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.elegivelCol} as elegivel',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.justificativaJsonCol} as justificativa_json',
        ])
        .join(
          Submissao.fqtn,
          Submissao.idFqCol,
          '=',
          ResultadoClassificacao.idSubmissaoFqCol,
        )
        .join(
          Protocolo.fqtn,
          Protocolo.idSubmissaoFqCol,
          '=',
          Submissao.idFqCol,
        )
        .join(
          Servico.fqtn,
          Servico.idFqCol,
          '=',
          Submissao.idServicoFqCol,
        )
        .where(ResultadoClassificacao.idExecucaoClassificacaoCol,
            Operator.equal, execucaoMaisRecente['id_execucao'])
        .orderBy(ResultadoClassificacao.posicaoFinalCol, OrderDir.asc)
        .get();

    final itens = rows
        .map(
          (row) => ResumoResultadoClassificacao(
            idSubmissao: row['id_submissao'].toString(),
            numeroProtocolo: row['numero_protocolo'] as String? ?? '',
            codigoPublico: row['codigo_publico'] as String? ?? '',
            nomeServico: row['nome_servico'] as String? ?? '',
            pontuacaoFinal: _lerDouble(row['pontuacao_final']) ?? 0,
            posicaoFinal: _lerInt(row['posicao_final']),
            elegivel: _lerBool(row['elegivel']) ?? false,
            justificativa: JsonUtils.lerMapa(row['justificativa_json']),
          ),
        )
        .toList(growable: false);

    return DataFrame<ResumoResultadoClassificacao>(
      items: itens,
      totalRecords: itens.length,
    );
  }

  Future<Map<String, dynamic>?> _buscarSubmissaoBase(String idSubmissao) {
    QueryBuilder criarQueryBase() {
      return db
          .table(Submissao.fqtn)
          .select([
            '${Submissao.idFqCol} as pk',
            '${Submissao.idPublicoFqCol} as id_submissao',
            '${Submissao.statusFqCol} as status',
            '${Servico.codigoFqCol} as codigo_servico',
            '${Servico.nomeFqCol} as nome_servico',
            '${Protocolo.numeroProtocoloFqCol} as numero_protocolo',
          ])
          .join(
            Servico.fqtn,
            Servico.idFqCol,
            '=',
            Submissao.idServicoFqCol,
          )
          .join(
            Protocolo.fqtn,
            Protocolo.idSubmissaoFqCol,
            '=',
            Submissao.idFqCol,
          );
    }

    return () async {
      var query = criarQueryBase();
      query.where(Protocolo.numeroProtocoloFqCol, Operator.equal, idSubmissao);
      Map<String, dynamic>? row = await query.first();

      if (row == null) {
        final idPublico = IdentificadorBindingUtils.uuidOuNull(idSubmissao);
        if (idPublico != null) {
          query = criarQueryBase();
          query.where(Submissao.idPublicoFqCol, Operator.equal, idPublico);
          row = await query.first();
        }
      }

      return row;
    }();
  }

  Future<Map<int, ResumoSubmissaoOperacao>> _montarResumosPorPk(
      List<int> idsSubmissao) async {
    if (idsSubmissao.isEmpty) {
      return <int, ResumoSubmissaoOperacao>{};
    }

    final rows = await db
        .table(Submissao.fqtn)
        .select([
          '${Submissao.idFqCol} as pk',
          '${Submissao.idPublicoFqCol} as id_submissao',
          '${Submissao.statusFqCol} as status',
          '${Submissao.fqtn}.submetida_em as criado_em',
          '${Submissao.fqtn}.atualizado_em as atualizado_em',
          '${Servico.idPublicoFqCol} as id_servico',
          '${Servico.codigoFqCol} as codigo_servico',
          '${Servico.nomeFqCol} as nome_servico',
          '${Protocolo.numeroProtocoloFqCol} as numero_protocolo',
          '${Protocolo.codigoPublicoFqCol} as codigo_publico',
        ])
        .join(
          Servico.fqtn,
          Servico.idFqCol,
          '=',
          Submissao.idServicoFqCol,
        )
        .join(
          Protocolo.fqtn,
          Protocolo.idSubmissaoFqCol,
          '=',
          Submissao.idFqCol,
        )
        .whereIn(Submissao.idCol, idsSubmissao)
        .get();

    final resultados = await _carregarUltimosResultados(idsSubmissao);
    final tarefasAbertas = await _carregarPossuiTarefaAberta(idsSubmissao);

    return <int, ResumoSubmissaoOperacao>{
      for (final row in rows)
        row['pk'] as int: ResumoSubmissaoOperacao(
          idSubmissao: row['id_submissao'].toString(),
          idServico: row['id_servico'].toString(),
          codigoServico: row['codigo_servico'] as String? ?? '',
          nomeServico: row['nome_servico'] as String? ?? '',
          numeroProtocolo: row['numero_protocolo'] as String? ?? '',
          codigoPublico: row['codigo_publico'] as String? ?? '',
          status: row['status'] as String? ?? 'submetida',
          criadoEm: _lerDataHora(row['criado_em']) ?? DateTime.now(),
          atualizadoEm: _lerDataHora(row['atualizado_em']),
          pontuacaoFinal:
              _lerDouble(resultados[row['pk'] as int]?['pontuacao_final']),
          posicaoFinal: _lerInt(resultados[row['pk'] as int]?['posicao_final']),
          elegivel: _lerBool(resultados[row['pk'] as int]?['elegivel']),
          possuiTarefaAberta: tarefasAbertas.contains(row['pk'] as int),
        ),
    };
  }

  Future<Set<int>> _carregarPossuiTarefaAberta(List<int> idsSubmissao) async {
    if (idsSubmissao.isEmpty) {
      return <int>{};
    }

    final rows = await db
        .table('public.tarefas_internas')
        .select(['id_submissao'])
        .whereIn('id_submissao', idsSubmissao)
        .whereIn('status', _statusTarefaAbertos)
        .get();
    return rows.map((item) => item['id_submissao'] as int).toSet();
  }

  Future<Map<int, Map<String, dynamic>>> _carregarUltimosResultados(
      List<int> idsSubmissao) async {
    if (idsSubmissao.isEmpty) {
      return <int, Map<String, dynamic>>{};
    }

    final rows = await db
        .table(ResultadoClassificacao.fqtn)
        .select([
          '${ResultadoClassificacao.idSubmissaoFqCol} as id_submissao',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.pontuacaoFinalCol} as pontuacao_final',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.posicaoFinalCol} as posicao_final',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.elegivelCol} as elegivel',
          '${ResultadoClassificacao.fqtb}.${ResultadoClassificacao.justificativaJsonCol} as justificativa_json',
          '${ExecucaoClassificacao.idPublicoFqCol} as id_execucao',
          '${ExecucaoClassificacao.idFqCol} as execucao_pk',
        ])
        .join(
          ExecucaoClassificacao.fqtn,
          ExecucaoClassificacao.idFqCol,
          '=',
          ResultadoClassificacao.idExecucaoClassificacaoFqCol,
        )
        .whereIn(ResultadoClassificacao.idSubmissaoCol, idsSubmissao)
        .orderBy(ExecucaoClassificacao.idFqCol, OrderDir.desc)
        .orderBy(ResultadoClassificacao.idFqCol, OrderDir.desc)
        .get();

    final mapa = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      final idSubmissao = row['id_submissao'] as int;
      mapa.putIfAbsent(idSubmissao, () => row);
    }
    return mapa;
  }

  Future<void> _garantirTarefaAnalise(
    Connection ctx,
    int idSubmissao,
    Map<String, dynamic> base,
  ) async {
    final existente = await ctx
        .table('public.tarefas_internas')
        .where('id_submissao', Operator.equal, idSubmissao)
        .whereIn('status', _statusTarefaAbertos)
        .first();
    if (existente != null) {
      return;
    }

    final idTarefa = await ctx
        .table('public.tarefas_internas')
        .insertGetId(<String, dynamic>{
      'id_submissao': idSubmissao,
      'titulo': 'Analisar submissão ${base['numero_protocolo']}',
      'descricao':
          'Triagem operacional do serviço ${base['codigo_servico']} - ${base['nome_servico']}.',
      'status': 'aberta',
      'prioridade': 'normal',
      'atualizado_em': DateTime.now().toIso8601String(),
    }, 'id') as int;

    await ctx.table('public.transicoes_tarefa').insert(<String, dynamic>{
      'id_tarefa': idTarefa,
      'status_anterior': null,
      'novo_status': 'aberta',
      'motivo':
          'Tarefa criada automaticamente ao iniciar análise institucional.',
    });
  }

  Future<void> _encerrarTarefasAbertas(
    Connection ctx,
    int idSubmissao, {
    required String novoStatusTarefa,
    String? motivo,
  }) async {
    final tarefas = await ctx
        .table('public.tarefas_internas')
        .select(['id', 'status'])
        .where('id_submissao', Operator.equal, idSubmissao)
        .whereIn('status', _statusTarefaAbertos)
        .get();

    for (final tarefa in tarefas) {
      final idTarefa = tarefa['id'] as int;
      final statusAnterior = tarefa['status'] as String?;
      await ctx
          .table('public.tarefas_internas')
          .where('id', Operator.equal, idTarefa)
          .update(<String, dynamic>{
        'status': novoStatusTarefa,
        'atualizado_em': DateTime.now().toIso8601String(),
        if (novoStatusTarefa == 'concluida')
          'concluido_em': DateTime.now().toIso8601String(),
      });
      await ctx.table('public.transicoes_tarefa').insert(<String, dynamic>{
        'id_tarefa': idTarefa,
        'status_anterior': statusAnterior,
        'novo_status': novoStatusTarefa,
        'motivo': motivo,
      });
    }
  }

  Future<Servico?> _buscarServico(String idServico) async {
    Map<String, dynamic>? row;
    final idPublico = IdentificadorBindingUtils.uuidOuNull(idServico);
    if (idPublico != null) {
      row = await db
          .table(Servico.fqtn)
          .where(Servico.idPublicoFqCol, Operator.equal, idPublico)
          .first();
    }

    row ??= await db
        .table(Servico.fqtn)
        .where(Servico.codigoFqCol, Operator.equal, idServico)
        .first();

    if (row == null) {
      return null;
    }
    return Servico.fromMap(row);
  }

  Future<VersaoServico?> _buscarVersaoServico(
    int idServicoPk,
    String? idVersaoServico,
  ) async {
    QueryBuilder criarQueryBase() {
      return db
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idServicoCol, Operator.equal, idServicoPk);
    }

    Map<String, dynamic>? row;
    if (idVersaoServico == null || idVersaoServico.isEmpty) {
      final query = criarQueryBase();
      query.where(
        VersaoServico.statusCol,
        Operator.equal,
        StatusVersaoServico.publicada.val,
      );
      query.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
      row = await query.first();
    } else {
      final idPublico = IdentificadorBindingUtils.uuidOuNull(idVersaoServico);
      final numeroVersao = _lerInt(idVersaoServico);

      if (idPublico != null) {
        final queryPorId = criarQueryBase();
        queryPorId.where(
            VersaoServico.idPublicoFqCol, Operator.equal, idPublico);
        queryPorId.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
        row = await queryPorId.first();
      }

      if (row == null && numeroVersao != null) {
        final queryPorNumero = criarQueryBase();
        queryPorNumero.where(
            VersaoServico.numeroVersaoFqCol, Operator.equal, numeroVersao);
        queryPorNumero.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
        row = await queryPorNumero.first();
      }
    }
    if (row == null) {
      return null;
    }
    return VersaoServico.fromMap(row);
  }

  Future<VersaoConjuntoRegras?> _buscarVersaoConjuntoRegras({
    required int idServicoPk,
    required String? idVersaoConjuntoRegras,
  }) async {
    QueryBuilder criarQueryBase() {
      return db
          .table(VersaoConjuntoRegras.fqtn)
          .select([
            VersaoConjuntoRegras.idFqCol,
            VersaoConjuntoRegras.idPublicoFqCol,
            VersaoConjuntoRegras.idConjuntoRegrasFqCol,
            VersaoConjuntoRegras.numeroVersaoFqCol,
            VersaoConjuntoRegras.statusFqCol,
            '${VersaoConjuntoRegras.descricaoFqCol} as descricao',
            '${VersaoConjuntoRegras.definicaoJsonFqCol} as definicao_json',
            '${VersaoConjuntoRegras.criadoEmFqCol} as criado_em',
            '${VersaoConjuntoRegras.publicadoEmFqCol} as publicado_em',
          ])
          .join(ConjuntoRegras.fqtn, ConjuntoRegras.idFqCol, '=',
              VersaoConjuntoRegras.idConjuntoRegrasFqCol)
          .where(ConjuntoRegras.idServicoFqCol, Operator.equal, idServicoPk);
    }

    Map<String, dynamic>? row;
    if (idVersaoConjuntoRegras == null || idVersaoConjuntoRegras.isEmpty) {
      final query = criarQueryBase();
      query.where(
        VersaoConjuntoRegras.statusCol,
        Operator.equal,
        StatusVersaoConjuntoRegras.publicada.val,
      );
      query.orderBy(VersaoConjuntoRegras.numeroVersaoCol, OrderDir.desc);
      row = await query.first();
    } else {
      final idPublico =
          IdentificadorBindingUtils.uuidOuNull(idVersaoConjuntoRegras);
      final numeroVersao = _lerInt(idVersaoConjuntoRegras);

      if (idPublico != null) {
        final queryPorId = criarQueryBase();
        queryPorId.where(
            VersaoConjuntoRegras.idPublicoFqCol, Operator.equal, idPublico);
        queryPorId.orderBy(VersaoConjuntoRegras.numeroVersaoCol, OrderDir.desc);
        row = await queryPorId.first();
      }

      if (row == null && numeroVersao != null) {
        final queryPorNumero = criarQueryBase();
        queryPorNumero.where(VersaoConjuntoRegras.numeroVersaoFqCol,
            Operator.equal, numeroVersao);
        queryPorNumero.orderBy(
            VersaoConjuntoRegras.numeroVersaoCol, OrderDir.desc);
        row = await queryPorNumero.first();
      }
    }
    if (row == null) {
      return null;
    }
    return VersaoConjuntoRegras.fromMap(row);
  }

  Map<String, dynamic> _normalizarContextoClassificacao(
      Map<String, dynamic> snapshot) {
    final respostas = JsonUtils.lerMapa(snapshot['respostas']);
    final variaveis = JsonUtils.lerMapa(snapshot['variaveis']);
    return <String, dynamic>{
      ...snapshot,
      ...variaveis,
      ...respostas,
      'respostas': respostas,
      'variaveis': variaveis,
    };
  }

  static DateTime? _lerDataHora(dynamic valor) {
    if (valor == null) {
      return null;
    }
    if (valor is DateTime) {
      return valor;
    }
    return DateTime.tryParse(valor.toString());
  }

  static double? _lerDouble(dynamic valor) {
    if (valor == null) {
      return null;
    }
    if (valor is num) {
      return valor.toDouble();
    }
    return double.tryParse(valor.toString());
  }

  static int? _lerInt(dynamic valor) {
    if (valor == null) {
      return null;
    }
    if (valor is int) {
      return valor;
    }
    if (valor is num) {
      return valor.toInt();
    }
    return int.tryParse(valor.toString());
  }

  static bool? _lerBool(dynamic valor) {
    if (valor == null) {
      return null;
    }
    if (valor is bool) {
      return valor;
    }
    if (valor is num) {
      return valor != 0;
    }
    final texto = valor.toString().toLowerCase();
    if (texto == 'true' || texto == 't' || texto == '1') {
      return true;
    }
    if (texto == 'false' || texto == 'f' || texto == '0') {
      return false;
    }
    return null;
  }
}
