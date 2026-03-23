import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

import 'package:ngdart/angular.dart';

@Directive(selector: '[dropdownmenu]') //dropdownmenu
class DropdownMenuDirective implements AfterContentInit, OnDestroy {
  final Element rootElement;

  @Input('dropdownmenu')
  String xPlacement = 'bottom-end';

  StreamSubscription? globalBodyClickSS;

  DropdownMenuDirective(this.rootElement);

  @override
  void ngAfterContentInit() {
    rootElement.onClick.listen(onRootClick);

    globalBodyClickSS =
        document.querySelector('body')?.onClick.listen(onBodyClick);
  }

  void onRootClick(MouseEvent event) {
    toogle();
  }

  void toogle() {
    rootElement.classes.toggle('show');
    var dropdownMenu = rootElement.querySelector('.dropdown-menu');
    if (dropdownMenu != null) {
      // transform: translate3d(-158px, 19px, 0px);
      //transform: translate3d(x, y, 0px);
      dropdownMenu.classes.toggle('show');
      var rectRoot = rootElement.getBoundingClientRect();

      //print(  'rectRoot x: ${rectRoot.left} | y: ${rectRoot.top} | height: ${rectRoot.height} | width: ${rectRoot.width}');

      var rectMenu = dropdownMenu.getBoundingClientRect();
      //print(  'rectMenu x: ${rectMenu.left} | y: ${rectMenu.top} | height: ${rectMenu.height} | width: ${rectMenu.width}');

      int vw =
          math.max(document.documentElement!.clientWidth, window.innerWidth!);
      int vh =
          math.max(document.documentElement!.clientHeight, window.innerHeight!);

      var halfViewportHeight = vh / 2;

      //print('viewport vw:$vw | vh:$vh | halfHeight: $halfViewportHeight');

      var x = (rectMenu.width + rectRoot.left) >= (vw - rectMenu.width)
          ? ((vw - rectMenu.width) - rectRoot.left) - (rectMenu.width / 2)
          : 0;

      //print('x: $x');

      var y = 19;
      if (rectRoot.top >= halfViewportHeight) {
        y = (rectMenu.height as int) * -1;
      }

      //dropdownMenu.style.transform = 'translate3d(${x}px, ${y}px, 0px)';
      dropdownMenu.style.top = '${y}px';
      dropdownMenu.style.left = '${x}px';
    }
  }

  void hide() {
    rootElement.classes.remove('show');
    var dropdownMenu = rootElement.querySelector('.dropdown-menu');
    if (dropdownMenu != null) {
      dropdownMenu.classes.remove('show');
    }
  }

  void onBodyClick(MouseEvent event) {
    var target = event.target as Element;
    var hasDescendant = rootElement.contains(target);
    if (!hasDescendant) {
      hide();
    }
  }

  @override
  void ngOnDestroy() {
    globalBodyClickSS?.cancel();
  }
}
