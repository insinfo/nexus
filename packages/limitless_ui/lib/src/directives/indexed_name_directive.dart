import 'dart:html';

import 'package:ngdart/angular.dart';

@Directive(selector: '[indexedName]')
class IndexedNameDirective {
  final Element _element;

  IndexedNameDirective(this._element);

  String? _baseName;
  int? _index;

  @Input('indexedName')
  set baseName(String? value) {
    _baseName = value;
    _updateName();
  }

  @Input()
  set indexedNameIndex(int? value) {
    _index = value;
    _updateName();
  }

  void _updateName() {
    final baseName = _baseName;
    final index = _index;

    if (baseName == null || baseName.isEmpty || index == null) {
      _element.attributes.remove('name');
      return;
    }

    _element.setAttribute('name', '$baseName$index');
  }
}
