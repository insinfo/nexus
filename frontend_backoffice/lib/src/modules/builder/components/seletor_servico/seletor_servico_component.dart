import 'dart:async';
import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Componente para seleção de serviço, versão e fluxo no editor.
@Component(
  selector: 'seletor-servico',
  templateUrl: 'seletor_servico_component.html',
  styleUrls: ['seletor_servico_component.css'],
  directives: [coreDirectives],
)
class SeletorServicoComponent {
  @Input()
  List<ResumoServico> services = [];

  @Input()
  List<ResumoVersaoServico> versions = [];

  @Input()
  VersaoServicoDto? selectedVersion;

  @Input()
  String? selectedServiceId;

  @Input()
  String? selectedVersionId;

  @Input()
  String? selectedFlowId;

  final _onServiceChange = StreamController<String>.broadcast();
  @Output()
  Stream<String> get onServiceChange => _onServiceChange.stream;

  final _onVersionChange = StreamController<String>.broadcast();
  @Output()
  Stream<String> get onVersionChange => _onVersionChange.stream;

  final _onFlowChange = StreamController<String>.broadcast();
  @Output()
  Stream<String> get onFlowChange => _onFlowChange.stream;

  void serviceChanged(String val) => _onServiceChange.add(val);
  void versionChanged(String val) => _onVersionChange.add(val);
  void flowChanged(String val) => _onFlowChange.add(val);
}
