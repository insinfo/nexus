import 'package:ngdart/angular.dart';

/// Creates a new Limitless/Bootstrap tab header template
@Directive(selector: 'template[li-tabx-header]')
class LiTabxHeaderDirective {
  /// constructs a [LiTabxHeaderDirective] injecting its own [templateRef] and its parent [tab]
  LiTabxHeaderDirective(this.templateRef);

  TemplateRef templateRef;
}
