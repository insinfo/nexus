import 'package:ngdart/angular.dart';

import '../../types/renderers.dart';

@Component(
  selector: 'rf-dynamic-node-host',
  templateUrl: 'dynamic_node_host_component.html',
  styleUrls: ['dynamic_node_host_component.css'],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class DynamicNodeHostComponent
    implements AfterViewInit, AfterChanges, OnDestroy {
  ComponentRef<Object>? _componentRef;
  ComponentFactory<Object>? _currentFactory;
  ViewContainerRef? _hostContainer;

  @Input()
  ComponentFactory<Object>? factory;

  @Input()
  FlowNodeRenderContext? context;

  @ViewChild('hostContainer', read: ViewContainerRef)
  set hostContainer(ViewContainerRef? value) {
    _hostContainer = value;
    _renderComponent();
  }

  @override
  void ngAfterViewInit() {
    _renderComponent();
  }

  @override
  void ngAfterChanges() {
    _renderComponent();
  }

  @override
  void ngOnDestroy() {
    _componentRef?.destroy();
    _componentRef = null;
    _currentFactory = null;
  }

  void _renderComponent() {
    final container = _hostContainer;
    final nextFactory = factory;
    if (container == null) {
      return;
    }

    if (nextFactory == null) {
      container.clear();
      _componentRef = null;
      _currentFactory = null;
      return;
    }

    if (_componentRef == null || _currentFactory != nextFactory) {
      container.clear();
      _componentRef = container.createComponent(nextFactory);
      _currentFactory = nextFactory;
    }

    final nextContext = context;
    final componentRef = _componentRef;
    if (componentRef == null || nextContext == null) {
      return;
    }

    componentRef.update((instance) {
      if (instance is FlowDynamicNodeComponent) {
        instance.context = nextContext;
      }
    });
  }
}
