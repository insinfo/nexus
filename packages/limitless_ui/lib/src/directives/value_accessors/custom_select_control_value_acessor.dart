// ignore_for_file: unnecessary_import, implementation_imports
import 'dart:html';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngforms/src/directives/control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;

bool isPrimitive(val) {
  return val is num || val is bool || val == null || val is String;
}

/// Default equality helper.
bool _equals(Object? a, Object? b) {
  return a == b;
}

String _buildValueString(String? id, Object? value) {
  if (id == null) return '$value';
  if (!isPrimitive(value)) value = 'Object';
  var s = '$id: $value';

  if (s.length > 50) {
    s = s.substring(0, 50);
  }
  return s;
}

String _extractId(String valueString) => valueString.split(':')[0];

const selectValueAccessorCustom = ExistingProvider.forToken(
  ngValueAccessor,
  CustomSelectControlValueAccessor,
);

/// The accessor for writing a value and listening to changes on a select
/// element.
///
/// Note: We have to listen to the 'change' event because 'input' events aren't
/// fired for selects in Firefox and IE:
/// https://bugzilla.mozilla.org/show_bug.cgi?id=1024350
/// https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/4660045
@Directive(
  selector: 'select[ngControl],select[ngFormControl],select[ngModel]',
  providers: [selectValueAccessorCustom],
  // SelectControlValueAccessor must be visible to NgSelectOption.
  visibility: Visibility.all,
)
class CustomSelectControlValueAccessor extends Object
    with TouchHandler, ChangeHandler<dynamic>
    implements ControlValueAccessor<Object?> {
  final SelectElement _element;
  Object? value;
  final Map<String, Object?> _optionMap = <String, Object?>{};
  num _idCounter = 0;

  CustomSelectControlValueAccessor(HtmlElement element)
      : _element = element as SelectElement;

  @HostListener('change', ['\$event.target.value'])
  void handleChange(String value) {
    onChange(_getOptionValue(value), rawValue: value);
  }

  @override
  void writeValue(Object? value) {
    this.value = value;
    var valueString = _buildValueString(_getOptionId(value), value);

    _element.value = valueString;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }

  String _registerOption() => (_idCounter++).toString();

  /// Sets the comparison function used to match option values.
  @Input()
  set compareWith(bool Function(Object? o1, Object? o2) fn) {
    _compareWith = fn;
  }

  /// Uses `==` instead of identity for comparisons.
  @Input()
  set useEquals(bool val) {
    _compareWith = _equals;
  }

  /// Uses identity or a custom comparison function.
  bool Function(Object? o1, Object? o2) _compareWith = identical;

  String? _getOptionId(Object? value) {
    for (var id in _optionMap.keys) {
      //if (identical(_optionMap[id], value)) return id;
      if (_compareWith(_optionMap[id], value)) return id;
    }
    return null;
  }

  /// Allows null values in select options.
  ///  <option value="null" selected>Select</option>
  ///  <option ngValue="null" selected>Select</option>
  @Input()
  bool enableNullValue = false;

  dynamic _getOptionValue(String valueString) {
    final ngVal = _optionMap[_extractId(valueString)];

    if (enableNullValue) {
      return ngVal;
    }
    return ngVal ?? valueString;
  }
}

/// Marks <option> as dynamic, so Angular can be notified when options change.
///
/// ### Example
///
///     <select ngControl="city">
///       <option *ngFor="let c of cities" [value]="c"></option>
///     </select>
@Directive(
  selector: 'option',
)
class CustomNgSelectOption implements OnDestroy {
  final OptionElement _element;
  final CustomSelectControlValueAccessor? _select;
  late final String id;

  CustomNgSelectOption(HtmlElement element, @Optional() @Host() this._select)
      : _element = element as OptionElement {
    if (_select != null) id = _select._registerOption();
  }

  @Input('ngValue')
  set ngValue(Object? value) {
    var select = _select;
    if (select == null) return;

    if (select.enableNullValue) {
      select._optionMap[id] = value == 'null' ? null : value;
    } else {
      select._optionMap[id] = value;
    }

    _setElementValue(_buildValueString(id, value));
    select.writeValue(select.value);
  }

  @Input('value')
  set value(Object? value) {
    var select = _select;
    _setElementValue(value as String);
    if (select != null) select.writeValue(select.value);
  }

  void _setElementValue(String value) {
    _element.value = value;
  }

  @override
  void ngOnDestroy() {
    var select = _select;
    if (select != null) {
      select._optionMap.remove(id);
      select.writeValue(select.value);
    }
  }
}
