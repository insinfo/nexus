import 'package:dart_flow/dart_flow.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'demo-highlight-edge',
  templateUrl: 'demo_highlight_edge_component.html',
  styleUrls: ['demo_highlight_edge_component.css'],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class DemoHighlightEdgeComponent implements FlowDynamicEdgeComponent {
  FlowEdgeRenderContext? _context;

  @override
  set context(FlowEdgeRenderContext value) {
    _context = value;
  }

  FlowEdge get edge => _context!.edge;
  bool get selected => _context?.selected ?? false;
}
