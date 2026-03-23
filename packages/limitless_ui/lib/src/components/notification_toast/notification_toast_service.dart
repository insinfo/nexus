//C:\MyDartProjects\new_sali\frontend\lib\src\shared\components\notification_toast\notification_toast_service.dart
import 'dart:async';
import 'dart:html' as html;

enum NotificationToastColor {
  primary,
  secondary,
  success,
  info,
  warning,
  danger,
  pink,
  teal,
  indigo,
  none,
}

extension NotificationToastColorExtension on NotificationToastColor {
  String asString() {
    switch (this) {
      case NotificationToastColor.primary:
        return 'primary';
      case NotificationToastColor.secondary:
        return 'secondary';
      case NotificationToastColor.success:
        return 'success';
      case NotificationToastColor.info:
        return 'info';
      case NotificationToastColor.warning:
        return 'warning';
      case NotificationToastColor.danger:
        return 'danger';
      case NotificationToastColor.pink:
        return 'pink';
      case NotificationToastColor.teal:
        return 'teal';
      case NotificationToastColor.indigo:
        return 'indigo';
      case NotificationToastColor.none:
        return 'none';
    }
  }
}

NotificationToastColor _stringAsNotificationCompColor(String val) {
  switch (val) {
    case 'primary':
      return NotificationToastColor.primary;
    case 'secondary':
      return NotificationToastColor.secondary;
    case 'success':
      return NotificationToastColor.success;
    case 'info':
      return NotificationToastColor.info;
    case 'warning':
      return NotificationToastColor.warning;
    case 'danger':
      return NotificationToastColor.danger;
    case 'pink':
      return NotificationToastColor.pink;
    case 'teal':
      return NotificationToastColor.teal;
    case 'indigo':
      return NotificationToastColor.indigo;
    case 'none':
      return NotificationToastColor.none;
    default:
      // return 'unknown';
      throw Exception('NotificationCompColor unknown');
  }
}

class ToastSoundController {
  late final html.AudioElement audio;
  bool userInteracted = false;

  ToastSoundController() {
    audio = html.AudioElement()
      ..src = 'assets/audio/level-up-191997.mp3'
      ..preload = 'auto';
    // Marque interação em qualquer click/keypress
    html.document.onClick.first.then((_) => userInteracted = true);
    html.document.onKeyDown.first.then((_) => userInteracted = true);
  }

  Future<void> playOnceSafely() async {
    if (!userInteracted) return; // evita NotAllowedError
    try {
      // reusa sempre o mesmo elemento; não crie novos
      await audio.play();
    } catch (_) {
      // ignore: política do navegador
    }
  }
}

/// A service that manages toasts that should be displayed.
//@Injectable()
class NotificationToastService {
  /// A list of toasts that should be displayed.
  List<Toast> toasts = [];

  final StreamController<Toast> _onNotifyStreamController;
  Stream<Toast> get onNotify => _onNotifyStreamController.stream;
  final sound = ToastSoundController();

  /// Constructor.
  NotificationToastService()
      : _onNotifyStreamController = StreamController<Toast>.broadcast();

  void notify(
    String message, {
    NotificationToastColor type = NotificationToastColor.success,
    String? title = 'Informação',
    String? icon,
    int durationSeconds = 3,
    bool enableSound = false,
    String? link,
  }) {
    final toast = Toast(
      type: type,
      title: title,
      message: message,
      icon: icon,
      durationSeconds: durationSeconds,
      link: link,
    );
    if (enableSound) {
      try {
        sound.playOnceSafely();
      } catch (e) {
        print('NotificationComponentService@notify $e');
      }
    }

    toasts.insert(0, toast);
    _onNotifyStreamController.add(toast);

    final milliseconds = ((1000 * toast.durationSeconds) + 300).round();
    // How to get size of each toast?
    Timer(Duration(milliseconds: milliseconds), () {
      toast.toBeDeleted = true;
      Timer(Duration(milliseconds: 300), () {
        toasts.remove(toast);
      });
    });
  }

  /// Display a toast.
  void add(NotificationToastColor type, String title, String message,
      {String? icon, int durationSeconds = 3, String? link}) {
    final toast = Toast(
      type: type,
      title: title,
      message: message,
      icon: icon,
      durationSeconds: durationSeconds,
      link: link,
    );
    toasts.insert(0, toast);
    final milliseconds = (1000 * toast.durationSeconds + 300).round();
    // How to get size of each toast?
    Timer(Duration(milliseconds: milliseconds), () {
      toast.toBeDeleted = true;
      Timer(Duration(milliseconds: 300), () {
        toasts.remove(toast);
      });
    });
  }
}

/// Data model for a toast, a.k.a. pop-up notification.
class Toast {
  /// The type (color) of this toast.
  NotificationToastColor type;

  /// The title to display (optional).
  String? title;

  /// The message to diplay.
  String message;

  /// The icon to display. If not specified, an icon is selected automatically
  /// based on `type`.
  String? icon;

  /// Link para redirecionamento ao clicar (opcional)
  String? link;

  /// How long to display the toast before removing it.
  int durationSeconds;

  /// Duration as a CSS property string.
  String get cssDuration => '${durationSeconds}s';

  /// Set to true before the item is deleted. This allows time to fade the
  /// item out.
  bool toBeDeleted = false;

  /// data de criação
  late DateTime created;

  String get cssAnimation => toBeDeleted == true
      ? 'toast-fade-out 0.3s ease-out'
      : 'toast-fade-in 0.3s ease-in';

  /// Constructor
  Toast(
      {this.type = NotificationToastColor.info,
      this.title,
      required this.message,
      this.icon,
      this.link,
      this.durationSeconds = 3}) {
    created = DateTime.now();
    if (icon == null) {
      if (type == NotificationToastColor.success) {
        icon = 'check';
      } else if (type == NotificationToastColor.info) {
        icon = 'info';
      } else if (type == NotificationToastColor.warning) {
        icon = 'exclamation';
      } else if (type == NotificationToastColor.danger) {
        icon = 'times';
      } else {
        icon = 'bullhorn';
      }
    }
  }

  factory Toast.fromMap(Map<String, dynamic> map) {
    final t = Toast(
      message: map['message'],
      icon: map['icon'],
      title: map['title'],
      durationSeconds: map['durationSeconds'],
    );
    t.type = _stringAsNotificationCompColor(map['type']);
    t.toBeDeleted = map['toBeDeleted'];
    if (map.containsKey('created')) {
      final dt = DateTime.tryParse(map['created']);
      if (dt != null) {
        t.created = dt;
      }
    }
    return t;
  }

  Map<String, dynamic> toMap() {
    final map = {
      'type': type.asString(),
      'title': title,
      'message': message,
      'icon': icon,
      'durationSeconds': durationSeconds,
      'toBeDeleted': toBeDeleted,
      'created': created.toIso8601String(),
    };
    return map;
  }

  String get bgColor {
    if (type == NotificationToastColor.primary) {
      return 'bg-primary';
    } else if (type == NotificationToastColor.secondary) {
      return 'bg-secondary';
    } else if (type == NotificationToastColor.success) {
      return 'bg-success';
    } else if (type == NotificationToastColor.info) {
      return 'bg-info';
    } else if (type == NotificationToastColor.warning) {
      return 'bg-warning';
    } else if (type == NotificationToastColor.danger) {
      return 'bg-danger';
    } else if (type == NotificationToastColor.primary) {
      return 'bg-primary';
    } else if (type == NotificationToastColor.pink) {
      return 'bg-pink';
    } else if (type == NotificationToastColor.teal) {
      return 'bg-teal';
    } else if (type == NotificationToastColor.indigo) {
      return 'bg-indigo';
    } else {
      return 'bg-white';
    }
  }
}
