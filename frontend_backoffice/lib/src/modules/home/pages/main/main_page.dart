import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';
import 'dart:async';

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
  Timer? _sidebarEnterTimer;
  Timer? _sidebarLeaveTimer;

  bool isSidebarResized = false;
  bool isSidebarUnfold = false;
  bool isSidebarMobileExpanded = false;

  int get todayYear => DateTime.now().year;

  bool get exibirRodape {
    final path = _router.current?.path ?? '';
    return !path.contains('builder');
  }

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

  void toggleSidebarResize() {
    isSidebarResized = !isSidebarResized;
    if (!isSidebarResized) {
      isSidebarUnfold = false;
    }
  }

  void onSidebarMouseEnter() {
    _sidebarLeaveTimer?.cancel();
    _sidebarEnterTimer?.cancel();
    _sidebarEnterTimer = Timer(const Duration(milliseconds: 150), () {
      if (isSidebarResized) {
        isSidebarUnfold = true;
      }
    });
  }

  void onSidebarMouseLeave() {
    _sidebarEnterTimer?.cancel();
    _sidebarLeaveTimer?.cancel();
    _sidebarLeaveTimer = Timer(const Duration(milliseconds: 150), () {
      isSidebarUnfold = false;
    });
  }

  void toggleSidebarMobile() {
    isSidebarMobileExpanded = !isSidebarMobileExpanded;
  }
}
