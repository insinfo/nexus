import 'dart:async';
import 'dart:html';

/// Lightweight SweetAlert-inspired toast helper for quick feedback messages.
class SimpleToast {
  static const _toastId = 'swal2-toast-root';

  /// Shows a warning toast.
  static void showWarning(String message, {int duration = 3000}) {
    _showToast(
      message: message,
      duration: duration,
      type: 'warning',
    );
  }

  /// Shows a success toast.
  static void showSuccess(String message, {int duration = 3000}) {
    _showToast(
      message: message,
      duration: duration,
      type: 'success',
    );
  }

  static void _showToast({
    required String message,
    required int duration,
    required String type,
  }) {
    document.querySelector('#$_toastId')?.remove();

    final root = DivElement()
      ..id = _toastId
      ..className = 'swal2-container swal2-top-end swal2-backdrop-show'
      ..style.zIndex = '3000'
      ..style.overflowY = 'auto';

    void closeToast() {
      root.remove();
      document.body?.classes.removeAll(['swal2-toast-shown', 'swal2-shown']);
    }

    root.onClick.listen((_) => closeToast());

    final popup = DivElement()
      ..className = 'swal2-popup swal2-toast swal2-icon-$type swal2-show'
      ..attributes['role'] = 'alert'
      ..attributes['aria-live'] = 'polite';

    final icon = DivElement()
      ..className = 'swal2-icon swal2-$type swal2-icon-show';

    if (type == 'warning') {
      icon.append(DivElement()
        ..className = 'swal2-icon-content'
        ..text = '!');
    } else if (type == 'success') {
      icon
        ..append(DivElement()..className = 'swal2-success-circular-line-left')
        ..append(SpanElement()..className = 'swal2-success-line-tip')
        ..append(SpanElement()..className = 'swal2-success-line-long')
        ..append(DivElement()..className = 'swal2-success-ring')
        ..append(DivElement()..className = 'swal2-success-fix')
        ..append(DivElement()..className = 'swal2-success-circular-line-right');
    }

    final htmlContainer = DivElement()
      ..className = 'swal2-html-container d-block'
      ..text = message;

    final progressContainer = DivElement()
      ..className = 'swal2-timer-progress-bar-container';

    final progressBar = DivElement()
      ..className = 'swal2-timer-progress-bar'
      ..style.transition = 'none';

    progressContainer.append(progressBar);

    popup
      ..append(icon)
      ..append(htmlContainer)
      ..append(progressContainer);

    root.append(popup);
    document.body?.append(root);
    document.body?.classes.addAll(['swal2-toast-shown', 'swal2-shown']);

    final start = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final remaining = duration - elapsed;

      if (remaining <= 0) {
        timer.cancel();
        closeToast();
        return;
      }

      final progress = remaining / duration;
      progressBar.style.width = '${(progress * 100).clamp(0, 100)}%';
    });
  }
}
