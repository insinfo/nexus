import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

@Component(
  selector: 'main-page',
  templateUrl: 'main_page.html',
  styleUrls: <String>['main_page.css'],
  directives: <Object>[
    coreDirectives,
    routerDirectives,
  ],
  exports: <Object>[RoutePaths, PagesRoutes],
)
class MainPage implements OnInit {
  final Router _router;

  int get todayYear => DateTime.now().year;

  MainPage(this._router);

  bool isRouteActive(String path) {
    if (_router.current == null) {
      if (path == 'dashboard') return true;
      return false;
    }
    return _router.current!.path.contains(path);
  }

  String get pageTitle {
    if (_router.current == null) return 'Dashboard';
    final path = _router.current!.path;
    if (path.contains('builder')) return 'Builder';
    if (path.contains('operacao')) return 'Operação';
    if (path.contains('editorial')) return 'Editorial';
    return 'Dashboard';
  }

  String get pageSubtitle {
    if (_router.current == null) return 'Visão Geral';
    final path = _router.current!.path;
    if (path.contains('builder')) return 'Edição Visual de Fluxos';
    if (path.contains('operacao')) return 'Fila de Trabalho';
    if (path.contains('editorial')) return 'Gestão de Conteúdo';
    return 'Visão Geral';
  }

  @override
  Future<void> ngOnInit() async {}
}
