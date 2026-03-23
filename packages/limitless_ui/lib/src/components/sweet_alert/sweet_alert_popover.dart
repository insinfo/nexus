import 'dart:async';
import 'dart:html';

import 'package:popper/popper.dart';

class SweetAlertPopover {
  static void showPopover(Element target, String message,
      {String title = 'Atenção',
      Duration? timeout = const Duration(seconds: 3)}) async {
//     var template = '''
//    <div class="popover-arrow" style="position: absolute; left: 0px; transform: translate(129px, 0px);"></div>
//    <h3 class="popover-header">${title}</h3>
//    <div class="popover-body">${message}</div>
// ''';

    final id = 'popover441630';

    final olds = document.querySelectorAll('#$id');
    if (olds.isNotEmpty) {
      for (final old in olds) {
        old.remove();
      }
    }

    final rootPopover = DivElement();
    rootPopover.attributes['id'] = id;
    rootPopover.classes.addAll(['popover', 'bs-popover-auto', 'fade', 'show']);
    rootPopover.attributes['data-popper-placement'] = 'top';
    rootPopover.style.position = 'fixed';
    rootPopover.style.margin = '0px';
    rootPopover.style.zIndex = '10000';

    final popoverArrow = DivElement();
    popoverArrow.classes.add('popover-arrow');
    rootPopover.append(popoverArrow);
    popoverArrow.style.position = 'absolute';
    popoverArrow.style.left = '0px';

    final popoverHeader = HeadingElement.h3();
    popoverHeader.classes.add('popover-header');
    popoverHeader.text = title;
    rootPopover.append(popoverHeader);

    final popoverBody = DivElement();
    popoverBody.classes.add('popover-body');
    popoverBody.innerHtml = message;
    popoverBody.style.whiteSpace = 'pre-line';
    rootPopover.append(popoverBody);
    rootPopover.style.maxWidth = '420px';

    // ignore: unsafe_html
    // rootPopover.setInnerHtml(template,
    //     treeSanitizer: NodeTreeSanitizer.trusted);

    document.body!.classes.addAll(['swal2-toast-shown', 'swal2-shown']);
    final overlay = PopperAnchoredOverlay.attach(
      referenceElement: target,
      floatingElement: rootPopover,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'SweetAlertPopover',
        hostZIndex: '10000',
        floatingZIndex: '10001',
      ),
      popperOptions: PopperOptions(
        placement: 'top-start',
        fallbackPlacements: const <String>[
          'bottom-start',
          'top-end',
          'bottom-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 10),
        arrowElement: popoverArrow,
      ),
    );
    overlay.startAutoUpdate();

    StreamSubscription? ssoc, ssokd;
    Timer? closeTimer;

    void close() {
      target.attributes.remove('data-popover');
      document.body!.classes.removeAll(['swal2-toast-shown', 'swal2-shown']);
      overlay.dispose();
      ssoc?.cancel();
      ssokd?.cancel();
      closeTimer?.cancel();
    }

    rootPopover.onClick.listen((event) {
      event.stopPropagation();
      close();
    });
    if (timeout != null) {
      closeTimer = Timer(timeout, close);
    }

    Future.delayed(const Duration(milliseconds: 250), () {
      ssoc = document.onClick.listen((event) {
        final te = event.target;
        if (te is Element &&
            !rootPopover.contains(te) &&
            !target.contains(te)) {
          close();
        }
      });

      ssokd = document.onKeyDown.listen((event) {
        // print('onKeyDown ${event.key} | ${event.code} | ${event.keyCode}');
        if (event.keyCode == 27) {
          close();
        }
      });
    });

    if (target.attributes['data-popover'] == null) {
      target.attributes['data-popover'] = 'true';
    }
  }
}
