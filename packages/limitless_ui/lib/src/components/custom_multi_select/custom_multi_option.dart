import 'dart:html';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import 'custom_multi_select.dart';

@Component(
  selector: 'custom-multi-option',
  templateUrl: 'custom_multi_option.html',
  directives: [
    coreDirectives,
    formDirectives,
  ],
)
class CustomMultiOptionComp {
  @Input('value')
  dynamic value;

  final Element rootElement;

  CustomMultiOptionComp(this.rootElement);

  CustomMultiSelectComponent? parent;

  @HostListener('click')
  void handleOnClick(Event e) {
    e.stopPropagation();
    print('handleOnClick ');
    // parent.dropdownOnSelect(e, value, item?.firstChild?.text);
  }

  String get text {
    return rootElement.text ?? '';
  }

  set text(String inputText) {
    rootElement.text = inputText;
  }

  String? get innerHtml {
    return rootElement.innerHtml;
  }

  set innerHtml(String? inputText) {
    rootElement.innerHtml = innerHtml;
  }
}
