import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';
import 'di.template.dart' as self;

@GenerateInjector([
  routerProvidersHash,
  ClassProvider(RestConfig),
  ClassProvider(CatalogoService),
  ClassProvider(BuilderService),
])
final InjectorFactory injector = self.injector$Injector;
