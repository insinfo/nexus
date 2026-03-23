import 'package:essential_core/essential_core.dart';

abstract class DadosNoFluxo implements SerializeBase {
  DadosNoFluxo();

  String get tipoNo;
  String get rotulo;
  set rotulo(String value);
}
