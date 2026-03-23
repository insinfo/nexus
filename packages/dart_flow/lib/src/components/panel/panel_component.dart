import 'package:ngdart/angular.dart';

@Component(
  selector: 'rf-panel',
  templateUrl: 'panel_component.html',
  styleUrls: ['panel_component.css'],
)
class PanelComponent {
  @Input()
  String position = 'top-left';

  String get panelStyle {
    switch (position) {
      case 'top-right':
        return 'top: 1rem; right: 1rem;';
      case 'bottom-left':
        return 'bottom: 1rem; left: 1rem;';
      case 'bottom-right':
        return 'bottom: 1rem; right: 1rem;';
      case 'top-left':
      default:
        return 'top: 1rem; left: 1rem;';
    }
  }
}
