import 'dart:async';
import 'dart:html' as html;

/// Lightweight DOM-based popover helper for quick warning messages.
class SimplePopover {
  static const _popoverId = 'simple-popover-root';

  /// Shows a warning popover anchored to [target].
  static void showWarning(
    html.Element target,
    String message, {
    String title = 'Warning',
    Duration timeout = const Duration(seconds: 3),
  }) {
    _showPopover(
      target,
      message,
      title: title,
      timeout: timeout,
    );
  }

  static void _showPopover(
    html.Element target,
    String message, {
    required String title,
    required Duration timeout,
  }) {
    html.document.querySelector('#$_popoverId')?.remove();

    final body = html.document.body;
    if (body == null) {
      return;
    }

    final root = html.DivElement()
      ..id = _popoverId
      ..classes.addAll(['popover', 'show', 'bs-popover-top'])
      ..style.position = 'fixed'
      ..style.margin = '0'
      ..style.maxWidth = '420px'
      ..style.zIndex = '10000'
      ..style.visibility = 'hidden';

    final arrow = html.DivElement()..classes.add('popover-arrow');
    final header = html.HeadingElement.h3()
      ..classes.add('popover-header')
      ..text = title;
    final content = html.DivElement()
      ..classes.add('popover-body')
      ..style.whiteSpace = 'pre-line'
      ..text = message;

    root
      ..append(arrow)
      ..append(header)
      ..append(content);
    body.append(root);

    _positionPopover(root, arrow, target);
    root.style.visibility = 'visible';

    StreamSubscription<html.MouseEvent>? clickSub;
    StreamSubscription<html.KeyboardEvent>? keySub;
    Timer? timer;

    void close() {
      clickSub?.cancel();
      keySub?.cancel();
      timer?.cancel();
      root.remove();
    }

    root.onClick.listen((event) {
      event.stopPropagation();
      close();
    });

    clickSub = html.document.onClick.listen((event) {
      final clickTarget = event.target;
      if (clickTarget is html.Element &&
          !root.contains(clickTarget) &&
          !target.contains(clickTarget)) {
        close();
      }
    });

    keySub = html.document.onKeyDown.listen((event) {
      if (event.keyCode == 27) {
        close();
      }
    });

    timer = Timer(timeout, close);
  }

  static void _positionPopover(
    html.DivElement popover,
    html.DivElement arrow,
    html.Element target,
  ) {
    final targetRect = target.getBoundingClientRect();
    final popoverRect = popover.getBoundingClientRect();
    final viewportWidth = html.window.innerWidth ?? 1366;
    final viewportHeight = html.window.innerHeight ?? 768;
    const spacing = 10.0;
    const pagePadding = 8.0;

    final showAbove =
        targetRect.top >= popoverRect.height + spacing + pagePadding;
    final placementClass = showAbove ? 'bs-popover-top' : 'bs-popover-bottom';
    popover.classes
      ..remove('bs-popover-top')
      ..remove('bs-popover-bottom')
      ..add(placementClass);

    var left =
        targetRect.left + (targetRect.width / 2) - (popoverRect.width / 2);
    left = left.clamp(
        pagePadding, viewportWidth - popoverRect.width - pagePadding);

    final top = showAbove
        ? targetRect.top - popoverRect.height - spacing
        : (targetRect.bottom + spacing).clamp(
            pagePadding, viewportHeight - popoverRect.height - pagePadding);

    popover.style
      ..left = '${left}px'
      ..top = '${top}px';

    final arrowLeft = (targetRect.left + (targetRect.width / 2) - left)
        .clamp(16, popoverRect.width - 16);
    arrow.style.left = '${arrowLeft}px';
  }
}
