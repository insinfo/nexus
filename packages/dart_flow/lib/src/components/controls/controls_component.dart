import 'package:ngdart/angular.dart';

import '../../state/flow_controller.dart';

@Component(
  selector: 'rf-controls',
  templateUrl: 'controls_component.html',
  styleUrls: ['controls_component.css'],
)
class ControlsComponent {
  ControlsComponent(this._controller);

  final FlowController _controller;

  void zoomIn() => _controller.zoomIn();

  void zoomOut() => _controller.zoomOut();

  void fitView() => _controller.fitView();
}
