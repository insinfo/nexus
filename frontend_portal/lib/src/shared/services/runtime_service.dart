import 'package:ngdart/angular.dart';
import 'package:nexus_core/nexus_core.dart';

import 'servico_http_base.dart';

@Injectable()
class RuntimeService {
  RuntimeService(this._servicoHttpBase);

  final ServicoHttpBase _servicoHttpBase;

  Future<EstadoPassoRuntime> iniciarSessao(String idServico) async {
    final jsonMap = await _servicoHttpBase.sendJsonMap(
      '/runtime/sessoes',
      metodo: 'POST',
      corpo: RequisicaoIniciarSessao(idServico: idServico).toMap(),
    );
    return EstadoPassoRuntime.fromMap(jsonMap);
  }

  Future<EstadoPassoRuntime> avancarSessao(
    String idSessao,
    Map<String, dynamic> respostas,
  ) async {
    final jsonMap = await _servicoHttpBase.sendJsonMap(
      '/runtime/sessoes/$idSessao/avancar',
      metodo: 'POST',
      corpo: RequisicaoAvancarPasso(respostas: respostas).toMap(),
    );
    return EstadoPassoRuntime.fromMap(jsonMap);
  }
}