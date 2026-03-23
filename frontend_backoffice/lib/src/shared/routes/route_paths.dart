import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

class RoutePaths {
  static final admin = RoutePath(path: '');
  static final dashboard = RoutePath(path: 'dashboard', parent: admin);
  static final builder = RoutePath(path: 'builder', parent: admin);
  static final operacao = RoutePath(path: 'operacao', parent: admin);
  static final editorial = RoutePath(path: 'editorial', parent: admin);
}
