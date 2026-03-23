import 'dart:convert';
import 'dart:html';

import 'package:dart_flow/dart_flow.dart';
import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:nexus_core/nexus_core.dart';

import 'package:nexus_frontend_backoffice/src/modules/app/fluxo_visual_mapper.dart';
import 'package:nexus_frontend_backoffice/src/modules/editorial/pages/editorial/editorial_page.dart';

@Component(
  selector: 'main-page',
  templateUrl: 'main_page.html',
  styleUrls: <String>['main_page.css'],
  directives: <Object>[
    coreDirectives,
    DatatableComponent,
    NgFlowComponent,
    BackgroundComponent,
    ControlsComponent,
    MiniMapComponent,
    PanelComponent,
    EditorialPage,
  ],
)
class MainPage implements OnInit {
  MainPage()
      : workQueueFilters = Filters(limit: 12, offset: 0),
        rankingFilters = Filters(limit: 12, offset: 0),
        publicationFilters = Filters(limit: 12, offset: 0),
        editorFluxoJson = '',
        contextoPreviewJson =
            '{\n  "respostas": {},\n  "variaveis": {},\n  "resultados_integracao": {}\n}',
        respostasPreviewJson = '{}';

  static const String _apiBaseUrl = 'http://127.0.0.1:8086/api/v1';

  final Filters workQueueFilters;
  final Filters rankingFilters;
  final Filters publicationFilters;

  String currentSection = 'servicos';
  bool servicesLoading = false;
  bool builderLoading = false;
  bool operationLoading = false;
  bool operationDetailLoading = false;
  bool operationActionLoading = false;
  String? servicesError;
  String? builderError;
  String? operationError;
  String? operationActionMessage;
  List<ResumoServico> services = <ResumoServico>[];
  List<ResumoSubmissaoOperacao> operationSubmissions =
      <ResumoSubmissaoOperacao>[];
  List<ResumoResultadoClassificacao> classificacaoResultados =
      <ResumoResultadoClassificacao>[];
  ServicoDto? builderService;
  FluxoDto? fluxoEmEdicao;
  List<ResumoVersaoServico> builderVersions = <ResumoVersaoServico>[];
  List<ResumoFluxo> builderFlows = <ResumoFluxo>[];
  List<FlowNode> builderCanvasNodes = const <FlowNode>[];
  List<FlowEdge> builderCanvasEdges = const <FlowEdge>[];
  String? selectedBuilderServiceId;
  String? selectedBuilderVersionId;
  String? selectedBuilderFlowId;
  String? selectedOperationSubmissionId;
  String? selectedOperationServiceId;
  String editorFluxoJson;
  String contextoPreviewJson;
  String respostasPreviewJson;
  bool validationLoading = false;
  bool previewLoading = false;
  bool saveDraftLoading = false;
  bool publishVersionLoading = false;
  String? validationMessage;
  String? previewError;
  String? saveDraftMessage;
  String? publishVersionMessage;
  ResultadoValidacaoFluxo? validationResult;
  ResultadoPreVisualizacaoFluxo? previewResult;
  Map<String, dynamic>? operationDetail;

  late final DatatableSettings workQueueSettings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'titulo', title: 'Fila de trabalho'),
      DatatableCol(key: 'departamento', title: 'Órgão'),
      DatatableCol(key: 'servico', title: 'Serviço'),
      DatatableCol(
        key: 'status',
        title: 'Status',
        customRenderString: (Map<String, dynamic> itemMap, dynamic _) {
          final status = itemMap['status']?.toString() ?? '';
          return _renderStatusBadge(status);
        },
      ),
      DatatableCol(key: 'responsavel', title: 'Responsável'),
      DatatableCol(key: 'prazo', title: 'Prazo'),
    ],
  );

  late final DatatableSettings rankingSettings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'numero_protocolo', title: 'Protocolo'),
      DatatableCol(key: 'nome_servico', title: 'Serviço'),
      DatatableCol(key: 'pontuacao_final', title: 'Pontuação'),
      DatatableCol(key: 'posicao_final', title: 'Posição'),
      DatatableCol(
        key: 'elegivel',
        title: 'Elegível',
        customRenderString: (Map<String, dynamic> itemMap, dynamic _) {
          final elegivel = itemMap['elegivel'] == true;
          final cssClass = elegivel ? 'bg-success' : 'bg-danger';
          final texto = elegivel ? 'Elegível' : 'Inelegível';
          return '<span class="badge $cssClass">$texto</span>';
        },
      ),
    ],
  );

  late final DatatableSettings publicationSettings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'titulo', title: 'Publicação'),
      DatatableCol(
        key: 'tipo',
        title: 'Tipo',
        customRenderString: (Map<String, dynamic> itemMap, dynamic _) {
          final tipo = TipoPublicacao.tryParse(itemMap['tipo']?.toString());
          return tipo?.label ?? (itemMap['tipo']?.toString() ?? '');
        },
      ),
      DatatableCol(key: 'area', title: 'Área editorial'),
      DatatableCol(
        key: 'status',
        title: 'Status',
        customRenderString: (Map<String, dynamic> itemMap, dynamic _) {
          final status = itemMap['status']?.toString() ?? '';
          return _renderPublicationBadge(status);
        },
      ),
      DatatableCol(
        key: 'publicacao_em',
        title: 'Publicação',
        format: DatatableFormat.dateTimeShort,
      ),
    ],
  );

  DadosPainelRetaguarda get dashboard => DadosPainelRetaguarda(
        titulo: 'Central de operacao Nexus',
        subtitulo:
            'Catalogo, builder visual, operacao e publicacao conectados ao backend com contratos de dominio em portugues.',
        metricas: <CardMetrica>[
          CardMetrica(
            id: 'metric-servicos',
            rotulo: 'Servicos publicados',
            valor: '${services.length}',
            rotuloDelta:
                '${builderVersions.length} versoes carregadas no builder',
            icone: 'ph-rocket-launch',
          ),
          CardMetrica(
            id: 'metric-fluxos',
            rotulo: 'Fluxos modelados',
            valor: '${builderFlows.length}',
            rotuloDelta: 'Canvas visual sincronizado com o schema do core',
            icone: 'ph-share-network',
          ),
          CardMetrica(
            id: 'metric-editorial',
            rotulo: 'Fila operacional',
            valor: '${operationSubmissions.length}',
            rotuloDelta: classificacaoResultados.isEmpty
                ? 'Operação institucional conectada ao backend'
                : '${classificacaoResultados.length} resultado(s) de classificação carregados',
            icone: 'ph-newspaper-clipping',
          ),
        ],
        filaTrabalho: operationSubmissions
            .map(_mapearResumoOperacaoParaFila)
            .toList(growable: false),
        nosBuilder: _resumoNosBuilder,
        publicacoesPendentes: const <PublicacaoOficial>[],
      );

  DataFrame<Map<String, dynamic>> get workQueueTable =>
      DataFrame<Map<String, dynamic>>(
        items: operationSubmissions
            .map(
              (ResumoSubmissaoOperacao item) => <String, dynamic>{
                'titulo': 'Protocolo ${item.numeroProtocolo}',
                'departamento':
                    _departamentoPorCodigoServico(item.codigoServico),
                'servico': item.codigoServico,
                'status': _statusRetaguarda(item.status).val,
                'responsavel': item.possuiTarefaAberta
                    ? 'Fila interna ativa'
                    : 'Aguardando distribuição',
                'prazo':
                    _rotuloPrazoOperacao(item.atualizadoEm ?? item.criadoEm),
              },
            )
            .toList(growable: false),
        totalRecords: operationSubmissions.length,
      );

  DataFrame<Map<String, dynamic>> get rankingTable =>
      DataFrame<Map<String, dynamic>>(
        items: classificacaoResultados
            .map(
              (ResumoResultadoClassificacao item) => <String, dynamic>{
                'numero_protocolo': item.numeroProtocolo,
                'nome_servico': item.nomeServico,
                'pontuacao_final': item.pontuacaoFinal,
                'posicao_final': item.posicaoFinal?.toString() ?? '-',
                'elegivel': item.elegivel,
              },
            )
            .toList(growable: false),
        totalRecords: classificacaoResultados.length,
      );

  DataFrame<Map<String, dynamic>> get publicationTable =>
      DataFrame<Map<String, dynamic>>(
        items: dashboard.publicacoesPendentes
            .map(
              (PublicacaoOficial item) => <String, dynamic>{
                'titulo': item.titulo,
                'tipo': item.tipo.val,
                'area': item.areaEditorial,
                'status': item.status.val,
                'publicacao_em': item.publicadoEm,
              },
            )
            .toList(growable: false),
        totalRecords: dashboard.publicacoesPendentes.length,
      );

  int get publishedFlowCount => builderFlows.length;

  bool get isServicesSection => currentSection == 'servicos';

  bool get isBuilderSection => currentSection == 'builder';

  bool get isOperationSection => currentSection == 'operacao';

  bool get isEditorialSection => currentSection == 'editorial';

  ResumoSubmissaoOperacao? get selectedOperationSubmission {
    final selectedId = selectedOperationSubmissionId;
    if (selectedId == null) {
      return operationSubmissions.firstOrNull;
    }
    for (final item in operationSubmissions) {
      if (item.idSubmissao == selectedId) {
        return item;
      }
    }
    return operationSubmissions.firstOrNull;
  }

  List<Map<String, dynamic>> get operationTasks =>
      _mapList(operationDetail?['tarefas']);

  List<Map<String, dynamic>> get operationHistory =>
      _mapList(operationDetail?['historico_status']);

  Map<String, dynamic>? get operationClassificationDetail {
    final valor = operationDetail?['resultado_classificacao'];
    if (valor is Map<String, dynamic>) {
      return valor;
    }
    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }
    return null;
  }

  ServicoDto? get service => builderService;

  VersaoServicoDto? get versaoSelecionada {
    final servicoAtual = builderService;
    if (servicoAtual == null) {
      return null;
    }
    for (final versao in servicoAtual.versoes) {
      if (versao.id == selectedBuilderVersionId) {
        return versao;
      }
    }
    return servicoAtual.versoes.firstOrNull;
  }

  FluxoDto? get fluxoSelecionado {
    final versao = versaoSelecionada;
    if (versao == null) {
      return null;
    }
    for (final fluxo in versao.fluxos) {
      if (fluxo.id == selectedBuilderFlowId) {
        return fluxo;
      }
    }
    return versao.fluxos.firstOrNull;
  }

  FlowNode? get noCanvasSelecionado =>
      builderCanvasNodes.where((item) => item.selected).firstOrNull;

  FlowEdge? get arestaCanvasSelecionada =>
      builderCanvasEdges.where((item) => item.selected).firstOrNull;

  NoFluxoDto? get noSelecionadoBuilder {
    final idNo = noCanvasSelecionado?.id;
    final fluxo = fluxoEmEdicao;
    if (idNo == null || fluxo == null) {
      return null;
    }
    for (final no in fluxo.nos) {
      if (no.id == idNo) {
        return no;
      }
    }
    return null;
  }

  ArestaFluxoDto? get arestaSelecionadaBuilder {
    final idAresta = arestaCanvasSelecionada?.id;
    final fluxo = fluxoEmEdicao;
    if (idAresta == null || fluxo == null) {
      return null;
    }
    for (final aresta in fluxo.arestas) {
      if (aresta.id == idAresta) {
        return aresta;
      }
    }
    return null;
  }

  DadosNoFormulario? get dadosFormularioSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.formulario) {
      return null;
    }
    return no.dados as DadosNoFormulario;
  }

  DadosNoApresentacao? get dadosApresentacaoSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.apresentacao) {
      return null;
    }
    return no.dados as DadosNoApresentacao;
  }

  DadosNoCondicao? get dadosCondicaoSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.condicao) {
      return null;
    }
    return no.dados as DadosNoCondicao;
  }

  DadosNoConteudoDinamico? get dadosConteudoSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.conteudoDinamico) {
      return null;
    }
    return no.dados as DadosNoConteudoDinamico;
  }

  DadosNoTarefaInterna? get dadosTarefaInternaSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.tarefaInterna) {
      return null;
    }
    return no.dados as DadosNoTarefaInterna;
  }

  DadosNoAtualizacaoStatus? get dadosAtualizacaoStatusSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.atualizacaoStatus) {
      return null;
    }
    return no.dados as DadosNoAtualizacaoStatus;
  }

  DadosNoPontuacao? get dadosPontuacaoSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.pontuacao) {
      return null;
    }
    return no.dados as DadosNoPontuacao;
  }

  DadosNoClassificacao? get dadosClassificacaoSelecionado {
    final no = noSelecionadoBuilder;
    if (no == null || no.tipo != TipoNoFluxo.classificacao) {
      return null;
    }
    return no.dados as DadosNoClassificacao;
  }

  Iterable<TipoNoFluxo> get tiposNosDisponiveis => const <TipoNoFluxo>[
        TipoNoFluxo.apresentacao,
        TipoNoFluxo.formulario,
        TipoNoFluxo.condicao,
        TipoNoFluxo.conteudoDinamico,
        TipoNoFluxo.tarefaInterna,
        TipoNoFluxo.atualizacaoStatus,
        TipoNoFluxo.pontuacao,
        TipoNoFluxo.classificacao,
        TipoNoFluxo.fim,
      ];

  Iterable<TipoCampoFormulario> get tiposCamposFormulario =>
      TipoCampoFormulario.values;

  Iterable<String> get prioridadesTarefaInternaDisponiveis => const <String>[
        'baixa',
        'normal',
        'alta',
        'critica',
      ];

  Iterable<String> get statusSubmissaoDisponiveis => const <String>[
        'submetida',
        'em_analise',
        'pendente_documentos',
        'elegivel',
        'inelegivel',
        'ranqueada',
        'homologada',
        'arquivada',
      ];

  bool get possuiFluxoEmEdicao => fluxoEmEdicao != null;

  String get publishedChannelLabel =>
      service?.metadados.canais
          .map((CanalServico item) => item.label)
          .join(' · ') ??
      'Sem canais ativos';

  String get validationSummary {
    final resultado = validationResult;
    if (resultado == null) {
      return 'Nenhuma validacao executada.';
    }
    if (resultado.valido) {
      return 'Fluxo valido para persistencia.';
    }
    return '${resultado.erros.length} erro(s) identificados no fluxo.';
  }

  String get previewSummary {
    final resultado = previewResult;
    if (resultado == null) {
      return 'Nenhuma pre-visualizacao executada.';
    }
    return 'No atual: ${resultado.noAtual.id} · status: ${resultado.status.label}';
  }

  String get previewPayloadFormatado {
    final resultado = previewResult;
    if (resultado == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert(resultado.toMap());
  }

  String get servicoPayloadFormatado {
    final servicoAtual = builderService;
    if (servicoAtual == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert(servicoAtual.toMap());
  }

  String get fluxoSnapshotFormatado {
    final fluxo = fluxoEmEdicao;
    if (fluxo == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert(fluxo.toMap());
  }

  String get conteudoApresentacaoTexto {
    final dados = dadosApresentacaoSelecionado;
    if (dados == null || dados.conteudoApresentacao.blocos.isEmpty) {
      return '';
    }
    return dados.conteudoApresentacao.blocos.first.dados['texto']?.toString() ??
        '';
  }

  @override
  Future<void> ngOnInit() async {
    await _loadCurrentSection();
  }

  Future<void> navigateTo(String section) async {
    currentSection = section;
    await _loadCurrentSection();
  }

  Future<void> onBuilderServiceChanged(String? serviceId) async {
    if (serviceId == null || serviceId.isEmpty) {
      return;
    }
    await loadBuilderData(serviceId: serviceId);
  }

  void onBuilderVersionChanged(String? versionId) {
    if (versionId == null || versionId.isEmpty || builderService == null) {
      return;
    }
    selectedBuilderVersionId = versionId;
    _sincronizarEditorComVersao();
  }

  void onBuilderFlowChanged(String? flowId) {
    if (flowId == null || flowId.isEmpty || builderService == null) {
      return;
    }
    selectedBuilderFlowId = flowId;
    _sincronizarEditorComFluxo();
  }

  void onContextoPreviewChanged(String value) {
    contextoPreviewJson = value;
  }

  void onRespostasPreviewChanged(String value) {
    respostasPreviewJson = value;
  }

  void onCanvasNodesChanged(List<FlowNodeChange> changes) {
    builderCanvasNodes = applyNodeChanges(changes, builderCanvasNodes);
    _sincronizarFluxoComCanvas();
  }

  void onCanvasEdgesChanged(List<FlowEdgeChange> changes) {
    builderCanvasEdges = applyEdgeChanges(changes, builderCanvasEdges);
    _sincronizarFluxoComCanvas();
  }

  void onCanvasSelectionChanged(Set<String> idsSelecionados) {
    builderCanvasNodes = builderCanvasNodes
        .map((item) =>
            item.copyWith(selected: idsSelecionados.contains(item.id)))
        .toList(growable: false);
    builderCanvasEdges = builderCanvasEdges
        .map((item) =>
            item.copyWith(selected: idsSelecionados.contains(item.id)))
        .toList(growable: false);
  }

  Future<void> abrirBuilder(String serviceId) async {
    await navigateTo('builder');
    await onBuilderServiceChanged(serviceId);
  }

  String nodeTitleCanvas(FlowNode node) =>
      node.data['label']?.toString() ?? node.id;

  String nodeSubtitleCanvas(FlowNode node) =>
      node.data['subtitle']?.toString() ?? '';

  String tipoNoLabel(TipoNoFluxo tipo) => tipo.label;

  String tipoCampoLabel(TipoCampoFormulario tipo) => tipo.label;

  String validacaoConfiguracaoFormatada(ValidacaoCampo validacao) {
    return const JsonEncoder.withIndent('  ').convert(validacao.configuracao);
  }

  String regraVisibilidadeFormatada(RegraVisibilidadeFormulario regra) {
    return const JsonEncoder.withIndent('  ').convert(regra.expressao);
  }

  String calculoExpressaoFormatada(CalculoCampo calculo) {
    return const JsonEncoder.withIndent('  ').convert(calculo.expressao);
  }

  String capitalizeLabel(String value) => _capitalizeLabel(value);

  bool perguntaTemOpcoes(DefinicaoPergunta pergunta) =>
      perguntaAceitaOpcoes(pergunta.tipo);

  bool versaoPodeSerPublicada(ResumoVersaoServico versao) {
    return versao.status == StatusVersaoServico.rascunho;
  }

  Future<void> _loadCurrentSection() async {
    if (isServicesSection) {
      await loadServices();
      return;
    }

    if (isBuilderSection) {
      await loadBuilderData();
      return;
    }

    if (isOperationSection) {
      await loadOperationData();
    }
  }

  Future<void> loadServices() async {
    servicesLoading = true;
    servicesError = null;

    try {
      final String response =
          await HttpRequest.getString('$_apiBaseUrl/servicos');
      final DataFrame<ResumoServico> payload =
          DataFrame<ResumoServico>.fromMapWithFactory(
        Map<String, dynamic>.from(jsonDecode(response) as Map),
        ResumoServico.fromMap,
      );
      services = payload.items.toList(growable: false);

      selectedBuilderServiceId ??= services.firstOrNull?.id;
    } catch (_) {
      servicesError = 'Nao foi possivel carregar os servicos do backend.';
    } finally {
      servicesLoading = false;
    }
  }

  Future<void> loadBuilderData({String? serviceId}) async {
    builderLoading = true;
    builderError = null;

    try {
      if (services.isEmpty) {
        await loadServices();
      }
      if (services.isEmpty) {
        return;
      }

      final String resolvedServiceId =
          serviceId ?? selectedBuilderServiceId ?? services.first.id;
      selectedBuilderServiceId = resolvedServiceId;

      final List<String> responses = await Future.wait(<Future<String>>[
        HttpRequest.getString('$_apiBaseUrl/servicos/$resolvedServiceId'),
        HttpRequest.getString(
            '$_apiBaseUrl/servicos/$resolvedServiceId/versoes'),
      ]);

      builderService = ServicoDto.fromMap(
        Map<String, dynamic>.from(
            jsonDecode(responses[0]) as Map<String, dynamic>),
      );

      final DataFrame<ResumoVersaoServico> versoes =
          DataFrame<ResumoVersaoServico>.fromMapWithFactory(
        Map<String, dynamic>.from(jsonDecode(responses[1]) as Map),
        ResumoVersaoServico.fromMap,
      );
      builderVersions = versoes.items.toList(growable: false);

      _atualizarResumosFluxos();
      selectedBuilderVersionId = _versaoSelecionadaInicial()?.id;
      _sincronizarEditorComVersao();
    } catch (_) {
      builderError =
          'Nao foi possivel carregar as definicoes de builder do backend.';
    } finally {
      builderLoading = false;
    }
  }

  Future<void> loadOperationData({String? serviceId}) async {
    operationLoading = true;
    operationError = null;

    try {
      final String filaResponse = await HttpRequest.getString(
        '$_apiBaseUrl/operacao/submissoes',
      );
      final DataFrame<ResumoSubmissaoOperacao> fila =
          DataFrame<ResumoSubmissaoOperacao>.fromMapWithFactory(
        Map<String, dynamic>.from(jsonDecode(filaResponse) as Map),
        ResumoSubmissaoOperacao.fromMap,
      );
      operationSubmissions = fila.items.toList(growable: false);

      final ResumoSubmissaoOperacao? selecionadaAtual =
          selectedOperationSubmission;
      selectedOperationSubmissionId = selecionadaAtual?.idSubmissao;
      selectedOperationServiceId = serviceId ??
          selectedOperationServiceId ??
          selecionadaAtual?.idServico ??
          operationSubmissions.firstOrNull?.idServico;

      if (selectedOperationServiceId != null &&
          selectedOperationServiceId!.isNotEmpty) {
        final String classificacaoResponse = await HttpRequest.getString(
          '$_apiBaseUrl/operacao/classificacao/$selectedOperationServiceId/resultados',
        );
        final DataFrame<ResumoResultadoClassificacao> resultados =
            DataFrame<ResumoResultadoClassificacao>.fromMapWithFactory(
          Map<String, dynamic>.from(jsonDecode(classificacaoResponse) as Map),
          ResumoResultadoClassificacao.fromMap,
        );
        classificacaoResultados = resultados.items.toList(growable: false);
      } else {
        classificacaoResultados = <ResumoResultadoClassificacao>[];
      }

      await carregarDetalheOperacional();
    } catch (_) {
      operationError = 'Nao foi possivel carregar a operacao institucional.';
    } finally {
      operationLoading = false;
    }
  }

  Future<void> carregarDetalheOperacional([String? idSubmissao]) async {
    final String? resolvedId = idSubmissao ?? selectedOperationSubmissionId;
    if (resolvedId == null || resolvedId.isEmpty) {
      operationDetail = null;
      return;
    }

    operationDetailLoading = true;
    try {
      final String response = await HttpRequest.getString(
        '$_apiBaseUrl/operacao/submissoes/$resolvedId',
      );
      operationDetail = Map<String, dynamic>.from(
        jsonDecode(response) as Map<String, dynamic>,
      );
    } catch (_) {
      operationError = 'Nao foi possivel carregar o detalhe operacional.';
    } finally {
      operationDetailLoading = false;
    }
  }

  Future<void> selecionarSubmissaoOperacional(
      ResumoSubmissaoOperacao item) async {
    selectedOperationSubmissionId = item.idSubmissao;
    selectedOperationServiceId = item.idServico;
    await loadOperationData(serviceId: item.idServico);
  }

  Future<void> transicionarSubmissaoOperacional(
    String novoStatus,
    String motivo,
  ) async {
    final submissao = selectedOperationSubmission;
    if (submissao == null) {
      return;
    }

    operationActionLoading = true;
    operationActionMessage = null;
    try {
      final response = await HttpRequest.request(
        '$_apiBaseUrl/operacao/submissoes/transicionar',
        method: 'POST',
        sendData: jsonEncode(
          RequisicaoTransicaoSubmissao(
            idSubmissao: submissao.idSubmissao,
            novoStatus: novoStatus,
            motivo: motivo,
          ).toMap(),
        ),
        requestHeaders: const <String, String>{
          'Content-Type': 'application/json',
        },
      );

      final atualizado = ResumoSubmissaoOperacao.fromMap(
        Map<String, dynamic>.from(
            jsonDecode(response.responseText ?? '{}') as Map),
      );
      selectedOperationSubmissionId = atualizado.idSubmissao;
      selectedOperationServiceId = atualizado.idServico;
      operationActionMessage =
          'Status atualizado para ${_capitalizeLabel(atualizado.status)}.';
      await loadOperationData(serviceId: atualizado.idServico);
    } catch (_) {
      operationActionMessage = 'Falha ao atualizar o status operacional.';
    } finally {
      operationActionLoading = false;
    }
  }

  Future<void> validarFluxoAtual() async {
    validationLoading = true;
    validationMessage = null;
    validationResult = null;

    try {
      final fluxo = _lerFluxoEditado();
      final response = await HttpRequest.request(
        '$_apiBaseUrl/editor/fluxos/validar',
        method: 'POST',
        sendData: jsonEncode(fluxo.toMap()),
        requestHeaders: const <String, String>{
          'Content-Type': 'application/json'
        },
      );
      validationResult = ResultadoValidacaoFluxo.fromMap(
        Map<String, dynamic>.from(
            jsonDecode(response.responseText ?? '{}') as Map),
      );
      validationMessage = validationResult!.valido
          ? 'Fluxo validado com sucesso.'
          : 'Fluxo possui inconsistencias que impedem o salvamento.';
    } catch (_) {
      validationMessage = 'Falha ao validar o fluxo editado.';
    } finally {
      validationLoading = false;
    }
  }

  Future<void> preVisualizarFluxoAtual() async {
    previewLoading = true;
    previewError = null;
    previewResult = null;

    try {
      final fluxo = _lerFluxoEditado();
      final contexto = _lerMapaJson(contextoPreviewJson);
      final respostas = _lerMapaJson(respostasPreviewJson);
      final requisicao = RequisicaoPreVisualizacaoFluxo(
        fluxo: fluxo,
        idNoAtual: fluxo.nos.isNotEmpty ? fluxo.nos.first.id : null,
        contexto: contexto,
        respostas: respostas,
      );
      final response = await HttpRequest.request(
        '$_apiBaseUrl/editor/fluxos/pre-visualizar',
        method: 'POST',
        sendData: jsonEncode(requisicao.toMap()),
        requestHeaders: const <String, String>{
          'Content-Type': 'application/json'
        },
      );
      previewResult = ResultadoPreVisualizacaoFluxo.fromMap(
        Map<String, dynamic>.from(
            jsonDecode(response.responseText ?? '{}') as Map),
      );
    } catch (_) {
      previewError = 'Falha ao executar a pre-visualizacao do fluxo.';
    } finally {
      previewLoading = false;
    }
  }

  Future<void> salvarRascunhoAtual() async {
    if (builderService == null) {
      return;
    }

    saveDraftLoading = true;
    saveDraftMessage = null;

    try {
      final servicoAtualizado = _montarServicoComFluxoEditado();
      final requisicao = RequisicaoSalvarRascunhoServico(
        servico: servicoAtualizado,
        idVersao: selectedBuilderVersionId,
      );
      final response = await HttpRequest.request(
        '$_apiBaseUrl/editor/servicos/salvar-rascunho',
        method: 'POST',
        sendData: jsonEncode(requisicao.toMap()),
        requestHeaders: const <String, String>{
          'Content-Type': 'application/json'
        },
      );
      builderService = ServicoDto.fromMap(
        Map<String, dynamic>.from(
            jsonDecode(response.responseText ?? '{}') as Map),
      );
      saveDraftMessage = 'Rascunho salvo no backend com sucesso.';
      _atualizarResumosFluxos();
      selectedBuilderVersionId = _versaoSelecionadaInicial()?.id;
      _sincronizarEditorComVersao();
      await loadBuilderData(serviceId: builderService!.id);
    } catch (_) {
      saveDraftMessage = 'Falha ao salvar o rascunho do servico.';
    } finally {
      saveDraftLoading = false;
    }
  }

  Future<void> publicarVersaoAtual() async {
    if (builderService == null || selectedBuilderVersionId == null) {
      return;
    }

    publishVersionLoading = true;
    publishVersionMessage = null;

    try {
      final requisicao = RequisicaoPublicarVersaoServico(
        idServico: builderService!.id,
        idVersao: selectedBuilderVersionId!,
      );
      final response = await HttpRequest.request(
        '$_apiBaseUrl/editor/servicos/publicar-versao',
        method: 'POST',
        sendData: jsonEncode(requisicao.toMap()),
        requestHeaders: const <String, String>{
          'Content-Type': 'application/json'
        },
      );
      builderService = ServicoDto.fromMap(
        Map<String, dynamic>.from(
            jsonDecode(response.responseText ?? '{}') as Map),
      );
      publishVersionMessage = 'Versao publicada com sucesso.';
      _atualizarResumosFluxos();
      await loadBuilderData(serviceId: builderService!.id);
      await loadServices();
    } catch (_) {
      publishVersionMessage = 'Falha ao publicar a versao selecionada.';
    } finally {
      publishVersionLoading = false;
    }
  }

  void adicionarNoAoFluxo(String tipoNo) {
    final fluxo = fluxoEmEdicao;
    if (fluxo == null) {
      return;
    }

    final tipo = TipoNoFluxo.parse(tipoNo);
    final novoNo = criarNoFluxoPadrao(tipo, fluxo.nos.length);
    _atualizarFluxoEmEdicao(
      (fluxoAtual) => FluxoDto(
        id: fluxoAtual.id,
        chave: fluxoAtual.chave,
        tipo: fluxoAtual.tipo,
        nos: <NoFluxoDto>[...fluxoAtual.nos, novoNo],
        arestas: fluxoAtual.arestas,
      ),
    );
  }

  void atualizarChaveFluxoEmEdicao(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) {
      return;
    }
    _atualizarFluxoEmEdicao(
      (fluxoAtual) => FluxoDto(
        id: fluxoAtual.id,
        chave: texto,
        tipo: fluxoAtual.tipo,
        nos: fluxoAtual.nos,
        arestas: fluxoAtual.arestas,
      ),
      sincronizarCanvas: false,
    );
  }

  void atualizarTipoFluxoEmEdicao(String valor) {
    _atualizarFluxoEmEdicao(
      (fluxoAtual) => FluxoDto(
        id: fluxoAtual.id,
        chave: fluxoAtual.chave,
        tipo: TipoFluxo.parse(valor),
        nos: fluxoAtual.nos,
        arestas: fluxoAtual.arestas,
      ),
      sincronizarCanvas: false,
    );
  }

  void atualizarRotuloNoSelecionado(String valor) {
    final no = noSelecionadoBuilder;
    if (no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      final dados = Map<String, dynamic>.from(atual.dados.toMap())
        ..['rotulo'] = valor;
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: dadosNoFluxoFromMap(tipo: atual.tipo, mapa: dados),
      );
    });
  }

  void atualizarConteudoApresentacao(String valor) {
    final dados = dadosApresentacaoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoApresentacao(
          rotulo: dados.rotulo,
          conteudoApresentacao: DocumentoConteudoRico(
            blocos: <BlocoConteudoRico>[
              BlocoConteudoRico(
                  tipo: 'paragrafo', dados: <String, dynamic>{'texto': valor}),
            ],
          ),
          conteudoAdicional: dados.conteudoAdicional,
        ),
      );
    });
  }

  void atualizarExpressaoCondicao(String valor) {
    final dados = dadosCondicaoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoCondicao(
          rotulo: dados.rotulo,
          expressao: valor,
          handleVerdadeiro: dados.handleVerdadeiro,
          handleFalso: dados.handleFalso,
        ),
      );
    });
  }

  void atualizarHandleVerdadeiro(String valor) {
    final dados = dadosCondicaoSelecionado;
    final no = noSelecionadoBuilder;
    final texto = valor.trim();
    if (dados == null || no == null || texto.isEmpty) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoCondicao(
          rotulo: dados.rotulo,
          expressao: dados.expressao,
          handleVerdadeiro: texto,
          handleFalso: dados.handleFalso,
        ),
      );
    });
  }

  void atualizarHandleFalso(String valor) {
    final dados = dadosCondicaoSelecionado;
    final no = noSelecionadoBuilder;
    final texto = valor.trim();
    if (dados == null || no == null || texto.isEmpty) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoCondicao(
          rotulo: dados.rotulo,
          expressao: dados.expressao,
          handleVerdadeiro: dados.handleVerdadeiro,
          handleFalso: texto,
        ),
      );
    });
  }

  void atualizarMetodoConteudo(String valor) {
    final dados = dadosConteudoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoConteudoDinamico(
          rotulo: dados.rotulo,
          metodo: valor,
          url: dados.url,
          modeloConteudo: dados.modeloConteudo,
          cabecalhos: dados.cabecalhos,
          modeloPayload: dados.modeloPayload,
          timeoutMs: dados.timeoutMs,
          finalizaFluxo: dados.finalizaFluxo,
        ),
      );
    });
  }

  void atualizarUrlConteudo(String valor) {
    final dados = dadosConteudoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoConteudoDinamico(
          rotulo: dados.rotulo,
          metodo: dados.metodo,
          url: valor,
          modeloConteudo: dados.modeloConteudo,
          cabecalhos: dados.cabecalhos,
          modeloPayload: dados.modeloPayload,
          timeoutMs: dados.timeoutMs,
          finalizaFluxo: dados.finalizaFluxo,
        ),
      );
    });
  }

  void atualizarTimeoutConteudo(String valor) {
    final dados = dadosConteudoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    final timeout = int.tryParse(valor.trim());
    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoConteudoDinamico(
          rotulo: dados.rotulo,
          metodo: dados.metodo,
          url: dados.url,
          modeloConteudo: dados.modeloConteudo,
          cabecalhos: dados.cabecalhos,
          modeloPayload: dados.modeloPayload,
          timeoutMs: timeout,
          finalizaFluxo: dados.finalizaFluxo,
        ),
      );
    });
  }

  void atualizarFinalizaFluxoConteudo(bool valor) {
    final dados = dadosConteudoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoConteudoDinamico(
          rotulo: dados.rotulo,
          metodo: dados.metodo,
          url: dados.url,
          modeloConteudo: dados.modeloConteudo,
          cabecalhos: dados.cabecalhos,
          modeloPayload: dados.modeloPayload,
          timeoutMs: dados.timeoutMs,
          finalizaFluxo: valor,
        ),
      );
    });
  }

  void atualizarTituloTarefaInterna(String valor) {
    final dados = dadosTarefaInternaSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoTarefaInterna(
          rotulo: dados.rotulo,
          titulo: valor,
          descricao: dados.descricao,
          prioridade: dados.prioridade,
        ),
      );
    });
  }

  void atualizarDescricaoTarefaInterna(String valor) {
    final dados = dadosTarefaInternaSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoTarefaInterna(
          rotulo: dados.rotulo,
          titulo: dados.titulo,
          descricao: valor.trim().isEmpty ? null : valor,
          prioridade: dados.prioridade,
        ),
      );
    });
  }

  void atualizarPrioridadeTarefaInterna(String valor) {
    final dados = dadosTarefaInternaSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoTarefaInterna(
          rotulo: dados.rotulo,
          titulo: dados.titulo,
          descricao: dados.descricao,
          prioridade: valor,
        ),
      );
    });
  }

  void atualizarStatusNoInterno(String valor) {
    final dados = dadosAtualizacaoStatusSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoAtualizacaoStatus(
          rotulo: dados.rotulo,
          novoStatus: valor,
          motivo: dados.motivo,
        ),
      );
    });
  }

  void atualizarMotivoStatusNoInterno(String valor) {
    final dados = dadosAtualizacaoStatusSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoAtualizacaoStatus(
          rotulo: dados.rotulo,
          novoStatus: dados.novoStatus,
          motivo: valor.trim().isEmpty ? null : valor,
        ),
      );
    });
  }

  void atualizarVersaoConjuntoRegrasPontuacao(String valor) {
    final dados = dadosPontuacaoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoPontuacao(
          rotulo: dados.rotulo,
          idVersaoConjuntoRegras: valor.trim().isEmpty ? null : valor,
          chaveResultado: dados.chaveResultado,
        ),
      );
    });
  }

  void atualizarChaveResultadoPontuacao(String valor) {
    final dados = dadosPontuacaoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoPontuacao(
          rotulo: dados.rotulo,
          idVersaoConjuntoRegras: dados.idVersaoConjuntoRegras,
          chaveResultado: valor,
        ),
      );
    });
  }

  void atualizarVersaoConjuntoRegrasClassificacao(String valor) {
    final dados = dadosClassificacaoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoClassificacao(
          rotulo: dados.rotulo,
          idVersaoConjuntoRegras: valor.trim().isEmpty ? null : valor,
          notas: dados.notas,
        ),
      );
    });
  }

  void atualizarNotasClassificacao(String valor) {
    final dados = dadosClassificacaoSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarNo(no.id, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: DadosNoClassificacao(
          rotulo: dados.rotulo,
          idVersaoConjuntoRegras: dados.idVersaoConjuntoRegras,
          notas: valor.trim().isEmpty ? null : valor,
        ),
      );
    });
  }

  void adicionarSecaoFormulario() {
    final dados = dadosFormularioSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    final indice = dados.secoes.length + 1;
    final novaSecao = SecaoFormularioDto(
      id: 'secao_$indice',
      chave: 'secao_$indice',
      titulo: 'Secao $indice',
      ordem: indice - 1,
    );
    _atualizarDadosFormulario(
      no.id,
      DadosNoFormulario(
        rotulo: dados.rotulo,
        descricao: dados.descricao,
        secoes: <SecaoFormularioDto>[...dados.secoes, novaSecao],
        perguntas: dados.perguntas,
      ),
    );
  }

  void removerSecaoFormulario(String idSecao) {
    final dados = dadosFormularioSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    final secoesAtualizadas = dados.secoes
        .where((item) => item.id != idSecao)
        .toList(growable: false);
    final perguntasAtualizadas = dados.perguntas
        .map(
          (item) => item.idSecao == idSecao
              ? DefinicaoPergunta(
                  id: item.id,
                  campo: item.campo,
                  rotulo: item.rotulo,
                  tipo: item.tipo,
                  descricao: item.descricao,
                  obrigatorio: item.obrigatorio,
                  placeholder: item.placeholder,
                  mascara: item.mascara,
                  valorPadrao: item.valorPadrao,
                  origemDados: item.origemDados,
                  participaRanking: item.participaRanking,
                  opcoes: item.opcoes,
                  validacoes: item.validacoes,
                  regrasVisibilidade: item.regrasVisibilidade,
                  calculos: item.calculos,
                )
              : item,
        )
        .toList(growable: false);

    _atualizarDadosFormulario(
      no.id,
      DadosNoFormulario(
        rotulo: dados.rotulo,
        descricao: dados.descricao,
        secoes: secoesAtualizadas,
        perguntas: perguntasAtualizadas,
      ),
    );
  }

  void atualizarSecaoFormularioTitulo(String idSecao, String valor) {
    _atualizarSecaoFormulario(idSecao, (atual) {
      return SecaoFormularioDto(
        id: atual.id,
        chave: atual.chave,
        titulo: valor,
        descricao: atual.descricao,
        ordem: atual.ordem,
        repetivel: atual.repetivel,
      );
    });
  }

  void atualizarSecaoFormularioDescricao(String idSecao, String valor) {
    _atualizarSecaoFormulario(idSecao, (atual) {
      return SecaoFormularioDto(
        id: atual.id,
        chave: atual.chave,
        titulo: atual.titulo,
        descricao: valor,
        ordem: atual.ordem,
        repetivel: atual.repetivel,
      );
    });
  }

  void atualizarSecaoFormularioRepetivel(String idSecao, bool valor) {
    _atualizarSecaoFormulario(idSecao, (atual) {
      return SecaoFormularioDto(
        id: atual.id,
        chave: atual.chave,
        titulo: atual.titulo,
        descricao: atual.descricao,
        ordem: atual.ordem,
        repetivel: valor,
      );
    });
  }

  void adicionarPerguntaFormulario() {
    final dados = dadosFormularioSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    final indice = dados.perguntas.length + 1;
    final novaPergunta = DefinicaoPergunta(
      id: 'campo_$indice',
      campo: 'campo_$indice',
      rotulo: 'Campo $indice',
      tipo: TipoCampoFormulario.textoCurto,
      idSecao: dados.secoes.firstOrNull?.id,
    );

    _atualizarDadosFormulario(
      no.id,
      DadosNoFormulario(
        rotulo: dados.rotulo,
        descricao: dados.descricao,
        secoes: dados.secoes,
        perguntas: <DefinicaoPergunta>[...dados.perguntas, novaPergunta],
      ),
    );
  }

  void removerPerguntaFormulario(String idPergunta) {
    final dados = dadosFormularioSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarDadosFormulario(
      no.id,
      DadosNoFormulario(
        rotulo: dados.rotulo,
        descricao: dados.descricao,
        secoes: dados.secoes,
        perguntas: dados.perguntas
            .where((item) => item.id != idPergunta)
            .toList(growable: false),
      ),
    );
  }

  void atualizarPerguntaRotulo(String idPergunta, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(atual, rotulo: valor);
    });
  }

  void atualizarPerguntaCampo(String idPergunta, String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) {
      return;
    }

    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(atual, id: texto, campo: texto);
    });
  }

  void atualizarPerguntaDescricao(String idPergunta, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(atual, descricao: valor);
    });
  }

  void atualizarPerguntaTipo(String idPergunta, String valor) {
    final tipo = TipoCampoFormulario.parse(valor);
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(
        atual,
        tipo: tipo,
        opcoes:
            perguntaAceitaOpcoes(tipo) ? atual.opcoes : const <OpcaoCampo>[],
      );
    });
  }

  void atualizarPerguntaSecao(String idPergunta, String? idSecao) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(
        atual,
        idSecao: idSecao == null || idSecao.isEmpty ? null : idSecao,
      );
    });
  }

  void atualizarPerguntaObrigatorio(String idPergunta, bool valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(atual, obrigatorio: valor);
    });
  }

  void atualizarPerguntaPlaceholder(String idPergunta, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(atual, placeholder: valor);
    });
  }

  void adicionarOpcaoPergunta(String idPergunta) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final indice = atual.opcoes.length + 1;
      return _copiarPergunta(
        atual,
        opcoes: <OpcaoCampo>[
          ...atual.opcoes,
          OpcaoCampo(
              valor: 'opcao_$indice',
              rotulo: 'Opcao $indice',
              ordem: indice - 1),
        ],
      );
    });
  }

  void atualizarOpcaoPergunta(
      String idPergunta, int indice, String campo, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final opcoes = atual.opcoes.toList(growable: false);
      if (indice < 0 || indice >= opcoes.length) {
        return atual;
      }
      final opcaoAtual = opcoes[indice];
      opcoes[indice] = OpcaoCampo(
        valor: campo == 'valor' ? valor : opcaoAtual.valor,
        rotulo: campo == 'rotulo' ? valor : opcaoAtual.rotulo,
        ordem: opcaoAtual.ordem,
      );
      return _copiarPergunta(atual, opcoes: opcoes);
    });
  }

  void removerOpcaoPergunta(String idPergunta, int indice) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final opcoes = atual.opcoes.toList(growable: true);
      if (indice < 0 || indice >= opcoes.length) {
        return atual;
      }
      opcoes.removeAt(indice);
      return _copiarPergunta(atual, opcoes: opcoes);
    });
  }

  void adicionarValidacaoPergunta(String idPergunta) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(
        atual,
        validacoes: <ValidacaoCampo>[
          ...atual.validacoes,
          ValidacaoCampo(
            tipo: 'regex',
            configuracao: const <String, dynamic>{'expressao': ''},
          ),
        ],
      );
    });
  }

  void atualizarValidacaoPerguntaTipo(
      String idPergunta, int indice, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final validacoes = atual.validacoes.toList(growable: true);
      if (indice < 0 || indice >= validacoes.length) {
        return atual;
      }
      final validacaoAtual = validacoes[indice];
      validacoes[indice] = ValidacaoCampo(
        tipo: valor,
        configuracao: validacaoAtual.configuracao,
        mensagem: validacaoAtual.mensagem,
      );
      return _copiarPergunta(atual, validacoes: validacoes);
    });
  }

  void atualizarValidacaoPerguntaMensagem(
      String idPergunta, int indice, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final validacoes = atual.validacoes.toList(growable: true);
      if (indice < 0 || indice >= validacoes.length) {
        return atual;
      }
      final validacaoAtual = validacoes[indice];
      validacoes[indice] = ValidacaoCampo(
        tipo: validacaoAtual.tipo,
        configuracao: validacaoAtual.configuracao,
        mensagem: valor,
      );
      return _copiarPergunta(atual, validacoes: validacoes);
    });
  }

  void atualizarValidacaoPerguntaConfiguracao(
      String idPergunta, int indice, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final validacoes = atual.validacoes.toList(growable: true);
      if (indice < 0 || indice >= validacoes.length) {
        return atual;
      }
      final validacaoAtual = validacoes[indice];
      validacoes[indice] = ValidacaoCampo(
        tipo: validacaoAtual.tipo,
        configuracao: _lerMapaJsonSeguro(valor, validacaoAtual.configuracao),
        mensagem: validacaoAtual.mensagem,
      );
      return _copiarPergunta(atual, validacoes: validacoes);
    });
  }

  void removerValidacaoPergunta(String idPergunta, int indice) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final validacoes = atual.validacoes.toList(growable: true);
      if (indice < 0 || indice >= validacoes.length) {
        return atual;
      }
      validacoes.removeAt(indice);
      return _copiarPergunta(atual, validacoes: validacoes);
    });
  }

  void adicionarRegraVisibilidadePergunta(String idPergunta) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(
        atual,
        regrasVisibilidade: <RegraVisibilidadeFormulario>[
          ...atual.regrasVisibilidade,
          RegraVisibilidadeFormulario(
            expressao: const <String, dynamic>{
              'campo': '',
              'operador': 'igual',
              'valor': '',
            },
          ),
        ],
      );
    });
  }

  void atualizarRegraVisibilidadePergunta(
      String idPergunta, int indice, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final regras = atual.regrasVisibilidade.toList(growable: true);
      if (indice < 0 || indice >= regras.length) {
        return atual;
      }
      regras[indice] = RegraVisibilidadeFormulario(
        expressao: _lerMapaJsonSeguro(valor, regras[indice].expressao),
      );
      return _copiarPergunta(atual, regrasVisibilidade: regras);
    });
  }

  void removerRegraVisibilidadePergunta(String idPergunta, int indice) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final regras = atual.regrasVisibilidade.toList(growable: true);
      if (indice < 0 || indice >= regras.length) {
        return atual;
      }
      regras.removeAt(indice);
      return _copiarPergunta(atual, regrasVisibilidade: regras);
    });
  }

  void adicionarCalculoPergunta(String idPergunta) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      return _copiarPergunta(
        atual,
        calculos: <CalculoCampo>[
          ...atual.calculos,
          CalculoCampo(
            expressao: const <String, dynamic>{
              'origem': '',
              'operacao': 'copiar'
            },
          ),
        ],
      );
    });
  }

  void atualizarCalculoPerguntaEscopo(
      String idPergunta, int indice, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final calculos = atual.calculos.toList(growable: true);
      if (indice < 0 || indice >= calculos.length) {
        return atual;
      }
      final calculoAtual = calculos[indice];
      calculos[indice] = CalculoCampo(
        expressao: calculoAtual.expressao,
        escopoDestino: valor,
      );
      return _copiarPergunta(atual, calculos: calculos);
    });
  }

  void atualizarCalculoPerguntaExpressao(
      String idPergunta, int indice, String valor) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final calculos = atual.calculos.toList(growable: true);
      if (indice < 0 || indice >= calculos.length) {
        return atual;
      }
      final calculoAtual = calculos[indice];
      calculos[indice] = CalculoCampo(
        expressao: _lerMapaJsonSeguro(valor, calculoAtual.expressao),
        escopoDestino: calculoAtual.escopoDestino,
      );
      return _copiarPergunta(atual, calculos: calculos);
    });
  }

  void removerCalculoPergunta(String idPergunta, int indice) {
    _atualizarPerguntaFormulario(idPergunta, (atual) {
      final calculos = atual.calculos.toList(growable: true);
      if (indice < 0 || indice >= calculos.length) {
        return atual;
      }
      calculos.removeAt(indice);
      return _copiarPergunta(atual, calculos: calculos);
    });
  }

  void atualizarRotuloArestaSelecionada(String valor) {
    final aresta = arestaSelecionadaBuilder;
    if (aresta == null) {
      return;
    }

    _atualizarFluxoEmEdicao(
      (fluxoAtual) => FluxoDto(
        id: fluxoAtual.id,
        chave: fluxoAtual.chave,
        tipo: fluxoAtual.tipo,
        nos: fluxoAtual.nos,
        arestas: fluxoAtual.arestas
            .map(
              (item) => item.id == aresta.id
                  ? ArestaFluxoDto(
                      id: item.id,
                      origem: item.origem,
                      destino: item.destino,
                      handleOrigem: item.handleOrigem,
                      handleDestino: item.handleDestino,
                      rotulo: valor,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
    );
  }

  void atualizarHandleOrigemArestaSelecionada(String valor) {
    _atualizarHandleArestaSelecionada(valor: valor, origem: true);
  }

  void atualizarHandleDestinoArestaSelecionada(String valor) {
    _atualizarHandleArestaSelecionada(valor: valor, origem: false);
  }

  VersaoServicoDto? _versaoSelecionadaInicial() {
    final servicoAtual = builderService;
    if (servicoAtual == null || servicoAtual.versoes.isEmpty) {
      return null;
    }
    for (final versao in servicoAtual.versoes) {
      if (versao.status == StatusVersaoServico.rascunho) {
        return versao;
      }
    }
    return servicoAtual.versoes.first;
  }

  void _atualizarResumosFluxos() {
    final servicoAtual = builderService;
    if (servicoAtual == null) {
      builderFlows = const <ResumoFluxo>[];
      return;
    }

    builderFlows = servicoAtual.versoes
        .expand((versao) => versao.fluxos)
        .map(ResumoFluxo.fromDefinicao)
        .toList(growable: false);
  }

  void _sincronizarEditorComVersao() {
    final versao = versaoSelecionada;
    if (versao == null || versao.fluxos.isEmpty) {
      selectedBuilderFlowId = null;
      fluxoEmEdicao = null;
      editorFluxoJson = '';
      builderCanvasNodes = const <FlowNode>[];
      builderCanvasEdges = const <FlowEdge>[];
      return;
    }
    selectedBuilderFlowId = versao.fluxos.first.id;
    _sincronizarEditorComFluxo();
  }

  void _sincronizarEditorComFluxo() {
    final fluxo = fluxoSelecionado;
    if (fluxo == null) {
      fluxoEmEdicao = null;
      editorFluxoJson = '';
      builderCanvasNodes = const <FlowNode>[];
      builderCanvasEdges = const <FlowEdge>[];
      return;
    }

    fluxoEmEdicao = FluxoDto.fromMap(fluxo.toMap());
    _atualizarSnapshotFluxo();
    _sincronizarCanvasComFluxo();
    validationResult = null;
    validationMessage = null;
    previewResult = null;
    previewError = null;
  }

  void _sincronizarCanvasComFluxo({Set<String>? idsSelecionados}) {
    final fluxo = fluxoEmEdicao;
    if (fluxo == null) {
      builderCanvasNodes = const <FlowNode>[];
      builderCanvasEdges = const <FlowEdge>[];
      return;
    }

    final selecionados = idsSelecionados ?? _idsSelecionadosNoCanvas();
    builderCanvasNodes = mapearNosFluxoParaCanvas(fluxo.nos)
        .map((item) => item.copyWith(selected: selecionados.contains(item.id)))
        .toList(growable: false);
    builderCanvasEdges = mapearArestasFluxoParaCanvas(fluxo.arestas)
        .map((item) => item.copyWith(selected: selecionados.contains(item.id)))
        .toList(growable: false);
  }

  void _sincronizarFluxoComCanvas() {
    final fluxo = fluxoEmEdicao;
    if (fluxo == null) {
      return;
    }

    final nosPorId = <String, NoFluxoDto>{
      for (final no in fluxo.nos) no.id: no,
    };
    final arestasPorId = <String, ArestaFluxoDto>{
      for (final aresta in fluxo.arestas) aresta.id: aresta,
    };

    final nosAtualizados = builderCanvasNodes.map((node) {
      final noExistente = nosPorId[node.id];
      if (noExistente == null) {
        return criarNoFluxoAPartirDoCanvas(node, fluxo.nos.length);
      }
      return NoFluxoDto(
        id: noExistente.id,
        tipo: noExistente.tipo,
        posicao: PosicaoXY(x: node.position.x, y: node.position.y),
        largura: node.width,
        altura: node.height,
        dados: noExistente.dados,
      );
    }).toList(growable: false);

    final arestasAtualizadas = builderCanvasEdges.map(
      (edge) {
        final arestaExistente = arestasPorId[edge.id];
        return ArestaFluxoDto(
          id: arestaExistente?.id ?? edge.id,
          origem: edge.source,
          destino: edge.target,
          handleOrigem: edge.sourceHandle,
          handleDestino: edge.targetHandle,
          rotulo: edge.label ?? arestaExistente?.rotulo,
        );
      },
    ).toList(growable: false);

    fluxoEmEdicao = FluxoDto(
      id: fluxo.id,
      chave: fluxo.chave,
      tipo: fluxo.tipo,
      nos: nosAtualizados,
      arestas: arestasAtualizadas,
    );
    _atualizarSnapshotFluxo();
  }

  Set<String> _idsSelecionadosNoCanvas() {
    final ids = <String>{};
    for (final no in builderCanvasNodes) {
      if (no.selected) {
        ids.add(no.id);
      }
    }
    for (final aresta in builderCanvasEdges) {
      if (aresta.selected) {
        ids.add(aresta.id);
      }
    }
    return ids;
  }

  void _atualizarFluxoEmEdicao(
    FluxoDto Function(FluxoDto atual) atualizar, {
    bool sincronizarCanvas = true,
  }) {
    final fluxo = fluxoEmEdicao;
    if (fluxo == null) {
      return;
    }

    final idsSelecionados = _idsSelecionadosNoCanvas();
    fluxoEmEdicao = atualizar(fluxo);
    _atualizarSnapshotFluxo();
    if (sincronizarCanvas) {
      _sincronizarCanvasComFluxo(idsSelecionados: idsSelecionados);
    }
  }

  void _atualizarNo(
      String idNo, NoFluxoDto Function(NoFluxoDto atual) atualizar) {
    _atualizarFluxoEmEdicao(
      (fluxoAtual) => FluxoDto(
        id: fluxoAtual.id,
        chave: fluxoAtual.chave,
        tipo: fluxoAtual.tipo,
        nos: fluxoAtual.nos
            .map((item) => item.id == idNo ? atualizar(item) : item)
            .toList(growable: false),
        arestas: fluxoAtual.arestas,
      ),
    );
  }

  void _atualizarDadosFormulario(String idNo, DadosNoFormulario dados) {
    _atualizarNo(idNo, (atual) {
      return NoFluxoDto(
        id: atual.id,
        tipo: atual.tipo,
        posicao: atual.posicao,
        largura: atual.largura,
        altura: atual.altura,
        dados: dados,
      );
    });
  }

  void _atualizarSecaoFormulario(
    String idSecao,
    SecaoFormularioDto Function(SecaoFormularioDto atual) atualizar,
  ) {
    final dados = dadosFormularioSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarDadosFormulario(
      no.id,
      DadosNoFormulario(
        rotulo: dados.rotulo,
        descricao: dados.descricao,
        secoes: dados.secoes
            .map((item) => item.id == idSecao ? atualizar(item) : item)
            .toList(growable: false),
        perguntas: dados.perguntas,
      ),
    );
  }

  void _atualizarPerguntaFormulario(
    String idPergunta,
    DefinicaoPergunta Function(DefinicaoPergunta atual) atualizar,
  ) {
    final dados = dadosFormularioSelecionado;
    final no = noSelecionadoBuilder;
    if (dados == null || no == null) {
      return;
    }

    _atualizarDadosFormulario(
      no.id,
      DadosNoFormulario(
        rotulo: dados.rotulo,
        descricao: dados.descricao,
        secoes: dados.secoes,
        perguntas: dados.perguntas
            .map((item) => item.id == idPergunta ? atualizar(item) : item)
            .toList(growable: false),
      ),
    );
  }

  void _atualizarHandleArestaSelecionada(
      {required String valor, required bool origem}) {
    final aresta = arestaSelecionadaBuilder;
    if (aresta == null) {
      return;
    }

    final texto = valor.trim();
    _atualizarFluxoEmEdicao(
      (fluxoAtual) => FluxoDto(
        id: fluxoAtual.id,
        chave: fluxoAtual.chave,
        tipo: fluxoAtual.tipo,
        nos: fluxoAtual.nos,
        arestas: fluxoAtual.arestas
            .map(
              (item) => item.id == aresta.id
                  ? ArestaFluxoDto(
                      id: item.id,
                      origem: item.origem,
                      destino: item.destino,
                      handleOrigem: origem
                          ? (texto.isEmpty ? null : texto)
                          : item.handleOrigem,
                      handleDestino: origem
                          ? item.handleDestino
                          : (texto.isEmpty ? null : texto),
                      rotulo: item.rotulo,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
    );
  }

  void _atualizarSnapshotFluxo() {
    final fluxo = fluxoEmEdicao;
    editorFluxoJson = fluxo == null
        ? ''
        : const JsonEncoder.withIndent('  ').convert(fluxo.toMap());
  }

  FluxoDto _lerFluxoEditado() {
    final fluxo = fluxoEmEdicao;
    if (fluxo != null) {
      return fluxo;
    }
    return FluxoDto.fromMap(_lerMapaJson(editorFluxoJson));
  }

  Map<String, dynamic> _lerMapaJson(String texto) {
    final bruto = jsonDecode(texto);
    return Map<String, dynamic>.from(bruto as Map);
  }

  Map<String, dynamic> _lerMapaJsonSeguro(
    String texto,
    Map<String, dynamic> fallback,
  ) {
    try {
      final bruto = jsonDecode(texto);
      if (bruto is Map) {
        return Map<String, dynamic>.from(bruto);
      }
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  ServicoDto _montarServicoComFluxoEditado() {
    final servicoAtual = builderService;
    final versaoAtual = versaoSelecionada;
    final fluxoAtual = fluxoSelecionado;
    final fluxoEditado = fluxoEmEdicao;
    if (servicoAtual == null ||
        versaoAtual == null ||
        fluxoAtual == null ||
        fluxoEditado == null) {
      throw StateError('Builder sem servico, versao ou fluxo selecionado.');
    }

    final versoesAtualizadas = servicoAtual.versoes.map((versao) {
      if (versao.id != versaoAtual.id) {
        return versao;
      }
      final fluxosAtualizados = versao.fluxos
          .map((fluxo) => fluxo.id == fluxoAtual.id ? fluxoEditado : fluxo)
          .toList(growable: false);
      return VersaoServicoDto(
        id: versao.id,
        versao: versao.versao,
        status: versao.status,
        criadoEm: versao.criadoEm,
        fluxos: fluxosAtualizados,
        notas: versao.notas,
      );
    }).toList(growable: false);

    return ServicoDto(
      id: servicoAtual.id,
      codigo: servicoAtual.codigo,
      metadados: servicoAtual.metadados,
      versoes: versoesAtualizadas,
      criadoEm: servicoAtual.criadoEm,
      atualizadoEm: servicoAtual.atualizadoEm,
    );
  }

  DefinicaoPergunta _copiarPergunta(
    DefinicaoPergunta atual, {
    String? id,
    String? campo,
    String? rotulo,
    TipoCampoFormulario? tipo,
    String? idSecao,
    String? descricao,
    bool? obrigatorio,
    String? placeholder,
    String? mascara,
    dynamic valorPadrao,
    Map<String, dynamic>? origemDados,
    bool? participaRanking,
    List<OpcaoCampo>? opcoes,
    List<ValidacaoCampo>? validacoes,
    List<RegraVisibilidadeFormulario>? regrasVisibilidade,
    List<CalculoCampo>? calculos,
  }) {
    return DefinicaoPergunta(
      id: id ?? atual.id,
      campo: campo ?? atual.campo,
      rotulo: rotulo ?? atual.rotulo,
      tipo: tipo ?? atual.tipo,
      idSecao: idSecao ?? atual.idSecao,
      descricao: descricao ?? atual.descricao,
      obrigatorio: obrigatorio ?? atual.obrigatorio,
      placeholder: placeholder ?? atual.placeholder,
      mascara: mascara ?? atual.mascara,
      valorPadrao: valorPadrao ?? atual.valorPadrao,
      origemDados: origemDados ?? atual.origemDados,
      participaRanking: participaRanking ?? atual.participaRanking,
      opcoes: opcoes ?? atual.opcoes,
      validacoes: validacoes ?? atual.validacoes,
      regrasVisibilidade: regrasVisibilidade ?? atual.regrasVisibilidade,
      calculos: calculos ?? atual.calculos,
    );
  }

  static String _capitalizeLabel(String value) {
    if (value.isEmpty) {
      return value;
    }

    final String withSpaces = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match match) => '${match.group(1)} ${match.group(2)}',
    );

    return withSpaces
        .split('_')
        .expand((String part) => part.split(' '))
        .where((String part) => part.isNotEmpty)
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String _renderStatusBadge(String status) {
    final parsed = StatusItemTrabalhoRetaguarda.tryParse(status);
    final cssClass = switch (parsed) {
      StatusItemTrabalhoRetaguarda.pendente => 'bg-warning text-dark',
      StatusItemTrabalhoRetaguarda.emAnalise => 'bg-primary',
      StatusItemTrabalhoRetaguarda.aguardandoAcaoExterna => 'bg-secondary',
      StatusItemTrabalhoRetaguarda.concluido => 'bg-success',
      null => 'bg-light text-body',
    };
    final label = parsed?.label ?? _capitalizeLabel(status);
    return '<span class="badge $cssClass">$label</span>';
  }

  static String _renderPublicationBadge(String status) {
    final parsed = StatusPublicacao.tryParse(status);
    final cssClass = switch (parsed) {
      StatusPublicacao.rascunho => 'bg-light text-body',
      StatusPublicacao.agendada => 'bg-info text-dark',
      StatusPublicacao.publicada => 'bg-success',
      StatusPublicacao.arquivada => 'bg-secondary',
      null => 'bg-light text-body',
    };
    final label = parsed?.label ?? _capitalizeLabel(status);
    return '<span class="badge $cssClass">$label</span>';
  }

  static String _rotuloPrazoOperacao(DateTime referencia) {
    return referencia.toIso8601String().substring(0, 16).replaceFirst('T', ' ');
  }

  static String _departamentoPorCodigoServico(String codigoServico) {
    final codigo = codigoServico.toLowerCase();
    if (codigo.contains('salus') || codigo.contains('auxilio')) {
      return 'SEMBES';
    }
    if (codigo.contains('sigep') || codigo.contains('estagio')) {
      return 'SEGEP';
    }
    return 'Prefeitura';
  }

  static StatusItemTrabalhoRetaguarda _statusRetaguarda(String status) {
    switch (status) {
      case 'em_analise':
        return StatusItemTrabalhoRetaguarda.emAnalise;
      case 'pendente_documentos':
        return StatusItemTrabalhoRetaguarda.aguardandoAcaoExterna;
      case 'homologada':
      case 'arquivada':
        return StatusItemTrabalhoRetaguarda.concluido;
      default:
        return StatusItemTrabalhoRetaguarda.pendente;
    }
  }

  static ItemFilaTrabalho _mapearResumoOperacaoParaFila(
    ResumoSubmissaoOperacao item,
  ) {
    return ItemFilaTrabalho(
      id: item.idSubmissao,
      titulo: 'Acompanhar protocolo ${item.numeroProtocolo}',
      departamento: _departamentoPorCodigoServico(item.codigoServico),
      codigoServico: item.codigoServico,
      status: _statusRetaguarda(item.status),
      rotuloResponsavel:
          item.possuiTarefaAberta ? 'Fila interna ativa' : 'Sem tarefa aberta',
      rotuloPrazo: _rotuloPrazoOperacao(item.atualizadoEm ?? item.criadoEm),
    );
  }

  static List<Map<String, dynamic>> _mapList(dynamic valor) {
    if (valor is List) {
      return valor
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    return <Map<String, dynamic>>[];
  }

  static final List<ResumoNoCanvasBuilder> _resumoNosBuilder =
      <ResumoNoCanvasBuilder>[
    ResumoNoCanvasBuilder(rotulo: 'Inicio', tipo: 'inicio', quantidade: 2),
    ResumoNoCanvasBuilder(
        rotulo: 'Apresentacao', tipo: 'apresentacao', quantidade: 4),
    ResumoNoCanvasBuilder(
        rotulo: 'Formulario', tipo: 'formulario', quantidade: 2),
    ResumoNoCanvasBuilder(rotulo: 'Condicao', tipo: 'condicao', quantidade: 2),
    ResumoNoCanvasBuilder(
        rotulo: 'Conteudo dinamico', tipo: 'conteudo_dinamico', quantidade: 2),
    ResumoNoCanvasBuilder(rotulo: 'Fim', tipo: 'fim', quantidade: 4),
  ];
}
