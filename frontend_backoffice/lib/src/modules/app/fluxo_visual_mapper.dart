import 'package:dart_flow/dart_flow.dart';
import 'package:nexus_core/nexus_core.dart';

List<FlowNode> mapearNosFluxoParaCanvas(List<NoFluxoDto> nos) {
  return nos
      .map(
        (no) => FlowNode(
          id: no.id,
          type: no.tipo.val,
          position: XYPosition(x: no.posicao.x, y: no.posicao.y),
          width: no.largura ?? 220,
          height: no.altura ?? _alturaNo(no),
          sourcePosition: Position.right,
          targetPosition: Position.left,
          handles: _handlesParaNo(no),
          data: <String, Object?>{
            'label': _rotuloDoNo(no),
            'subtitle': _subtituloDoNo(no),
            'tipo_no': no.tipo.val,
            'dados': no.dados.toMap(),
          },
        ),
      )
      .toList(growable: false);
}

List<FlowEdge> mapearArestasFluxoParaCanvas(List<ArestaFluxoDto> arestas) {
  return arestas
      .map(
        (aresta) => FlowEdge(
          id: aresta.id,
          source: aresta.origem,
          target: aresta.destino,
          sourceHandle: aresta.handleOrigem,
          targetHandle: aresta.handleDestino,
          label: aresta.rotulo,
          type: ConnectionLineType.smoothStep,
        ),
      )
      .toList(growable: false);
}

NoFluxoDto criarNoFluxoPadrao(TipoNoFluxo tipo, int indice) {
  final chaveBase = _chavePadrao(tipo, indice);
  return NoFluxoDto(
    id: chaveBase,
    tipo: tipo,
    posicao: PosicaoXY(x: 120 + (indice * 48), y: 120 + (indice * 28)),
    largura: 220,
    altura: _alturaTipo(tipo),
    dados: _dadosPadrao(tipo, chaveBase),
  );
}

NoFluxoDto criarNoFluxoAPartirDoCanvas(FlowNode node, int indice) {
  final tipo = _tipoNoDoCanvas(node);
  final dadosBrutos = node.data['dados'];
  final dados = dadosBrutos is Map<String, dynamic>
      ? dadosBrutos
      : dadosBrutos is Map
          ? Map<String, dynamic>.from(dadosBrutos)
          : _dadosPadrao(tipo, node.id).toMap();

  return NoFluxoDto(
    id: node.id,
    tipo: tipo,
    posicao: PosicaoXY(x: node.position.x, y: node.position.y),
    largura: node.width,
    altura: node.height,
    dados: dadosNoFluxoFromMap(tipo: tipo, mapa: dados),
  );
}

bool perguntaAceitaOpcoes(TipoCampoFormulario tipo) {
  return tipo == TipoCampoFormulario.selecao ||
      tipo == TipoCampoFormulario.multiplaSelecao;
}

TipoNoFluxo _tipoNoDoCanvas(FlowNode node) {
  final tipo = node.type ??
      node.data['tipo_no']?.toString() ??
      TipoNoFluxo.apresentacao.val;
  return TipoNoFluxo.parse(tipo);
}

double _alturaNo(NoFluxoDto no) {
  return no.altura ?? _alturaTipo(no.tipo);
}

double _alturaTipo(TipoNoFluxo tipo) {
  switch (tipo) {
    case TipoNoFluxo.formulario:
      return 88;
    case TipoNoFluxo.condicao:
      return 72;
    case TipoNoFluxo.conteudoDinamico:
      return 72;
    default:
      return 60;
  }
}

String _chavePadrao(TipoNoFluxo tipo, int indice) {
  switch (tipo) {
    case TipoNoFluxo.inicio:
      return 'inicio_${indice + 1}';
    case TipoNoFluxo.apresentacao:
      return 'apresentacao_${indice + 1}';
    case TipoNoFluxo.formulario:
      return 'formulario_${indice + 1}';
    case TipoNoFluxo.conteudoDinamico:
      return 'conteudo_${indice + 1}';
    case TipoNoFluxo.condicao:
      return 'condicao_${indice + 1}';
    case TipoNoFluxo.fim:
      return 'fim_${indice + 1}';
    case TipoNoFluxo.tarefaInterna:
      return 'tarefa_${indice + 1}';
    case TipoNoFluxo.atualizacaoStatus:
      return 'status_${indice + 1}';
    case TipoNoFluxo.pontuacao:
      return 'pontuacao_${indice + 1}';
    case TipoNoFluxo.classificacao:
      return 'classificacao_${indice + 1}';
  }
}

DadosNoFluxo _dadosPadrao(TipoNoFluxo tipo, String chave) {
  final rotulo = '${tipo.label} ${chave.split('_').last}';
  switch (tipo) {
    case TipoNoFluxo.inicio:
      return DadosNoInicio(rotulo: rotulo);
    case TipoNoFluxo.apresentacao:
      return DadosNoApresentacao(
        rotulo: rotulo,
        conteudoApresentacao: DocumentoConteudoRico(
          blocos: <BlocoConteudoRico>[
            BlocoConteudoRico(
                tipo: 'paragrafo', dados: <String, dynamic>{'texto': ''}),
          ],
        ),
      );
    case TipoNoFluxo.formulario:
      return DadosNoFormulario(
          rotulo: rotulo, perguntas: const <DefinicaoPergunta>[]);
    case TipoNoFluxo.conteudoDinamico:
      return DadosNoConteudoDinamico(
        rotulo: rotulo,
        metodo: 'GET',
        url: '',
        modeloConteudo: DocumentoConteudoRico(
          blocos: <BlocoConteudoRico>[
            BlocoConteudoRico(
                tipo: 'paragrafo', dados: <String, dynamic>{'texto': ''}),
          ],
        ),
      );
    case TipoNoFluxo.condicao:
      return DadosNoCondicao(rotulo: rotulo, expressao: '{}');
    case TipoNoFluxo.fim:
      return DadosNoFim(rotulo: rotulo);
    case TipoNoFluxo.tarefaInterna:
      return DadosNoTarefaInterna(
        rotulo: rotulo,
        titulo: 'Tarefa interna ${chave.split('_').last}',
      );
    case TipoNoFluxo.atualizacaoStatus:
      return DadosNoAtualizacaoStatus(
        rotulo: rotulo,
        novoStatus: 'em_analise',
      );
    case TipoNoFluxo.pontuacao:
      return DadosNoPontuacao(rotulo: rotulo);
    case TipoNoFluxo.classificacao:
      return DadosNoClassificacao(rotulo: rotulo);
  }
}

String _rotuloDoNo(NoFluxoDto no) {
  final dados = no.dados.toMap();
  return dados['rotulo']?.toString() ?? no.tipo.label;
}

String _subtituloDoNo(NoFluxoDto no) {
  switch (no.tipo) {
    case TipoNoFluxo.formulario:
      final dados = no.dados as DadosNoFormulario;
      return '${dados.perguntas.length} campo(s)';
    case TipoNoFluxo.condicao:
      final dados = no.dados as DadosNoCondicao;
      return dados.expressao;
    case TipoNoFluxo.conteudoDinamico:
      final dados = no.dados as DadosNoConteudoDinamico;
      return dados.url.isEmpty ? 'Sem endpoint' : dados.url;
    case TipoNoFluxo.tarefaInterna:
      final dados = no.dados as DadosNoTarefaInterna;
      return dados.titulo;
    case TipoNoFluxo.atualizacaoStatus:
      final dados = no.dados as DadosNoAtualizacaoStatus;
      return dados.novoStatus;
    case TipoNoFluxo.pontuacao:
      final dados = no.dados as DadosNoPontuacao;
      return dados.idVersaoConjuntoRegras?.isNotEmpty == true
          ? 'Regras ${dados.idVersaoConjuntoRegras}'
          : 'Versão publicada';
    case TipoNoFluxo.classificacao:
      final dados = no.dados as DadosNoClassificacao;
      return dados.idVersaoConjuntoRegras?.isNotEmpty == true
          ? 'Regras ${dados.idVersaoConjuntoRegras}'
          : 'Classificação auditável';
    default:
      return no.tipo.label;
  }
}

List<FlowHandle> _handlesParaNo(NoFluxoDto no) {
  switch (no.tipo) {
    case TipoNoFluxo.inicio:
      return const <FlowHandle>[
        FlowHandle(
          id: 'saida',
          type: HandleType.source,
          position: Position.right,
          x: 220,
          y: 30,
        ),
      ];
    case TipoNoFluxo.fim:
      return const <FlowHandle>[
        FlowHandle(
          id: 'entrada',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 30,
        ),
      ];
    case TipoNoFluxo.condicao:
      final dados = no.dados as DadosNoCondicao;
      return <FlowHandle>[
        const FlowHandle(
          id: 'entrada',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 36,
        ),
        FlowHandle(
          id: dados.handleVerdadeiro,
          type: HandleType.source,
          position: Position.right,
          x: 220,
          y: 22,
        ),
        FlowHandle(
          id: dados.handleFalso,
          type: HandleType.source,
          position: Position.right,
          x: 220,
          y: 50,
        ),
      ];
    default:
      return const <FlowHandle>[
        FlowHandle(
          id: 'entrada',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 30,
        ),
        FlowHandle(
          id: 'saida',
          type: HandleType.source,
          position: Position.right,
          x: 220,
          y: 30,
        ),
      ];
  }
}
