import 'dart:async';
import 'package:dart_flow/dart_flow.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Componente para o canvas visual do fluxo utilizando dart_flow (ng-flow).
@Component(
  selector: 'canvas-fluxo',
  templateUrl: 'canvas_fluxo_component.html',
  styleUrls: ['canvas_fluxo_component.css'],
  directives: [
    coreDirectives,
    NgFlowComponent,
    BackgroundComponent,
    ControlsComponent,
    MiniMapComponent,
    PanelComponent,
  ],
)
class CanvasFluxoComponent {
  final List<TipoNoFluxo> toolboxNodeTypes = const <TipoNoFluxo>[
    TipoNoFluxo.inicio,
    TipoNoFluxo.formulario,
    TipoNoFluxo.apresentacao,
    TipoNoFluxo.condicao,
    TipoNoFluxo.conteudoDinamico,
    TipoNoFluxo.tarefaInterna,
    TipoNoFluxo.atualizacaoStatus,
    TipoNoFluxo.classificacao,
    TipoNoFluxo.pontuacao,
    TipoNoFluxo.fim,
  ];

  @Input()
  List<FlowNode> nodes = [];

  @Input()
  List<FlowEdge> edges = [];

  bool toolboxOpen = false;

  final _onNodesChange = StreamController<List<FlowNodeChange>>.broadcast();
  @Output()
  Stream<List<FlowNodeChange>> get onNodesChange => _onNodesChange.stream;

  final _onEdgesChange = StreamController<List<FlowEdgeChange>>.broadcast();
  @Output()
  Stream<List<FlowEdgeChange>> get onEdgesChange => _onEdgesChange.stream;

  final _onSelectionChange = StreamController<Set<String>>.broadcast();
  @Output()
  Stream<Set<String>> get onSelectionChange => _onSelectionChange.stream;

  final _onNodeDoubleClick = StreamController<FlowNode>.broadcast();
  @Output()
  Stream<FlowNode> get onNodeDoubleClick => _onNodeDoubleClick.stream;

  final _onEdgeDoubleClick = StreamController<FlowEdge>.broadcast();
  @Output()
  Stream<FlowEdge> get onEdgeDoubleClick => _onEdgeDoubleClick.stream;

  final _onAddNode = StreamController<TipoNoFluxo>.broadcast();
  @Output()
  Stream<TipoNoFluxo> get onAddNode => _onAddNode.stream;

  void handleNodesChanged(List<FlowNodeChange> changes) =>
      _onNodesChange.add(changes);
  void handleEdgesChanged(List<FlowEdgeChange> changes) =>
      _onEdgesChange.add(changes);
  void handleSelectionChanged(Set<String> ids) => _onSelectionChange.add(ids);
  void handleNodeDoubleClick(FlowNode node) => _onNodeDoubleClick.add(node);
  void handleEdgeDoubleClick(FlowEdge edge) => _onEdgeDoubleClick.add(edge);

  void addNode(TipoNoFluxo tipo) => _onAddNode.add(tipo);

  void addNodeAndClose(TipoNoFluxo tipo) {
    addNode(tipo);
    closeToolbox();
  }

  void toggleToolbox() {
    toolboxOpen = !toolboxOpen;
  }

  void closeToolbox() {
    toolboxOpen = false;
  }

  String toolboxIcon(TipoNoFluxo tipo) {
    switch (tipo) {
      case TipoNoFluxo.inicio:
        return 'ph-sign-in';
      case TipoNoFluxo.apresentacao:
        return 'ph-file-text';
      case TipoNoFluxo.formulario:
        return 'ph-list-bullets';
      case TipoNoFluxo.conteudoDinamico:
        return 'ph-lightning';
      case TipoNoFluxo.condicao:
        return 'ph-git-branch';
      case TipoNoFluxo.fim:
        return 'ph-flag-checkered';
      case TipoNoFluxo.tarefaInterna:
        return 'ph-briefcase';
      case TipoNoFluxo.atualizacaoStatus:
        return 'ph-arrows-clockwise';
      case TipoNoFluxo.pontuacao:
        return 'ph-chart-bar';
      case TipoNoFluxo.classificacao:
        return 'ph-funnel';
    }
  }

  String toolboxBadge(TipoNoFluxo tipo) {
    switch (tipo) {
      case TipoNoFluxo.inicio:
        return 'Entrada';
      case TipoNoFluxo.fim:
        return 'Saida';
      case TipoNoFluxo.condicao:
        return 'Decisao';
      case TipoNoFluxo.formulario:
        return 'Coleta';
      case TipoNoFluxo.apresentacao:
        return 'Conteudo';
      case TipoNoFluxo.conteudoDinamico:
        return 'Api';
      case TipoNoFluxo.tarefaInterna:
        return 'Backoffice';
      case TipoNoFluxo.atualizacaoStatus:
        return 'Status';
      case TipoNoFluxo.pontuacao:
        return 'Score';
      case TipoNoFluxo.classificacao:
        return 'Regra';
    }
  }
}
