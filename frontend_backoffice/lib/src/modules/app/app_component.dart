import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

@Component(
  selector: 'app-root',
  templateUrl: 'app_component.html',
  styleUrls: <String>['app_component.css'],
  directives: <Object>[coreDirectives, RouterOutlet],
  exports: <Object>[PagesRoutes],
)
class AppComponent implements OnInit {
  AppComponent();

  @override
  void ngOnInit() {}
}
