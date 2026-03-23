import 'dart:async';
import 'dart:html' as html;

import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Página de dashboard do backoffice.
///
/// Responsabilidade única: exibir métricas resumidas e lista de serviços
/// conectados ao backend, com navegação para o builder.
@Component(
  selector: 'dashboard-page',
  templateUrl: 'dashboard_page.html',
  styleUrls: <String>['dashboard_page.css'],
  directives: <Object>[
    coreDirectives,
  ],
)
class DashboardPage implements OnActivate {
  final CatalogoService _catalogoService;
  final Router _router;
  final html.Element hostElement;

  DashboardPage(
    this.hostElement,
    this._catalogoService,
    this._router,
  );

  bool servicesLoading = false;
  String? servicesError;
  List<ResumoServico> services = <ResumoServico>[];

  final filtro = Filters(limit: 50, offset: 0);

  int get publishedFlowCount {
    int count = 0;
    for (final s in services) {
      if (s.versaoPublicada != null) {
        count++;
      }
    }
    return count;
  }

  String get publishedChannelLabel {
    if (services.isEmpty) return '0';
    return '${services.length}';
  }

  @override
  void onActivate(RouterState? previous, RouterState current) {
    unawaited(_loadServices());
  }

  Future<void> _loadServices() async {
    servicesLoading = true;
    servicesError = null;
    try {
      final df = await _catalogoService.listServicos(filtro);
      services = df.items.toList();
    } catch (e, s) {
      print('DashboardPage@_loadServices $e $s');
      servicesError = 'Erro ao carregar serviços: $e';
    } finally {
      servicesLoading = false;
    }
  }

  Future<void> abrirBuilder(String serviceId) async {
    final url = RoutePaths.builder.toUrl();
    await _router.navigate(
      url,
      NavigationParams(queryParameters: <String, String>{'servico': serviceId}),
    );
  }

  Future<void> navegarParaNovoServico() async {
    final url = RoutePaths.builder.toUrl();
    await _router.navigate(
      url,
      NavigationParams(queryParameters: <String, String>{'novo': 'true'}),
    );
  }
}
