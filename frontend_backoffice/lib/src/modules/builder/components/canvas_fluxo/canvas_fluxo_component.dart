import 'dart:async';
import 'package:dart_flow/dart_flow.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Componente para o canvas visual do fluxo utilizando dart_flow (ng-flow).
@Component(
  selector: 'canvas-fluxo',
  templateUrl: 'canvas_fluxo_component.html',
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
  @Input()
  List<FlowNode> nodes = [];

  @Input()
  List<FlowEdge> edges = [];

  final _onNodesChange = StreamController<List<FlowNodeChange>>.broadcast();
  @Output()
  Stream<List<FlowNodeChange>> get onNodesChange => _onNodesChange.stream;

  final _onEdgesChange = StreamController<List<FlowEdgeChange>>.broadcast();
  @Output()
  Stream<List<FlowEdgeChange>> get onEdgesChange => _onEdgesChange.stream;

  final _onSelectionChange = StreamController<Set<String>>.broadcast();
  @Output()
  Stream<Set<String>> get onSelectionChange => _onSelectionChange.stream;

  void handleNodesChanged(List<FlowNodeChange> changes) => _onNodesChange.add(changes);
  void handleEdgesChanged(List<FlowEdgeChange> changes) => _onEdgesChange.add(changes);
  void handleSelectionChanged(Set<String> ids) => _onSelectionChange.add(ids);
}
