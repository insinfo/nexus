import 'dart:html' show Element, NodeTreeSanitizer;

import 'package:ngdart/angular.dart';

/// Writes trusted HTML into the host element.
@Directive(selector: '[safeInnerHtml]')
class SafeInnerHtmlDirective {
  final Element _element;

  SafeInnerHtmlDirective(this._element);

  @Input()
  set safeInnerHtml(String? html) {
    // ignore: unsafe_html
    _element.setInnerHtml(html, treeSanitizer: NodeTreeSanitizer.trusted);
  }
}
