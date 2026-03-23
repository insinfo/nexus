import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/consulta_protocolos_port.dart';

class ConsultaProtocolosController {
  static Future<Response> buscarPorCodigo(Request req, String codigo) async {
    try {
      final servico = req.make<ConsultaProtocolosPort>();
      final protocolo = await servico.buscarPorCodigo(codigo);
      if (protocolo == null) {
        return responseError('Protocolo nao encontrado: $codigo',
            statusCode: 404);
      }
      return responseJson(protocolo.toMap());
    } catch (e, s) {
      print('ConsultaProtocolosController@buscarPorCodigo $e $s');
      return responseError(
        'Falha ao consultar protocolo publico',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }
}
