import 'dart:async';
import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Componente para inspeção e edição de propriedades de um nó do fluxo.
@Component(
  selector: 'inspetor-no',
  templateUrl: 'inspetor_no_component.html',
  styleUrls: ['inspetor_no_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  exports: [
    TipoNoFluxo,
  ],
)
class InspetorNoComponent {
  @Input()
  NoFluxoDto? no;

  @Input()
  ArestaFluxoDto? aresta;

  final _onChange = StreamController<void>.broadcast();
  @Output()
  Stream<void> get onChange => _onChange.stream;

  final _onRemove = StreamController<void>.broadcast();
  @Output()
  Stream<void> get onRemove => _onRemove.stream;

  bool get temSelecao => no != null || aresta != null;

  void notifyChange() => _onChange.add(null);
  void remove() => _onRemove.add(null);

  String get tipoNoLabel => no?.tipo.label ?? '';

  // Auxiliares para o template
  DadosNoFormulario? get dadosForm => no?.tipo == TipoNoFluxo.formulario ? no!.dados as DadosNoFormulario : null;
  DadosNoApresentacao? get dadosApres => no?.tipo == TipoNoFluxo.apresentacao ? no!.dados as DadosNoApresentacao : null;
  DadosNoCondicao? get dadosCond => no?.tipo == TipoNoFluxo.condicao ? no!.dados as DadosNoCondicao : null;
}
