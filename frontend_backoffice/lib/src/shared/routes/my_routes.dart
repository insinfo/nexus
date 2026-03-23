import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';
import 'package:nexus_frontend_backoffice/src/modules/home/pages/main/main_page.template.dart'
    as main_page_template;

import 'route_paths.dart';

class PagesRoutes {
  static final main = RouteDefinition(
    routePath: RoutePaths.main,
    component: main_page_template.MainPageNgFactory,
    useAsDefault: true,
  );

  static final allPublic = <RouteDefinition>[
    main,
  ];
}
