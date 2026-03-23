import 'package:ngforms/ngforms.dart';

import 'indexed_name_directive.dart';
import 'value_accessors/custom_checkbox_control_value_accessor.dart';
import 'value_accessors/custom_select_control_value_acessor.dart';
import 'value_accessors/date_value_accessor.dart';

/// Convenience bundle of generic form directives and value accessors provided
/// by `limitless_ui`.
const List<Type> limitlessFormDirectives = [
  NgControlName,
  NgControlGroup,
  NgFormControl,
  NgModel,
  NgFormModel,
  NgForm,
  DefaultValueAccessor,
  NumberValueAccessor,
  CustomCheckboxControlValueAccessor,
  RadioControlValueAccessor,
  RequiredValidator,
  MinLengthValidator,
  MaxLengthValidator,
  PatternValidator,
  CustomNgSelectOption,
  CustomSelectControlValueAccessor,
  DateValueAccessor,
  IndexedNameDirective,
];
