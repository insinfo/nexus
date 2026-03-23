import 'dart:async';

import 'package:ngdart/angular.dart';

import '../../state/flow_controller.dart';

@Component(
  selector: 'rf-background',
  templateUrl: 'background_component.html',
  styleUrls: ['background_component.css'],
)
class BackgroundComponent implements OnInit, OnDestroy {
  BackgroundComponent(this._controller, this._changeDetectorRef);

  final FlowController _controller;
  final ChangeDetectorRef _changeDetectorRef;

  StreamSubscription<int>? _subscription;

  @Input()
  int gap = 24;

  @Input()
  String color = 'rgba(148, 163, 184, 0.36)';

  @Input()
  String variant = 'dots';

  String get backgroundCss {
    if (variant == 'lines') {
      return 'linear-gradient($color 1px, transparent 1px), linear-gradient(90deg, $color 1px, transparent 1px)';
    }

    return 'radial-gradient(circle, $color 1.25px, transparent 1.25px)';
  }

  String get backgroundSize {
    final scaledGap = gap * _controller.viewport.zoom;
    return '${scaledGap}px ${scaledGap}px';
  }

  String get backgroundPosition {
    return '${_controller.viewport.x}px ${_controller.viewport.y}px';
  }

  @override
  void ngOnInit() {
    _subscription = _controller.changes.listen((_) {
      _changeDetectorRef.markForCheck();
    });
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
  }
}
