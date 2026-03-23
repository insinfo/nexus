import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';
import 'package:nexus_frontend_backoffice/src/modules/home/pages/main/main_page.template.dart'
    as main_page_template;
import 'package:nexus_frontend_backoffice/src/modules/home/pages/dashboard/dashboard_page.template.dart'
    as dashboard_page_template;
import 'package:nexus_frontend_backoffice/src/modules/home/pages/builder/builder_page.template.dart'
    as builder_page_template;
import 'package:nexus_frontend_backoffice/src/modules/home/pages/operacao/operacao_page.template.dart'
    as operacao_page_template;
import 'package:nexus_frontend_backoffice/src/modules/editorial/pages/editorial/editorial_page.template.dart'
    as editorial_page_template;

class PagesRoutes {
  static final admin = RouteDefinition(
    routePath: RoutePaths.admin,
    component: main_page_template.MainPageNgFactory,
    useAsDefault: true,
  );

  static final dashboard = RouteDefinition(
    routePath: RoutePaths.dashboard,
    component: dashboard_page_template.DashboardPageNgFactory,
    useAsDefault: true,
  );

  static final builder = RouteDefinition(
    routePath: RoutePaths.builder,
    component: builder_page_template.BuilderPageNgFactory,
  );

  static final operacao = RouteDefinition(
    routePath: RoutePaths.operacao,
    component: operacao_page_template.OperacaoPageNgFactory,
  );

  static final editorial = RouteDefinition(
    routePath: RoutePaths.editorial,
    component: editorial_page_template.EditorialPageNgFactory,
  );

  static final allPrivate = <RouteDefinition>[
    dashboard,
    builder,
    operacao,
    editorial,
  ];

  static final allPublic = <RouteDefinition>[
    admin,
  ];
}
