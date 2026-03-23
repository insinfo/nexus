import 'package:ngdart/angular.dart';

import '../../types/models.dart';

@Component(
  selector: 'rf-handle',
  templateUrl: 'handle_component.html',
  styleUrls: ['handle_component.css'],
)
class HandleComponent {
  @Input()
  HandleType type = HandleType.source;

  @Input()
  Position position = Position.right;

  HandleType get handleType => HandleType.source;

  Position get handlePosition => Position.right;
}
