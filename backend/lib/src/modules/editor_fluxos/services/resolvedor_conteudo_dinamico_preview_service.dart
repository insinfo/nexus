import 'package:nexus_core/nexus_core.dart';

import '../../runtime/services/executor_conteudo_dinamico_service.dart';

class ResolvedorConteudoDinamicoPreviewService {
  const ResolvedorConteudoDinamicoPreviewService(
      this._executorConteudoDinamicoService);

  final ExecutorConteudoDinamicoService _executorConteudoDinamicoService;

  Future<Map<String, dynamic>> resolver({
    required NoFluxoDto no,
    required Map<String, dynamic> contexto,
  }) async {
    final resultado = await _executorConteudoDinamicoService.executar(
      no: no,
      contexto: contexto,
    );
    return <String, dynamic>{
      'metodo': resultado['requisicao']?['metodo'],
      'url': resultado['requisicao']?['url'],
      'status_code': resultado['status_code'],
      'sucesso': resultado['sucesso'],
      'tipo_erro': resultado['tipo_erro'],
      'mensagem_erro': resultado['mensagem_erro'],
      'cabecalhos':
          resultado['resposta']?['cabecalhos'] ?? const <String, dynamic>{},
      'corpo': resultado['resposta']?['corpo'],
      'timeout_ms': resultado['requisicao']?['timeout_ms'],
    };
  }
}
