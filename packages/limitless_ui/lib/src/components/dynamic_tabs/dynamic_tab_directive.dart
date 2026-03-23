import 'dart:async';
import 'package:ngdart/angular.dart';

import 'dynamic_tab_header_directive.dart';
import 'dynamic_tabs.dart';

/// Creates a tab which will be inside the [TabsComponent]
@Directive(selector: 'li-tabx')
class LiTabxDirective {
  LiTabxDirective(this._ref);

  final ChangeDetectorRef _ref;

  @HostBinding('class.tab-pane')
  bool tabPane = true;

  /// provides the injected parent tabset
  TabsComponent? tabsx;

  /// if `true` tab can not be activated
  @Input()
  bool disabled = false;

  /// tab header text
  @Input()
  String? header;

  /// Template reference to the heading template
  @ContentChild(LiTabxHeaderDirective)
  LiTabxHeaderDirective? headerTemplate;

  final _selectCtrl = StreamController<LiTabxDirective>.broadcast();

  /// emits the selected element change
  @Output()
  Stream<LiTabxDirective> get select => _selectCtrl.stream;

  final _deselectCtrl = StreamController<LiTabxDirective>.broadcast();

  /// emits the deselected element change
  @Output()
  Stream get deselect => _deselectCtrl.stream;

  bool _active = false;

  /// if tab is active equals true, or set `true` to activate tab
  @HostBinding('class.active')
  bool get active => _active;

  /// if tab is active equals true, or set `true` to activate tab
  @Input()
  set active(bool? activeP) {
    activeP ??= true;
    if (_active != activeP) {
      _active = activeP;
      //_ref.detectChanges();
      _ref.markForCheck();
    }
    if (activeP) {
      _selectCtrl.add(this);
    } else {
      _deselectCtrl.add(this);
    }
  }
}
