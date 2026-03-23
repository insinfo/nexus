//C:\MyDartProjects\new_sali\frontend\lib\src\shared\components\custom_multi_select\custom_multi_select.dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:popper/popper.dart';

import '../../directives/click_outside.dart';
import '../../exceptions/invalid_argument_exception.dart';
import 'custom_multi_option.dart';

class CustomMultiSelectItem {
  String text;
  dynamic value;
  bool selected = false;
  bool hover = false;
  bool visible = true;
  //Map<String, dynamic>? instanceMap;
  dynamic instanceObj;
  CustomMultiSelectItem(
      {required this.text,
      this.value,
      // this.selected = false,
      // this.hover = false,
      // this.instanceMap,
      this.instanceObj});
}

/// Example:
/// `<custom-multi-select [dataSource]="dropdownOptions" [fields]="{'text': 'name', 'value': 'value'}" (currentValueChange)="dropdownValueChanged($event)"></custom-multi-select>`
@Component(
  selector: 'custom-multi-select',
  changeDetection: ChangeDetectionStrategy.onPush,
  templateUrl: 'custom_multi_select.html',
  styleUrls: ['custom_multi_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
    ClickOutsideDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, CustomMultiSelectComponent),
  ],
)
class CustomMultiSelectComponent
    implements
        ControlValueAccessor<dynamic>,
        OnInit,
        OnDestroy,
        AfterContentInit {
  final html.Element nativeElement;
  final ChangeDetectorRef _changeDetectorRef;
  PopperAnchoredOverlay? _overlay;
  bool isDisabled = false;

  CustomMultiSelectComponent(this.nativeElement, this._changeDetectorRef);

  final StreamController<dynamic> _changeController =
      StreamController<dynamic>();

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @ContentChildren(CustomMultiOptionComp)
  List<CustomMultiOptionComp> childrenSelectOptions = [];

  @override
  void ngAfterContentInit() {
    for (final opt in childrenSelectOptions) {
      opt.parent = this;

      options.add(
        CustomMultiSelectItem(
          value: opt.value,
          text: opt.text,
          instanceObj: opt.value,
        ),
      );
    }
    _markForCheck();
  }

  @override
  void writeValue(dynamic newVal) {
    for (final option in options) {
      option.selected = false;
    }

    if (newVal is List) {
      for (final value in newVal) {
        for (final option in options) {
          if (value == option.value) {
            option.selected = true;
          }
        }
      }
    }

    _markForCheck();
  }

  dynamic Function(dynamic, {String rawValue})? _callback;

  @override
  void registerOnChange(callback) {
    _callback = callback;
  }

  // optionally you can implement the rest interface methods
  @override
  void registerOnTouched(TouchFunction callback) {}

  @override
  void onDisabledChanged(bool state) {
    isDisabled = state;
    _markForCheck();
  }

  @ViewChild('dropdownContainer')
  html.Element? dropdownContainerEle;

  @ViewChild('inputSearch')
  html.InputElement? inputSearch;

  @ViewChild('dropdownButton')
  html.Element? dropdownButtonElement;

  List<dynamic> get selectedValues =>
      options.where((opt) => opt.selected).map((e) => e.value).toList();

  List<String> get selectedLabels =>
      options.where((opt) => opt.selected).map((e) => e.text).toList();

  bool dropdownOpen = false;

  /// define de key used get label to diplay from data source options
  @Input('labelKey')
  String labelKey = 'label';

  @Input('valueKey')
  String? valueKey;

  List<CustomMultiSelectItem> options = [];

  int get minHeight {
    var mh = options.length < 5 ? options.length * 25 : 5 * 25;
    return mh;
  }

  html.Element get listElement => dropdownContainerEle!.querySelector('ul')!;

  /// dataSource
  @Input()
  set dataSource(dynamic ops) {
    options = [];
    if (ops is List<Map<String, dynamic>>) {
      for (final map in ops) {
        options.add(
          CustomMultiSelectItem(
            value: valueKey != null ? map[valueKey] : map,
            text: map[labelKey],
            instanceObj: map,
          ),
        );
      }
      _markForCheck();
    } else if (ops is DataFrame) {
      var opAsMap = ops.itemsAsMap;
      for (var i = 0; i < ops.length; i++) {
        var map = opAsMap[i];
        options.add(
          CustomMultiSelectItem(
            value: valueKey != null ? map[valueKey] : ops[i],
            text: map[labelKey] ?? '',
            instanceObj: ops[i],
          ),
        );
      }
      _markForCheck();
    } else {
      throw InvalidArgumentException(CustomMultiSelectComponent, ops);
    }
  }

  //placeholder
  @Input()
  String placeholder = 'Selecione';

  @override
  void ngOnInit() {
    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: dropdownButtonElement!,
      floatingElement: dropdownContainerEle!,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'CustomSelectComponent',
        hostZIndex: '1000',
        floatingZIndex: '1000',
      ),
      popperOptions: PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: const <String>[
          'top-start',
          'bottom-end',
          'top-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 4),
        matchReferenceWidth: true,
        onLayout: (layout) {
          final maxHeight = math.max(120.0, layout.availableHeight);
          final minListHeight = math.min(minHeight.toDouble(), maxHeight);
          listElement.style.maxHeight = '${maxHeight.floor()}px';
          listElement.style.minHeight = '${minListHeight.floor()}px';
        },
      ),
    );

    if (options.isNotEmpty == true) {
      //currentValue = options[0];
    }
  }

  void closeDropdown({bool markForCheck = true}) {
    for (final element in dropdownContainerEle!.querySelectorAll('li')) {
      if (element.classes.contains('dropdown-item-hover')) {
        element.classes.remove('dropdown-item-hover');
      }
    }
    dropdownContainerEle!.setAttribute('aria-expanded', 'false');

    dropdownOpen = false;

    for (final option in options) {
      option.visible = true;
    }
    inputSearch?.value = '';

    _overlay?.stopAutoUpdate();

    if (markForCheck) {
      _markForCheck();
    }
  }

  void openDropdown() {
    if (isDisabled) {
      return;
    }

    dropdownContainerEle!.setAttribute('aria-expanded', 'true');

    dropdownOpen = true;
    _overlay?.startAutoUpdate();
    Future.delayed(const Duration(milliseconds: 20), () {
      _overlay?.update();
    });

    _markForCheck();
  }

  void onLiClickHandle(dynamic event, CustomMultiSelectItem value) {
    // currentValue = value;
    // closeDropdown();
    // _changeController.add(currentValue?.value);
    // if (_callback != null) {
    //   _callback!(currentValue?.value);
    // }
  }

  void onCheckboxClickHandle(dynamic event, CustomMultiSelectItem option) {
    if (isDisabled) {
      return;
    }

    event.stopPropagation();
    option.selected = !option.selected;

    _changeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markForCheck();
  }

  void toggleDropdown() {
    if (isDisabled) {
      return;
    }

    dropdownOpen = !dropdownOpen;
    //dropdownElement.setAttribute( 'aria-expanded', dropdownOpen ? 'true' : 'false');
    if (dropdownOpen) {
      openDropdown();
    } else {
      closeDropdown();
    }
  }

  @override
  void ngOnDestroy() {
    closeDropdown(markForCheck: false);
    _overlay?.dispose();
    _changeController.close();
  }

  void reset() {
    for (final element in options) {
      element.selected = false;
    }
    _changeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markForCheck();
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }
}
