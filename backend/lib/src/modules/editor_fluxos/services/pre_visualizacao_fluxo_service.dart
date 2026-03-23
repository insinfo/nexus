import 'package:nexus_core/nexus_core.dart';

import '../../runtime/services/avaliador_condicao_service.dart';
import 'fluxo_invalido_exception.dart';
import 'resolvedor_conteudo_dinamico_preview_service.dart';
import 'validador_fluxo_service.dart';

class PreVisualizacaoFluxoService {
  PreVisualizacaoFluxoService(
    this._validadorFluxoService,
    this._avaliadorCondicaoService,
    this._resolvedorConteudoDinamicoPreviewService,
  );

  final ValidadorFluxoService _validadorFluxoService;
  final AvaliadorCondicaoService _avaliadorCondicaoService;
  final ResolvedorConteudoDinamicoPreviewService
      _resolvedorConteudoDinamicoPreviewService;

  Future<ResultadoPreVisualizacaoFluxo> preVisualizar(
    RequisicaoPreVisualizacaoFluxo requisicao,
  ) async {
    final resultadoValidacao = _validadorFluxoService.validar(requisicao.fluxo);
    if (!resultadoValidacao.valido) {
      throw FluxoInvalidoException(resultadoValidacao);
    }

    final nosPorId = <String, NoFluxoDto>{
      for (final no in requisicao.fluxo.nos) no.id: no,
    };
    final contextoAtual = Map<String, dynamic>.from(requisicao.contexto);
    final respostasContexto = Map<String, dynamic>.from(
      (contextoAtual['respostas'] as Map?) ?? const <String, dynamic>{},
    );
    respostasContexto.addAll(requisicao.respostas);
    contextoAtual['respostas'] = respostasContexto;

    if (requisicao.idNoAtual == null || requisicao.idNoAtual!.isEmpty) {
      final noInicio = requisicao.fluxo.nos.firstWhere(
        (no) => no.tipo == TipoNoFluxo.inicio,
      );
      final proximoNo = _resolverProximoNo(
        fluxo: requisicao.fluxo,
        noAtual: noInicio,
        respostasContexto: respostasContexto,
      );
      await _executarNoSeNecessario(proximoNo.no, contextoAtual);
      return ResultadoPreVisualizacaoFluxo(
        idNoOrigem: noInicio.id,
        noAtual: proximoNo.no,
        status: proximoNo.status,
        contexto: contextoAtual,
      );
    }

    final noAtual = nosPorId[requisicao.idNoAtual];
    if (noAtual == null) {
      throw StateError('No atual nao encontrado: ${requisicao.idNoAtual}');
    }

    if (noAtual.tipo == TipoNoFluxo.conteudoDinamico) {
      await _executarNoSeNecessario(noAtual, contextoAtual);
    }

    if (_deveConcluirNoAtual(noAtual)) {
      return ResultadoPreVisualizacaoFluxo(
        idNoOrigem: noAtual.id,
        noAtual: noAtual,
        status: StatusExecucao.concluida,
        contexto: contextoAtual,
      );
    }

    final proximoNo = _resolverProximoNo(
      fluxo: requisicao.fluxo,
      noAtual: noAtual,
      respostasContexto: respostasContexto,
    );
    await _executarNoSeNecessario(proximoNo.no, contextoAtual);
    return ResultadoPreVisualizacaoFluxo(
      idNoOrigem: noAtual.id,
      noAtual: proximoNo.no,
      status: proximoNo.status,
      contexto: contextoAtual,
    );
  }

  _ResultadoResolucaoNo _resolverProximoNo({
    required FluxoDto fluxo,
    required NoFluxoDto noAtual,
    required Map<String, dynamic> respostasContexto,
  }) {
    if (_deveConcluirNoAtual(noAtual)) {
      return _ResultadoResolucaoNo(
        no: noAtual,
        status: StatusExecucao.concluida,
      );
    }

    final handleSaida = _resolverHandleSaida(noAtual, respostasContexto);
    final arestaSaida = fluxo.arestas.firstWhere(
      (aresta) =>
          aresta.origem == noAtual.id &&
          (handleSaida == null || aresta.handleOrigem == handleSaida),
      orElse: () => ArestaFluxoDto(
        id: '',
        origem: '',
        destino: '',
      ),
    );

    if (arestaSaida.id.isEmpty) {
      return _ResultadoResolucaoNo(
        no: noAtual,
        status: StatusExecucao.concluida,
      );
    }

    final proximoNo =
        fluxo.nos.firstWhere((item) => item.id == arestaSaida.destino);
    return _ResultadoResolucaoNo(
      no: proximoNo,
      status: _deveConcluirNoAtual(proximoNo)
          ? StatusExecucao.concluida
          : StatusExecucao.emAndamento,
    );
  }

  String? _resolverHandleSaida(
    NoFluxoDto noAtual,
    Map<String, dynamic> respostasContexto,
  ) {
    if (noAtual.tipo != TipoNoFluxo.condicao) {
      return null;
    }

    final dados = noAtual.dados as DadosNoCondicao;
    final resultado = _avaliadorCondicaoService.avaliarExpressaoJson(
      dados.expressao,
      respostasContexto,
    );
    return resultado ? dados.handleVerdadeiro : dados.handleFalso;
  }

  bool _deveConcluirNoAtual(NoFluxoDto noAtual) {
    if (noAtual.tipo == TipoNoFluxo.fim) {
      return true;
    }
    if (noAtual.tipo != TipoNoFluxo.conteudoDinamico) {
      return false;
    }

    final dados = noAtual.dados as DadosNoConteudoDinamico;
    return dados.finalizaFluxo;
  }

  Future<void> _executarNoSeNecessario(
    NoFluxoDto noAtual,
    Map<String, dynamic> contextoAtual,
  ) async {
    if (noAtual.tipo != TipoNoFluxo.conteudoDinamico) {
      return;
    }

    final resultadosIntegracao = Map<String, dynamic>.from(
      (contextoAtual['resultados_integracao'] as Map?) ??
          const <String, dynamic>{},
    );
    resultadosIntegracao[noAtual.id] =
        await _resolvedorConteudoDinamicoPreviewService.resolver(
      no: noAtual,
      contexto: contextoAtual,
    );
    contextoAtual['resultados_integracao'] = resultadosIntegracao;
  }
}

class _ResultadoResolucaoNo {
  const _ResultadoResolucaoNo({
    required this.no,
    required this.status,
  });

  final NoFluxoDto no;
  final StatusExecucao status;
}
