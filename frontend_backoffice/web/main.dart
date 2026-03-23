import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';
import 'package:nexus_frontend_backoffice/src/modules/app/app_component.template.dart' as ng;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nexus_frontend_backoffice/src/shared/di/di.dart';

void main() {
  initializeDateFormatting('pt_BR')
      .then((value) => Intl.defaultLocale = 'pt_BR');
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
