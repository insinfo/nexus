import 'package:dart_flow/dart_flow.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'demo-approval-node',
  templateUrl: 'demo_approval_node_component.html',
  styleUrls: ['demo_approval_node_component.css'],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class DemoApprovalNodeComponent implements FlowDynamicNodeComponent {
  FlowNodeRenderContext? _context;

  @override
  set context(FlowNodeRenderContext value) {
    _context = value;
  }

  FlowNode get node => _context!.node;
  bool get selected => _context?.selected ?? false;
}
