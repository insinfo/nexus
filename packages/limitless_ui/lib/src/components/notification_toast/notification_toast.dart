//C:\MyDartProjects\new_sali\frontend\lib\src\shared\components\notification_toast\notification_toast.dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'notification_toast_service.dart';

/// Top navigation component.
@Component(
  selector: 'notification-outlet',
  templateUrl: 'notification_toast.html',
  styleUrls: ['notification_toast.css'],
  directives: [
    coreDirectives,
  ],
  exports: [
    NotificationToastColor,
  ],
)
class NotificationToast {
  final Router _router;

  @Input()
  NotificationToastService? service;

  NotificationToast(this._router);

  /// Produce a CSS style for the `top` property.
  String styleTop(int i) {
    return '${i * 20}px';
  }

  void closeToast(Toast toast) {
    service?.toasts.remove(toast);
  }

  void onToastClick(Toast toast) {
    if (toast.link != null && toast.link!.isNotEmpty) {
      final link = toast.link!;
      if (link.contains('?')) {
        final parts = link.split('?');
        final path = parts[0];
        final query = parts[1];
        final queryParams = Uri.splitQueryString(query);
        _router.navigate(path, NavigationParams(queryParameters: queryParams));
      } else {
        _router.navigate(link);
      }
      closeToast(toast);
    }
  }
}
