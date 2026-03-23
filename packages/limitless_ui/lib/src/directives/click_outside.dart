import 'dart:async';

import 'dart:html';

import 'package:ngdart/angular.dart';

///
/// uma diretiva angular para detectar cliques fora de um objeto
/// baseada em https://javascript.plainenglish.io/creating-an-angular-directive-to-detect-clicking-outside-an-object-afd6c07212ef
///
@Directive(selector: '[clickOutside]')
class ClickOutsideDirective implements OnDestroy, OnInit {
  Element nativeElement;
  ClickOutsideDirective(this.nativeElement);

  StreamSubscription? documentClickStreamSubscription;

  StreamController<MouseEvent> clickOutsideSC = StreamController<MouseEvent>();

  @Output('clickOutside')
  Stream<MouseEvent> get clickOutside => clickOutsideSC.stream;

  /*@HostListener('document:click', ['\$event', '\$event.target'])
  void onClick(MouseEvent event, HtmlElement targetElement) {
    /*if (!targetElement) {
            return;
        }
        const clickedInside = nativeElement.contains(targetElement);
        if (!clickedInside) {
            clickOutsideSC.add(event);
        }*/
    print('ClickOutsideDirective document:click ');
  }*/

  void onClick(MouseEvent event) {
    final target = event.target;
    if (target is! Node) {
      return;
    }

    var clickedInside = nativeElement.contains(target);
    if (!clickedInside) {
      clickOutsideSC.add(event);
    }
  }

  @override
  void ngOnDestroy() {
    documentClickStreamSubscription?.cancel();
  }

  @override
  void ngOnInit() {
    documentClickStreamSubscription = document.onClick.listen(onClick);
  }
}
