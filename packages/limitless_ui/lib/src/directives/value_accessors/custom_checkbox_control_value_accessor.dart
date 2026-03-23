import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

const customCheckboxValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  CustomCheckboxControlValueAccessor,
);

/// Writes boolean values to checkbox inputs and listens to user changes.
@Directive(
  selector: 'input[type=checkbox][ngControl],'
      'input[type=checkbox][ngFormControl],'
      'input[type=checkbox][ngModel]',
  providers: [customCheckboxValueAccessor],
)
class CustomCheckboxControlValueAccessor
    implements ControlValueAccessor<bool?> {
  final InputElement _element;

  CustomCheckboxControlValueAccessor(HtmlElement element)
      : _element = element as InputElement;

  ChangeFunction<bool?> onChange = (bool? _, {String? rawValue}) {};
  TouchFunction onTouched = () {};

  @HostListener('change', ['\$event.target.checked'])
  void handleChange(bool checked) {
    onChange(checked, rawValue: '$checked');
  }

  @HostListener('blur')
  void touchHandler() {
    onTouched();
  }

  @override
  void registerOnChange(ChangeFunction<bool?> fn) {
    onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  @override
  void writeValue(bool? value) {
    _element.checked = value ?? false;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }
}
