import 'dart:html';

import 'package:ngdart/angular.dart';

/// Appends a trusted DOM node to the host element.
@Directive(selector: '[safeAppendHtml]')
class SafeAppendHtmlDirective {
  final Element _element;

  SafeAppendHtmlDirective(this._element);

  @Input()
  set safeAppendHtml(Node? htmlElement) {
    if (htmlElement != null) {
      _element.append(htmlElement);
    }
  }
}
