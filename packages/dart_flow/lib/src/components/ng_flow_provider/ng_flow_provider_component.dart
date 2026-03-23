import 'package:ngdart/angular.dart';

import '../../state/flow_controller.dart';
import '../../state/ng_flow_interaction_controller.dart';
import '../../state/ng_flow_instance.dart';
import '../../state/ng_flow_store.dart';

@Component(
  selector: 'ng-flow-provider',
  templateUrl: 'ng_flow_provider_component.html',
  providers: [
    ClassProvider(FlowController),
    ClassProvider(NgFlowInteractionController),
    ClassProvider(NgFlowInstance),
    ClassProvider(NgFlowStore),
  ],
)
class NgFlowProviderComponent {}
