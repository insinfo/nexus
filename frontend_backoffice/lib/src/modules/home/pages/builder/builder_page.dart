import 'dart:async';
import 'package:dart_flow/dart_flow.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';
import 'package:nexus_frontend_backoffice/src/modules/app/fluxo_visual_mapper.dart';
import 'package:nexus_frontend_backoffice/src/modules/builder/components/canvas_fluxo/canvas_fluxo_component.dart';
import 'package:nexus_frontend_backoffice/src/modules/builder/components/inspetor_no/inspetor_no_component.dart';
import 'package:nexus_frontend_backoffice/src/modules/builder/components/seletor_servico/seletor_servico_component.dart';

@Component(
  selector: 'builder-page',
  templateUrl: 'builder_page.html',
  styleUrls: <String>['builder_page.css'],
  directives: [
    coreDirectives,
    SeletorServicoComponent,
    CanvasFluxoComponent,
    InspetorNoComponent,
  ],
)
class BuilderPage implements OnInit {
  final CatalogoService _catalogoService;
  final BuilderService _builderService;
  final Router _router;

  BuilderPage(this._catalogoService, this._builderService, this._router);

  bool builderLoading = false;
  String? builderError;
  bool saveDraftLoading = false;
  bool validationLoading = false;

  List<ResumoServico> services = [];
  List<ResumoVersaoServico> builderVersions = [];

  ServicoDto? builderService;
  String? selectedBuilderServiceId;
  String? selectedBuilderVersionId;
  String? selectedBuilderFlowId;

  VersaoServicoDto? versaoSelecionada;
  FluxoDto? fluxoEmEdicao;

  List<FlowNode> builderCanvasNodes = [];
  List<FlowEdge> builderCanvasEdges = [];

  NoFluxoDto? noSelecionadoBuilder;
  ArestaFluxoDto? arestaSelecionadaBuilder;

  bool get temElementoSelecionado =>
      noSelecionadoBuilder != null || arestaSelecionadaBuilder != null;

  @override
  Future<void> ngOnInit() async {
    await _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    try {
      final df = await _catalogoService.listServicos(Filters(limit: 100));
      services = df.items;
      if (services.isNotEmpty) {
        selectedBuilderServiceId = services.first.id;
        await onBuilderServiceChanged(selectedBuilderServiceId!);
      }
    } catch (_) {
      builderError = 'Erro ao carregar serviços.';
    }
  }

  Future<void> onBuilderServiceChanged(String serviceId) async {
    selectedBuilderServiceId = serviceId;
    builderLoading = true;
    try {
      builderService = await _builderService.findServico(serviceId);
      final dfVersoes =
          await _builderService.listVersoes(serviceId, Filters(limit: 50));
      builderVersions = dfVersoes.items;

      if (builderVersions.isNotEmpty) {
        // Tenta achar um rascunho
        final rascunho = builderVersions.firstWhere(
            (v) => v.status == StatusVersaoServico.rascunho,
            orElse: () => builderVersions.first);
        await onBuilderVersionChanged(rascunho.id);
      }
    } catch (_) {
      builderError = 'Erro ao carregar detalhe do serviço.';
    } finally {
      builderLoading = false;
    }
  }

  Future<void> onBuilderVersionChanged(String versionId) async {
    selectedBuilderVersionId = versionId;
    versaoSelecionada =
        builderService?.versoes.firstWhere((v) => v.id == versionId);

    if (versaoSelecionada != null && versaoSelecionada!.fluxos.isNotEmpty) {
      final fluxoId = versaoSelecionada!.fluxos.first.id;
      await onBuilderFlowChanged(fluxoId);
    } else {
      selectedBuilderFlowId = null;
      fluxoEmEdicao = null;
      builderCanvasNodes = [];
      builderCanvasEdges = [];
    }
  }

  Future<void> onBuilderFlowChanged(String flowId) async {
    selectedBuilderFlowId = flowId;
    final fluxoOriginal =
        versaoSelecionada?.fluxos.firstWhere((f) => f.id == flowId);
    if (fluxoOriginal != null) {
      // Cria uma cópia mutável para edição (fromMap retorna listas growable:false)
      fluxoEmEdicao = FluxoDto(
        id: fluxoOriginal.id,
        chave: fluxoOriginal.chave,
        tipo: fluxoOriginal.tipo,
        nos: fluxoOriginal.nos
            .map((n) => NoFluxoDto.fromMap(n.toMap()))
            .toList(),
        arestas: fluxoOriginal.arestas
            .map((a) => ArestaFluxoDto.fromMap(a.toMap()))
            .toList(),
      );
      _sincronizarCanvasComFluxo();
    }
  }

  void _sincronizarCanvasComFluxo() {
    if (fluxoEmEdicao == null) return;
    builderCanvasNodes = mapearNosFluxoParaCanvas(fluxoEmEdicao!.nos);
    builderCanvasEdges = mapearArestasFluxoParaCanvas(fluxoEmEdicao!.arestas);
    _limparSelecao();
  }

  void _limparSelecao() {
    noSelecionadoBuilder = null;
    arestaSelecionadaBuilder = null;
  }

  void fecharPainelLateral() {
    _limparSelecao();
  }

  void handleNodesChanged(List<FlowNodeChange> changes) {
    if (fluxoEmEdicao == null) return;

    for (final change in changes) {
      if (change is FlowNodeAddChange) {
        fluxoEmEdicao!.nos.add(
          criarNoFluxoAPartirDoCanvas(change.item, fluxoEmEdicao!.nos.length),
        );
      } else if (change is FlowNodePositionChange) {
        final no = fluxoEmEdicao!.nos.firstWhere((n) => n.id == change.id);
        no.posicao = PosicaoXY(x: change.position.x, y: change.position.y);
      } else if (change is FlowNodeReplaceChange) {
        final idx = fluxoEmEdicao!.nos.indexWhere((n) => n.id == change.id);
        if (idx >= 0) {
          fluxoEmEdicao!.nos[idx] =
              criarNoFluxoAPartirDoCanvas(change.item, idx);
        }
      } else if (change is FlowNodeRemoveChange) {
        fluxoEmEdicao!.nos.removeWhere((n) => n.id == change.id);
        fluxoEmEdicao!.arestas.removeWhere(
            (a) => a.origem == change.id || a.destino == change.id);
      }
    }
  }

  void handleEdgesChanged(List<FlowEdgeChange> changes) {
    if (fluxoEmEdicao == null) return;

    for (final change in changes) {
      if (change is FlowEdgeRemoveChange) {
        fluxoEmEdicao!.arestas.removeWhere((a) => a.id == change.id);
      } else if (change is FlowEdgeAddChange) {
        final novaAresta = ArestaFluxoDto(
          id: change.item.id,
          origem: change.item.source,
          destino: change.item.target,
        );
        if (!fluxoEmEdicao!.arestas.any((a) => a.id == novaAresta.id)) {
          fluxoEmEdicao!.arestas.add(novaAresta);
        }
      } else if (change is FlowEdgeReplaceChange) {
        final idx =
            fluxoEmEdicao!.arestas.indexWhere((a) => a.id == change.item.id);
        if (idx >= 0) {
          fluxoEmEdicao!.arestas[idx] = ArestaFluxoDto(
            id: change.item.id,
            origem: change.item.source,
            destino: change.item.target,
          );
        }
      }
    }
  }

  void handleCanvasSelectionChanged(Set<String> selectedIds) {
    if (selectedIds.isEmpty) {
      _limparSelecao();
    }
  }

  void handleNodeDoubleClick(FlowNode node) {
    if (fluxoEmEdicao == null) {
      return;
    }

    final selecionado =
        fluxoEmEdicao!.nos.where((item) => item.id == node.id).firstOrNull;
    if (selecionado == null) {
      return;
    }

    noSelecionadoBuilder = selecionado;
    arestaSelecionadaBuilder = null;
  }

  void handleEdgeDoubleClick(FlowEdge edge) {
    if (fluxoEmEdicao == null) {
      return;
    }

    final selecionada =
        fluxoEmEdicao!.arestas.where((item) => item.id == edge.id).firstOrNull;
    if (selecionada == null) {
      return;
    }

    arestaSelecionadaBuilder = selecionada;
    noSelecionadoBuilder = null;
  }

  void handleNodeDataChanged() {
    _sincronizarCanvasComFluxo();
  }

  void adicionarNo(TipoNoFluxo tipo) {
    if (fluxoEmEdicao == null) return;

    final novoNo = criarNoFluxoPadrao(tipo, fluxoEmEdicao!.nos.length);
    fluxoEmEdicao!.nos.add(novoNo);
    _sincronizarCanvasComFluxo();
  }

  void removerElementoSelecionado() {
    if (fluxoEmEdicao == null) return;

    if (noSelecionadoBuilder != null) {
      fluxoEmEdicao!.nos.removeWhere((n) => n.id == noSelecionadoBuilder!.id);
      fluxoEmEdicao!.arestas.removeWhere((a) =>
          a.origem == noSelecionadoBuilder!.id ||
          a.destino == noSelecionadoBuilder!.id);
      _limparSelecao();
      _sincronizarCanvasComFluxo();
    } else if (arestaSelecionadaBuilder != null) {
      fluxoEmEdicao!.arestas
          .removeWhere((a) => a.id == arestaSelecionadaBuilder!.id);
      _limparSelecao();
      _sincronizarCanvasComFluxo();
    }
  }

  void voltarDashboard() {
    _router.navigate(RoutePaths.dashboard.toUrl());
  }

  Future<void> validarFluxo() async {
    if (fluxoEmEdicao == null) return;
    validationLoading = true;
    try {
      final res = await _builderService.validarFluxo(fluxoEmEdicao!);
      if (res.valido) {
        // Sucesso
      } else {
        // Mostrar erros
      }
    } catch (_) {
    } finally {
      validationLoading = false;
    }
  }

  Future<void> salvarRascunho() async {
    final servico = _montarServicoComFluxoEditado();
    if (servico == null) return;

    saveDraftLoading = true;
    try {
      await _builderService.salvarRascunho(servico);
      // Sucesso
    } catch (_) {
    } finally {
      saveDraftLoading = false;
    }
  }

  ServicoDto? _montarServicoComFluxoEditado() {
    if (builderService == null ||
        versaoSelecionada == null ||
        fluxoEmEdicao == null) return null;

    final versoesAtualizadas = builderService!.versoes.map((v) {
      if (v.id != versaoSelecionada!.id) return v;

      final fluxosAtualizados = v.fluxos.map((f) {
        return f.id == fluxoEmEdicao!.id ? fluxoEmEdicao! : f;
      }).toList(growable: false);

      return VersaoServicoDto(
        id: v.id,
        versao: v.versao,
        status: v.status,
        criadoEm: v.criadoEm,
        fluxos: fluxosAtualizados,
        notas: v.notas,
      );
    }).toList(growable: false);

    return ServicoDto(
      id: builderService!.id,
      codigo: builderService!.codigo,
      metadados: builderService!.metadados,
      versoes: versoesAtualizadas,
      criadoEm: builderService!.criadoEm,
      atualizadoEm: DateTime.now(),
    );
  }
}
