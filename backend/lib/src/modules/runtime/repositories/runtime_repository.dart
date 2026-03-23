import 'dart:convert';

import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';
import '../../../shared/services/reconstrutor_formulario_persistido_service.dart';
import '../../../shared/utils/identificador_binding_utils.dart';
import '../../../shared/utils/json_utils.dart';
import '../../../shared/utils/numero_utils.dart';
import '../../operacao/services/operacao_port.dart';
import '../services/avaliador_condicao_service.dart';
import '../services/executor_conteudo_dinamico_service.dart';
import '../services/runtime_port.dart';
import '../../../shared/utils/protocolo_utils.dart';

class _SessaoInterna {
  final int pk;
  final String idPublico;
  final int idServicoPk;
  final String idServicoPublico;
  final int idVersaoPk;
  final String idVersaoPublico;
  final int idFluxoAtualPk;
  final String chaveFluxoAtual;
  final int idNoAtualPk;
  final String chaveNoAtual;
  final String canal;
  final String status;
  final Map<String, dynamic> contextoJson;
  final String snapshotFluxoJson;

  const _SessaoInterna({
    required this.pk,
    required this.idPublico,
    required this.idServicoPk,
    required this.idServicoPublico,
    required this.idVersaoPk,
    required this.idVersaoPublico,
    required this.idFluxoAtualPk,
    required this.chaveFluxoAtual,
    required this.idNoAtualPk,
    required this.chaveNoAtual,
    required this.canal,
    required this.status,
    required this.contextoJson,
    required this.snapshotFluxoJson,
  });
}

class _ResultadoProcessamentoAutomatico {
  const _ResultadoProcessamentoAutomatico({
    required this.rowNoAtual,
    required this.status,
    this.registroSubmissao,
  });

  final Map<String, dynamic> rowNoAtual;
  final StatusExecucao status;
  final RegistroSubmissao? registroSubmissao;
}

class _ResultadoSubmissaoGarantida {
  const _ResultadoSubmissaoGarantida({
    required this.submissao,
    required this.registroSubmissao,
  });

  final Submissao submissao;
  final RegistroSubmissao registroSubmissao;
}

/// Repositório de operações de runtime de execução de fluxos.
class RuntimeRepository implements RuntimePort {
  final Connection db;
  final AvaliadorCondicaoService _avaliadorCondicaoService;
  final ExecutorConteudoDinamicoService _executorConteudoDinamicoService;
  final ReconstrutorFormularioPersistidoService
      _reconstrutorFormularioPersistidoService;
  final OperacaoPort _operacaoPort;

  RuntimeRepository(
    this.db,
    this._avaliadorCondicaoService,
    this._executorConteudoDinamicoService,
    this._reconstrutorFormularioPersistidoService,
    this._operacaoPort,
  );

  // ---------- helpers ----------

  QueryBuilder _queryServicoAtivoPorIdentificador(String identificador) {
    final idPublico = IdentificadorBindingUtils.uuidOuNull(identificador);
    final query = db
        .table(Servico.fqtn)
        .select([Servico.idFqCol, Servico.idPublicoFqCol]).where(
            Servico.ativoFqCol, Operator.equal, true);

    if (idPublico != null) {
      query.where(Servico.idPublicoFqCol, Operator.equal, idPublico);
      return query;
    }

    query.where(Servico.codigoFqCol, Operator.equal, identificador);
    return query;
  }

  // ---------- leitura ----------

  /// Carrega a sessão interna pelo [idPublico].
  Future<_SessaoInterna?> _buscarSessaoInterna(String idPublico) async {
    final idPublicoUuid = IdentificadorBindingUtils.uuidOuNull(idPublico);
    if (idPublicoUuid == null) {
      return null;
    }

    final row = await db
        .table(SessaoExecucao.fqtn)
        .select([
          '${SessaoExecucao.idFqCol} as pk',
          SessaoExecucao.idPublicoFqCol,
          SessaoExecucao.canalFqCol,
          SessaoExecucao.statusFqCol,
          SessaoExecucao.contextoJsonFqCol,
          SessaoExecucao.snapshotFluxoJsonFqCol,
          SessaoExecucao.idFluxoAtualFqCol,
          DefinicaoFluxo.chaveFluxoFqCol,
          SessaoExecucao.idNoAtualFqCol,
          NoFluxo.chaveNoFqCol,
          SessaoExecucao.idServicoFqCol,
          Servico.idPublicoFqCol,
          SessaoExecucao.idVersaoServicoFqCol,
          VersaoServico.idPublicoFqCol,
        ])
        .join(DefinicaoFluxo.fqtn, DefinicaoFluxo.idFqCol, '=',
            SessaoExecucao.idFluxoAtualFqCol)
        .join(NoFluxo.fqtn, NoFluxo.idFqCol, '=', SessaoExecucao.idNoAtualFqCol)
        .join(Servico.fqtn, Servico.idFqCol, '=', SessaoExecucao.idServicoFqCol)
        .join(
          VersaoServico.fqtn,
          VersaoServico.idFqCol,
          '=',
          SessaoExecucao.idVersaoServicoFqCol,
        )
        .where(SessaoExecucao.idPublicoFqCol, Operator.equal, idPublicoUuid)
        .first();

    if (row == null) return null;

    return _SessaoInterna(
      pk: row['pk'] as int,
      idPublico: row[SessaoExecucao.idPublicoCol].toString(),
      idServicoPk: row['id_servico'] as int,
      idServicoPublico: row[Servico.idPublicoCol].toString(),
      idVersaoPk: row['id_versao_servico'] as int,
      idVersaoPublico: row[VersaoServico.idPublicoCol].toString(),
      idFluxoAtualPk: row['id_fluxo_atual'] as int,
      chaveFluxoAtual: row['chave_fluxo'] as String,
      idNoAtualPk: row['id_no_atual'] as int,
      chaveNoAtual: row['chave_no'] as String,
      canal: row['canal'] as String,
      status: row['status'] as String,
      contextoJson: JsonUtils.lerMapa(row['contexto_json']),
      snapshotFluxoJson: JsonUtils.lerTexto(row['snapshot_fluxo_json']),
    );
  }

  /// Carrega o nó de fluxo pelo PK interno.
  Future<Map<String, dynamic>?> _buscarNoPorPk(int pk) async {
    return db
        .table(NoFluxo.fqtn)
        .select([
          NoFluxo.idFqCol,
          NoFluxo.chaveNoFqCol,
          NoFluxo.tipoNoFqCol,
          NoFluxo.rotuloFqCol,
          NoFluxo.posicaoXFqCol,
          NoFluxo.posicaoYFqCol,
          NoFluxo.larguraFqCol,
          NoFluxo.alturaFqCol,
          NoFluxo.dadosJsonFqCol,
        ])
        .where(NoFluxo.idFqCol, Operator.equal, pk)
        .first();
  }

  /// Constrói um [NoFluxoDto] a partir de uma linha bruta do banco.
  Future<NoFluxoDto> _construirNo(Map<String, dynamic> row) async {
    final tipo = TipoNoFluxo.parseBanco(row['tipo_no'] as String);
    final dadosBase = JsonUtils.lerMapa(row['dados_json']);
    if (dadosBase['rotulo'] == null && row[NoFluxo.rotuloCol] != null) {
      dadosBase['rotulo'] = row[NoFluxo.rotuloCol].toString();
    }

    return NoFluxoDto(
      id: row['chave_no'] as String,
      tipo: tipo,
      posicao: PosicaoXY(
        x: NumeroUtils.lerDouble(row['posicao_x']),
        y: NumeroUtils.lerDouble(row['posicao_y']),
      ),
      dados: tipo == TipoNoFluxo.formulario
          ? await _reconstrutorFormularioPersistidoService.carregarPorIdNo(
              row[NoFluxo.idCol] as int,
              dadosBase: dadosBase,
            )
          : dadosNoFluxoFromMap(
              tipo: tipo,
              mapa: dadosBase,
            ),
      largura:
          row['largura'] != null ? NumeroUtils.lerDouble(row['largura']) : null,
      altura:
          row['altura'] != null ? NumeroUtils.lerDouble(row['altura']) : null,
    );
  }

  /// Busca a aresta de saída do nó, considerando o handle de saída.
  /// Para nós de condição, [handleSaida] indica qual ramo seguir.
  Future<Map<String, dynamic>?> _buscarArestaSaida(
    int idFluxoPk,
    int idNoOrigemPk, {
    String? handleSaida,
  }) async {
    final query = db
        .table(ArestaFluxo.fqtn)
        .select([ArestaFluxo.idNoDestinoFqCol, ArestaFluxo.handleOrigemFqCol])
        .where(ArestaFluxo.idDefinicaoFluxoFqCol, Operator.equal, idFluxoPk)
        .where(ArestaFluxo.idNoOrigemFqCol, Operator.equal, idNoOrigemPk);

    if (handleSaida != null) {
      query.where(ArestaFluxo.handleOrigemFqCol, Operator.equal, handleSaida);
    }

    return query.first();
  }

  // ---------- leitura pública ----------

  /// Retorna o [EstadoPassoRuntime] atual de uma sessão.
  @override
  Future<EstadoPassoRuntime?> obterEstado(String idSessao) async {
    final sessao = await _buscarSessaoInterna(idSessao);
    if (sessao == null) return null;

    final rowNo = await _buscarNoPorPk(sessao.idNoAtualPk);
    if (rowNo == null) return null;

    return EstadoPassoRuntime(
      idSessao: sessao.idPublico,
      idServico: sessao.idServicoPublico,
      idVersaoServico: sessao.idVersaoPublico,
      chaveFluxoAtual: sessao.chaveFluxoAtual,
      noAtual: await _construirNo(rowNo),
      status: StatusExecucao.parseBanco(sessao.status),
      contexto: ContextoExecucaoDto.fromMap(sessao.contextoJson),
    );
  }

  // ---------- escrita ----------

  /// Inicia uma nova sessão de execução para o serviço indicado.
  @override
  Future<EstadoPassoRuntime> iniciarSessao(
    String idServico,
    String canal,
    Map<String, dynamic> contextoInicial,
  ) async {
    // 1. Localizar o serviço
    final rowServico =
        await _queryServicoAtivoPorIdentificador(idServico).first();

    if (rowServico == null) {
      throw StateError('Serviço não encontrado: $idServico');
    }

    final servicoPk = rowServico['id'] as int;
    final servicoPubId = rowServico[Servico.idPublicoCol].toString();

    // 2. Versão publicada
    final rowVersao = await db
        .table(VersaoServico.fqtn)
        .select([VersaoServico.idFqCol, VersaoServico.idPublicoFqCol])
        .where(VersaoServico.idServicoFqCol, Operator.equal, servicoPk)
        .where(
          VersaoServico.statusFqCol,
          Operator.equal,
          StatusVersaoServico.publicada.val,
        )
        .first();

    if (rowVersao == null) {
      throw StateError('Serviço sem versão publicada: $idServico');
    }

    final versaoPk = rowVersao['id'] as int;
    final versaoPubId = rowVersao[VersaoServico.idPublicoCol].toString();

    // 3. Fluxo de entrada
    final rowFluxo = await db
        .table(DefinicaoFluxo.fqtn)
        .select([
          DefinicaoFluxo.idFqCol,
          DefinicaoFluxo.idPublicoFqCol,
          DefinicaoFluxo.chaveFluxoFqCol
        ])
        .where(DefinicaoFluxo.idVersaoServicoFqCol, Operator.equal, versaoPk)
        .where(DefinicaoFluxo.pontoEntradaFqCol, Operator.equal, true)
        .first();

    if (rowFluxo == null) {
      throw StateError('Versão sem fluxo de entrada: $versaoPubId');
    }

    final fluxoPk = rowFluxo['id'] as int;
    final chaveFluxo = rowFluxo['chave_fluxo'] as String;

    // 4. Nó de início
    final rowNoInicio = await db
        .table(NoFluxo.fqtn)
        .select([
          NoFluxo.idFqCol,
          NoFluxo.chaveNoFqCol,
          NoFluxo.tipoNoFqCol,
          NoFluxo.posicaoXFqCol,
          NoFluxo.posicaoYFqCol,
          NoFluxo.larguraFqCol,
          NoFluxo.alturaFqCol,
          NoFluxo.dadosJsonFqCol
        ])
        .where(NoFluxo.idDefinicaoFluxoFqCol, Operator.equal, fluxoPk)
        .where(NoFluxo.tipoNoFqCol, Operator.equal, 'inicio')
        .first();

    if (rowNoInicio == null) {
      throw StateError('Fluxo sem nó de início: $chaveFluxo');
    }

    // 5. Avança automaticamente do início para o primeiro nó real
    final arestaSaidaInicio = await _buscarArestaSaida(
      fluxoPk,
      rowNoInicio['id'] as int,
    );

    final int idNoPrimeiro;
    if (arestaSaidaInicio != null) {
      idNoPrimeiro = arestaSaidaInicio['id_no_destino'] as int;
    } else {
      idNoPrimeiro = rowNoInicio['id'] as int;
    }

    final rowNoPrimeiro = await _buscarNoPorPk(idNoPrimeiro);
    if (rowNoPrimeiro == null) {
      throw StateError('Primeiro nó após início não encontrado');
    }

    // 6. Criar sessão
    final contextoSessao = <String, dynamic>{
      'respostas': <String, dynamic>{},
      'variaveis': contextoInicial,
      'resultados_integracao': <String, dynamic>{},
      'contexto_usuario': <String, dynamic>{},
      'contexto_servico': <String, dynamic>{},
      'contexto_edicao': <String, dynamic>{},
    };
    final contextoJson = jsonEncode(contextoSessao);

    final s = SessaoExecucao(
      id: 0,
      idServico: servicoPk,
      idVersaoServico: versaoPk,
      idFluxoAtual: fluxoPk,
      idNoAtual: idNoPrimeiro,
      canal: canal,
      status: 'em_andamento',
      contextoJson: contextoJson,
      snapshotFluxoJson: '{}',
    );

    final sessaoPk = await db.table(SessaoExecucao.fqtn).insertGetId(
          s.toInsertMap(),
          SessaoExecucao.idCol,
        ) as int;

    final sessaoInterna = _SessaoInterna(
      pk: sessaoPk,
      idPublico: '',
      idServicoPk: servicoPk,
      idServicoPublico: servicoPubId,
      idVersaoPk: versaoPk,
      idVersaoPublico: versaoPubId,
      idFluxoAtualPk: fluxoPk,
      chaveFluxoAtual: chaveFluxo,
      idNoAtualPk: idNoPrimeiro,
      chaveNoAtual: rowNoPrimeiro[NoFluxo.chaveNoCol] as String? ?? '',
      canal: canal,
      status: 'em_andamento',
      contextoJson: contextoSessao,
      snapshotFluxoJson: '{}',
    );

    final processamentoInicial = await _processarNosAutomaticos(
      sessao: sessaoInterna,
      rowNoInicial: rowNoPrimeiro,
      contextoAtual: contextoSessao,
    );
    final statusSessao = processamentoInicial.status;
    final rowNoAtualSessao = processamentoInicial.rowNoAtual;
    var registroSubmissao = processamentoInicial.registroSubmissao;
    if (statusSessao == StatusExecucao.concluida && registroSubmissao == null) {
      registroSubmissao = await _registrarSubmissaoSeNecessario(
        sessaoPk: sessaoPk,
        idServicoPk: servicoPk,
        idVersaoPk: versaoPk,
        idServicoPublico: servicoPubId,
        idVersaoPublico: versaoPubId,
        contextoAtual: contextoSessao,
      );
    }

    final sessaoAtualizada = SessaoExecucao(
      id: sessaoPk,
      idServico: servicoPk,
      idVersaoServico: versaoPk,
      idFluxoAtual: fluxoPk,
      idNoAtual: rowNoAtualSessao[NoFluxo.idCol] as int,
      canal: canal,
      status: statusSessao.val,
      contextoJson: jsonEncode(contextoSessao),
      snapshotFluxoJson: '{}',
      finalizadaEm:
          statusSessao == StatusExecucao.concluida ? DateTime.now() : null,
    );
    await db
        .table(SessaoExecucao.fqtn)
        .where(SessaoExecucao.idCol, Operator.equal, sessaoPk)
        .update(sessaoAtualizada.toUpdateMap());

    // 7. Ler id_publico da sessão criada
    final rowSessao = await db
        .table(SessaoExecucao.fqtn)
        .select([SessaoExecucao.idPublicoFqCol])
        .where(SessaoExecucao.idFqCol, Operator.equal, sessaoPk)
        .first();

    final idSessaoPub = rowSessao![SessaoExecucao.idPublicoCol].toString();

    return EstadoPassoRuntime(
      idSessao: idSessaoPub,
      idServico: servicoPubId,
      idVersaoServico: versaoPubId,
      chaveFluxoAtual: chaveFluxo,
      noAtual: await _construirNo(rowNoAtualSessao),
      status: statusSessao,
      contexto: ContextoExecucaoDto.fromMap(contextoSessao),
      registroSubmissao: registroSubmissao,
    );
  }

  /// Avança a sessão para o próximo nó com base nas [respostas] fornecidas.
  @override
  Future<EstadoPassoRuntime> avancarPasso(
    String idSessao,
    Map<String, dynamic> respostas,
  ) async {
    final sessao = await _buscarSessaoInterna(idSessao);
    if (sessao == null) {
      throw StateError('Sessão não encontrada: $idSessao');
    }
    if (sessao.status != 'em_andamento') {
      throw StateError('Sessão não está em andamento: $idSessao');
    }

    final rowNoAtual = await _buscarNoPorPk(sessao.idNoAtualPk);
    if (rowNoAtual == null) throw StateError('Nó atual não encontrado');

    final tipoNoAtual = TipoNoFluxo.parseBanco(rowNoAtual['tipo_no'] as String);

    // Salvar respostas do formulário
    if (tipoNoAtual == TipoNoFluxo.formulario) {
      await _salvarRespostasFormulario(
        sessaoPk: sessao.pk,
        idNoFluxoPk: sessao.idNoAtualPk,
        respostas: respostas,
      );
    }

    // Atualizar contexto com as novas respostas
    final contextoAtual = Map<String, dynamic>.from(sessao.contextoJson);
    final respostasContexto = Map<String, dynamic>.from(
        JsonUtils.lerMapa(contextoAtual['respostas']));
    respostasContexto.addAll(respostas);
    contextoAtual['respostas'] = respostasContexto;

    // Determinar próximo nó
    final String? handleSaida;
    if (tipoNoAtual == TipoNoFluxo.condicao) {
      final dadosJson = JsonUtils.lerMapa(rowNoAtual['dados_json']);
      final expressao = dadosJson['expressao'] as String? ?? '{}';
      final resultado = _avaliadorCondicaoService.avaliarExpressaoJson(
        expressao,
        respostasContexto,
      );
      handleSaida = resultado
          ? (dadosJson['handle_verdadeiro'] as String? ?? 'true')
          : (dadosJson['handle_falso'] as String? ?? 'false');
    } else {
      handleSaida = null;
    }

    final arestaSaida = await _buscarArestaSaida(
      sessao.idFluxoAtualPk,
      sessao.idNoAtualPk,
      handleSaida: handleSaida,
    );

    // Determinar novo status
    String novoStatus = 'em_andamento';
    int idNovoNo;
    late Map<String, dynamic> rowNovoNo;
    RegistroSubmissao? registroSubmissao;

    if (_noConcluiFluxo(rowNoAtual) || arestaSaida == null) {
      // Sem aresta de saída: nó terminal
      novoStatus = 'concluida';
      idNovoNo = sessao.idNoAtualPk;
      rowNovoNo = rowNoAtual;
    } else {
      idNovoNo = arestaSaida['id_no_destino'] as int;
      final row = await _buscarNoPorPk(idNovoNo);
      if (row == null) {
        throw StateError('Próximo nó não encontrado');
      }
      rowNovoNo = row;
      final tipoNovoNo = TipoNoFluxo.parseBanco(row['tipo_no'] as String);
      if (tipoNovoNo == TipoNoFluxo.fim || tipoNovoNo.automatico) {
        final processamento = await _processarNosAutomaticos(
          sessao: sessao,
          rowNoInicial: rowNovoNo,
          contextoAtual: contextoAtual,
        );
        rowNovoNo = processamento.rowNoAtual;
        novoStatus = processamento.status.val;
        registroSubmissao = processamento.registroSubmissao;
      }
    }

    // Atualizar sessão no banco
    final sessaoUpdate = SessaoExecucao(
      id: sessao.pk,
      idServico: sessao.idServicoPk,
      idVersaoServico: sessao.idVersaoPk,
      canal: sessao.canal,
      idFluxoAtual: sessao.idFluxoAtualPk,
      idNoAtual: idNovoNo,
      status: novoStatus,
      contextoJson: jsonEncode(contextoAtual),
      snapshotFluxoJson: sessao.snapshotFluxoJson,
      finalizadaEm: novoStatus == 'concluida' ? DateTime.now() : null,
    );

    await db
        .table(SessaoExecucao.fqtn)
        .where(SessaoExecucao.idFqCol, Operator.equal, sessao.pk)
        .update(sessaoUpdate.toUpdateMap());

    if (novoStatus == 'concluida') {
      registroSubmissao ??= await _registrarSubmissaoSeNecessario(
        sessaoPk: sessao.pk,
        idServicoPk: sessao.idServicoPk,
        idVersaoPk: sessao.idVersaoPk,
        idServicoPublico: sessao.idServicoPublico,
        idVersaoPublico: sessao.idVersaoPublico,
        contextoAtual: contextoAtual,
      );
    }

    return EstadoPassoRuntime(
      idSessao: sessao.idPublico,
      idServico: sessao.idServicoPublico,
      idVersaoServico: sessao.idVersaoPublico,
      chaveFluxoAtual: sessao.chaveFluxoAtual,
      noAtual: await _construirNo(rowNovoNo),
      status: StatusExecucao.parseBanco(novoStatus),
      contexto: ContextoExecucaoDto.fromMap(contextoAtual),
      registroSubmissao: registroSubmissao,
    );
  }

  /// Persiste as respostas de um nó de formulário.
  Future<void> _salvarRespostasFormulario({
    required int sessaoPk,
    required int idNoFluxoPk,
    required Map<String, dynamic> respostas,
  }) async {
    for (final entry in respostas.entries) {
      // Busca o campo pelo chave_campo
      final rowCampo = await db
          .table(CampoFormulario.fqtn)
          .select([CampoFormulario.idFqCol])
          .where(CampoFormulario.idNoFluxoFqCol, Operator.equal, idNoFluxoPk)
          .where(CampoFormulario.chaveCampoFqCol, Operator.equal, entry.key)
          .first();

      if (rowCampo == null) continue;

      final idCampo = rowCampo['id'] as int;
      final valorJson = jsonEncode(entry.value);

      // Upsert: atualiza se existir, insere caso contrário
      final existente = await db
          .table(RespostaSessao.fqtn)
          .where(RespostaSessao.idSessaoExecucaoFqCol, Operator.equal, sessaoPk)
          .where(RespostaSessao.idCampoFqCol, Operator.equal, idCampo)
          .where(RespostaSessao.indiceRepeticaoFqCol, Operator.equal, 0)
          .first();

      if (existente != null) {
        final rUpdate = RespostaSessao(
          id: existente[RespostaSessao.idCol] as int,
          idSessaoExecucao: sessaoPk,
          idCampo: idCampo,
          chaveCampo: entry.key,
          valorJson: valorJson,
          atualizadoEm: DateTime.now(),
        );
        await db
            .table(RespostaSessao.fqtn)
            .where(RespostaSessao.idFqCol, Operator.equal,
                existente[RespostaSessao.idCol])
            .update(rUpdate.toUpdateMap());
      } else {
        final rInsert = RespostaSessao(
          id: 0,
          idSessaoExecucao: sessaoPk,
          idCampo: idCampo,
          chaveCampo: entry.key,
          valorJson: valorJson,
          idNoOrigem: idNoFluxoPk,
        );
        await db.table(RespostaSessao.fqtn).insert(rInsert.toInsertMap());
      }
    }
  }

  Future<_ResultadoProcessamentoAutomatico> _processarNosAutomaticos({
    required _SessaoInterna sessao,
    required Map<String, dynamic> rowNoInicial,
    required Map<String, dynamic> contextoAtual,
  }) async {
    var rowAtual = rowNoInicial;
    var status = StatusExecucao.emAndamento;
    RegistroSubmissao? registroSubmissao;

    while (true) {
      final tipoNoAtual =
          TipoNoFluxo.parseBanco(rowAtual[NoFluxo.tipoNoCol] as String);
      if (tipoNoAtual == TipoNoFluxo.fim) {
        status = StatusExecucao.concluida;
        break;
      }
      if (!tipoNoAtual.automatico) {
        break;
      }

      if (tipoNoAtual == TipoNoFluxo.conteudoDinamico) {
        status = await _executarConteudoDinamico(
          sessaoPk: sessao.pk,
          idNoFluxoPk: rowAtual[NoFluxo.idCol] as int,
          rowNo: rowAtual,
          contextoAtual: contextoAtual,
        );
      } else {
        final submissao = await _garantirSubmissao(
          sessaoPk: sessao.pk,
          idServicoPk: sessao.idServicoPk,
          idVersaoPk: sessao.idVersaoPk,
          idServicoPublico: sessao.idServicoPublico,
          idVersaoPublico: sessao.idVersaoPublico,
          contextoAtual: contextoAtual,
        );
        registroSubmissao = submissao.registroSubmissao;
        switch (tipoNoAtual) {
          case TipoNoFluxo.tarefaInterna:
            await _executarNoTarefaInterna(
              idSubmissaoPk: submissao.submissao.id,
              rowNo: rowAtual,
            );
            break;
          case TipoNoFluxo.atualizacaoStatus:
            await _executarNoAtualizacaoStatus(
              idSubmissaoPk: submissao.submissao.id,
              rowNo: rowAtual,
            );
            break;
          case TipoNoFluxo.pontuacao:
            await _executarNoPontuacao(
              sessao: sessao,
              idSubmissaoPk: submissao.submissao.id,
              rowNo: rowAtual,
              contextoAtual: contextoAtual,
            );
            break;
          case TipoNoFluxo.classificacao:
            await _executarNoClassificacao(
              sessao: sessao,
              idSubmissaoPk: submissao.submissao.id,
              rowNo: rowAtual,
              contextoAtual: contextoAtual,
            );
            break;
          case TipoNoFluxo.conteudoDinamico:
          case TipoNoFluxo.inicio:
          case TipoNoFluxo.apresentacao:
          case TipoNoFluxo.formulario:
          case TipoNoFluxo.condicao:
          case TipoNoFluxo.fim:
            break;
        }
      }

      if (_noConcluiFluxo(rowAtual) || status == StatusExecucao.concluida) {
        status = StatusExecucao.concluida;
        break;
      }

      final arestaSaida = await _buscarArestaSaida(
        sessao.idFluxoAtualPk,
        rowAtual[NoFluxo.idCol] as int,
      );
      if (arestaSaida == null) {
        status = StatusExecucao.concluida;
        break;
      }

      final proximoNo =
          await _buscarNoPorPk(arestaSaida[ArestaFluxo.idNoDestinoCol] as int);
      if (proximoNo == null) {
        throw StateError('Próximo nó automático não encontrado.');
      }
      rowAtual = proximoNo;
    }

    return _ResultadoProcessamentoAutomatico(
      rowNoAtual: rowAtual,
      status: status,
      registroSubmissao: registroSubmissao,
    );
  }

  bool _noConcluiFluxo(Map<String, dynamic> rowNo) {
    final tipoNo = rowNo[NoFluxo.tipoNoCol] as String;
    if (tipoNo == TipoNoFluxo.fim.val) {
      return true;
    }
    if (tipoNo != TipoNoFluxo.conteudoDinamico.val) {
      return false;
    }

    final dadosJson = JsonUtils.lerMapa(rowNo[NoFluxo.dadosJsonCol]);
    return dadosJson['finaliza_fluxo'] == true;
  }

  Future<StatusExecucao> _executarConteudoDinamico({
    required int sessaoPk,
    required int idNoFluxoPk,
    required Map<String, dynamic> rowNo,
    required Map<String, dynamic> contextoAtual,
  }) async {
    final no = await _construirNo(rowNo);
    final resultado = await _executorConteudoDinamicoService.executar(
      no: no,
      contexto: contextoAtual,
    );

    final resultadosIntegracao = Map<String, dynamic>.from(
      JsonUtils.lerMapa(contextoAtual['resultados_integracao']),
    );
    resultadosIntegracao[no.id] = resultado;
    contextoAtual['resultados_integracao'] = resultadosIntegracao;

    final persistencia = ResultadoNoSessao(
      id: 0,
      idSessaoExecucao: sessaoPk,
      idNoFluxo: idNoFluxoPk,
      status: resultado['sucesso'] == true ? 'concluido' : 'falhou',
      payloadRequisicaoJson: jsonEncode(resultado['requisicao']),
      payloadRespostaJson: jsonEncode(resultado['resposta']),
      mensagemErro: resultado['mensagem_erro']?.toString(),
    );
    await db.table(ResultadoNoSessao.fqtn).insert(
          persistencia.toInsertMap(),
        );

    if (_noConcluiFluxo(rowNo)) {
      return StatusExecucao.concluida;
    }
    return StatusExecucao.emAndamento;
  }

  Future<_ResultadoSubmissaoGarantida> _garantirSubmissao({
    required int sessaoPk,
    required int idServicoPk,
    required int idVersaoPk,
    required String idServicoPublico,
    required String idVersaoPublico,
    required Map<String, dynamic> contextoAtual,
  }) async {
    var row = await db
        .table(Submissao.fqtn)
        .where(Submissao.idSessaoExecucaoCol, Operator.equal, sessaoPk)
        .first();
    var registro = await _buscarRegistroSubmissao(
      sessaoPk,
      idServicoPublico,
      idVersaoPublico,
    );

    if (row == null) {
      registro = await _registrarSubmissaoSeNecessario(
        sessaoPk: sessaoPk,
        idServicoPk: idServicoPk,
        idVersaoPk: idVersaoPk,
        idServicoPublico: idServicoPublico,
        idVersaoPublico: idVersaoPublico,
        contextoAtual: contextoAtual,
      );
      row = await db
          .table(Submissao.fqtn)
          .where(Submissao.idSessaoExecucaoCol, Operator.equal, sessaoPk)
          .first();
    }

    if (row == null || registro == null) {
      throw StateError('Falha ao garantir submissão para a sessão $sessaoPk.');
    }

    return _ResultadoSubmissaoGarantida(
      submissao: Submissao.fromMap(row),
      registroSubmissao: registro,
    );
  }

  Future<void> _executarNoTarefaInterna({
    required int idSubmissaoPk,
    required Map<String, dynamic> rowNo,
  }) async {
    final dados = DadosNoTarefaInterna.fromMap(
        JsonUtils.lerMapa(rowNo[NoFluxo.dadosJsonCol]));
    final idNoFluxo = rowNo[NoFluxo.idCol] as int;
    final existente = await db
        .table(TarefaInterna.fqtn)
        .where(TarefaInterna.idSubmissaoCol, Operator.equal, idSubmissaoPk)
        .where(TarefaInterna.idNoFluxoCol, Operator.equal, idNoFluxo)
        .whereIn(TarefaInterna.statusCol,
            const <String>['aberta', 'em_andamento', 'bloqueada']).first();
    if (existente != null) {
      return;
    }

    await db.transaction((Connection ctx) async {
      final idTarefa = await ctx.table(TarefaInterna.fqtn).insertGetId(
            TarefaInterna(
              id: 0,
              idSubmissao: idSubmissaoPk,
              idNoFluxo: idNoFluxo,
              titulo: dados.titulo,
              descricao: dados.descricao,
              prioridade: dados.prioridade,
              status: 'aberta',
              atualizadoEm: DateTime.now(),
            ).toInsertMap(),
            TarefaInterna.idCol,
          ) as int;

      await ctx.table(TransicaoTarefa.fqtn).insert(
            TransicaoTarefa(
              id: 0,
              idTarefa: idTarefa,
              novoStatus: 'aberta',
              motivo:
                  'Tarefa criada automaticamente pelo runtime institucional.',
            ).toInsertMap(),
          );
    });
  }

  Future<void> _executarNoAtualizacaoStatus({
    required int idSubmissaoPk,
    required Map<String, dynamic> rowNo,
  }) async {
    final dados = DadosNoAtualizacaoStatus.fromMap(
        JsonUtils.lerMapa(rowNo[NoFluxo.dadosJsonCol]));
    final rowSubmissao = await db
        .table(Submissao.fqtn)
        .select([Submissao.statusFqCol])
        .where(Submissao.idCol, Operator.equal, idSubmissaoPk)
        .first();
    final statusAnterior =
        rowSubmissao?[Submissao.statusCol] as String? ?? 'submetida';
    if (statusAnterior == dados.novoStatus) {
      return;
    }

    await db.transaction((Connection ctx) async {
      await ctx
          .table(Submissao.fqtn)
          .where(Submissao.idCol, Operator.equal, idSubmissaoPk)
          .update(
        <String, dynamic>{
          Submissao.statusCol: dados.novoStatus,
          'atualizado_em': DateTime.now().toIso8601String(),
        },
      );

      await ctx.table(HistoricoStatusSubmissao.fqtn).insert(
            HistoricoStatusSubmissao(
              id: 0,
              idSubmissao: idSubmissaoPk,
              statusAnterior: statusAnterior,
              novoStatus: dados.novoStatus,
              motivo: dados.motivo,
              metadadosJson: jsonEncode(<String, dynamic>{
                'origem': 'runtime_fluxo',
                'id_no_fluxo': rowNo[NoFluxo.idCol],
                'chave_no': rowNo[NoFluxo.chaveNoCol],
              }),
            ).toInsertMap(),
          );
    });
  }

  Future<void> _executarNoPontuacao({
    required _SessaoInterna sessao,
    required int idSubmissaoPk,
    required Map<String, dynamic> rowNo,
    required Map<String, dynamic> contextoAtual,
  }) async {
    final dados = DadosNoPontuacao.fromMap(
        JsonUtils.lerMapa(rowNo[NoFluxo.dadosJsonCol]));
    final versaoConjuntoRegras = await _buscarVersaoConjuntoRegras(
      idServicoPk: sessao.idServicoPk,
      idVersaoConjuntoRegras: dados.idVersaoConjuntoRegras,
    );
    if (versaoConjuntoRegras == null) {
      throw StateError(
          'Serviço sem versão publicada de conjunto de regras para pontuação.');
    }

    final resultado = await _avaliarPontuacaoIndividual(
      contextoAtual: contextoAtual,
      versaoConjuntoRegras: versaoConjuntoRegras,
    );
    final contextoEdicao = Map<String, dynamic>.from(
        JsonUtils.lerMapa(contextoAtual['contexto_edicao']));
    contextoEdicao[dados.chaveResultado] = resultado;
    contextoAtual['contexto_edicao'] = contextoEdicao;

    await db
        .table(Submissao.fqtn)
        .where(Submissao.idCol, Operator.equal, idSubmissaoPk)
        .update(
      <String, dynamic>{
        Submissao.idVersaoConjuntoRegrasCol: versaoConjuntoRegras.id,
        Submissao.snapshotRankingJsonCol: jsonEncode(resultado),
        'atualizado_em': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _executarNoClassificacao({
    required _SessaoInterna sessao,
    required int idSubmissaoPk,
    required Map<String, dynamic> rowNo,
    required Map<String, dynamic> contextoAtual,
  }) async {
    final dados = DadosNoClassificacao.fromMap(
        JsonUtils.lerMapa(rowNo[NoFluxo.dadosJsonCol]));
    final identificadorServico = await _buscarCodigoServico(sessao.idServicoPk);
    final resumo = await _operacaoPort.executarClassificacao(
      RequisicaoExecutarClassificacao(
        idServico: identificadorServico,
        idVersaoServico: sessao.idVersaoPublico,
        idVersaoConjuntoRegras: dados.idVersaoConjuntoRegras,
        notas: dados.notas ??
            'Execução disparada automaticamente pelo runtime do serviço.',
      ),
    );

    final rowSubmissao = await db
        .table(Submissao.fqtn)
        .select([
          Submissao.statusFqCol,
          '${Submissao.fqtb}.${Submissao.snapshotRankingJsonCol} as snapshot_ranking_json',
        ])
        .where(Submissao.idCol, Operator.equal, idSubmissaoPk)
        .first();

    final contextoEdicao = Map<String, dynamic>.from(
        JsonUtils.lerMapa(contextoAtual['contexto_edicao']));
    contextoEdicao['classificacao'] = resumo.toMap();
    contextoEdicao['resultado_submissao'] = <String, dynamic>{
      'status': rowSubmissao?[Submissao.statusCol] as String? ?? 'submetida',
      'ranking':
          JsonUtils.lerMapa(rowSubmissao?[Submissao.snapshotRankingJsonCol]),
    };
    contextoAtual['contexto_edicao'] = contextoEdicao;
  }

  Future<String> _buscarCodigoServico(int idServicoPk) async {
    final rowServico = await db
        .table(Servico.fqtn)
        .select([Servico.codigoFqCol])
        .where(Servico.idCol, Operator.equal, idServicoPk)
        .first();
    if (rowServico == null) {
      throw StateError(
          'Serviço não encontrado para classificação automática: $idServicoPk');
    }
    return rowServico[Servico.codigoCol] as String;
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
          .join(
            ConjuntoRegras.fqtn,
            ConjuntoRegras.idFqCol,
            '=',
            VersaoConjuntoRegras.idConjuntoRegrasFqCol,
          )
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
      final numeroVersao =
          IdentificadorBindingUtils.inteiroOuNull(idVersaoConjuntoRegras);

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

  Future<Map<String, dynamic>> _avaliarPontuacaoIndividual({
    required Map<String, dynamic> contextoAtual,
    required VersaoConjuntoRegras versaoConjuntoRegras,
  }) async {
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
    final contexto = _normalizarContextoClassificacao(contextoAtual);

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
      'pontuacao_final': pontuacao,
      'elegivel': falhasElegibilidade.isEmpty,
      'falhas_elegibilidade': falhasElegibilidade,
      'pontuacoes_aplicadas': pontuacoesAplicadas,
      'id_versao_conjunto_regras':
          versaoConjuntoRegras.idPublico ?? '${versaoConjuntoRegras.id}',
    };
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

  Future<RegistroSubmissao?> _registrarSubmissaoSeNecessario({
    required int sessaoPk,
    required int idServicoPk,
    required int idVersaoPk,
    required String idServicoPublico,
    required String idVersaoPublico,
    required Map<String, dynamic> contextoAtual,
  }) async {
    final existente = await _buscarRegistroSubmissao(
        sessaoPk, idServicoPublico, idVersaoPublico);
    if (existente != null) {
      return existente;
    }

    return await db.transaction((Connection ctx) async {
      final submissaoId = await ctx.table(Submissao.fqtn).insertGetId(
            Submissao(
              id: 0,
              idServico: idServicoPk,
              idVersaoServico: idVersaoPk,
              idSessaoExecucao: sessaoPk,
              status: 'submetida',
              snapshotJson: jsonEncode(contextoAtual),
            ).toInsertMap(),
            Submissao.idCol,
          ) as int;

      final submissaoRow = await ctx
          .table(Submissao.fqtn)
          .where(Submissao.idCol, Operator.equal, submissaoId)
          .first();
      final submissao = Submissao.fromMap(submissaoRow!);
      final numeroProtocolo =
          ProtocoloUtils.gerarNumeroProtocolo(submissaoId, DateTime.now());
      final codigoPublico = ProtocoloUtils.gerarCodigoPublico(
          submissao.idPublico ?? '$submissaoId');

      await ctx.table(Protocolo.fqtn).insert(
            Protocolo(
              id: 0,
              idSubmissao: submissaoId,
              numeroProtocolo: numeroProtocolo,
              codigoPublico: codigoPublico,
            ).toInsertMap(),
          );

      return RegistroSubmissao(
        id: submissao.idPublico ?? '$submissaoId',
        idServico: idServicoPublico,
        idVersaoServico: idVersaoPublico,
        numeroProtocolo: numeroProtocolo,
        criadoEm: DateTime.now(),
        snapshot: contextoAtual,
      );
    });
  }

  Future<RegistroSubmissao?> _buscarRegistroSubmissao(
    int sessaoPk,
    String idServicoPublico,
    String idVersaoPublico,
  ) async {
    final row = await db
        .table(Submissao.fqtn)
        .select([
          '${Submissao.fqtn}.${Submissao.idPublicoCol} as submissao_id_publico',
          '${Submissao.fqtn}.${Submissao.snapshotJsonCol} as snapshot_json',
          '${Protocolo.fqtn}.${Protocolo.numeroProtocoloCol} as numero_protocolo',
          '${Protocolo.fqtn}.criado_em as criado_em',
        ])
        .join(
          Protocolo.fqtn,
          Protocolo.idSubmissaoFqCol,
          '=',
          Submissao.idFqCol,
        )
        .where(Submissao.idSessaoExecucaoCol, Operator.equal, sessaoPk)
        .first();
    if (row == null) {
      return null;
    }

    return RegistroSubmissao(
      id: row['submissao_id_publico'].toString(),
      idServico: idServicoPublico,
      idVersaoServico: idVersaoPublico,
      numeroProtocolo: row['numero_protocolo'] as String,
      criadoEm: row['criado_em'] is DateTime
          ? row['criado_em'] as DateTime
          : DateTime.tryParse(row['criado_em'].toString()) ?? DateTime.now(),
      snapshot: JsonUtils.lerMapa(row['snapshot_json']),
    );
  }
}
