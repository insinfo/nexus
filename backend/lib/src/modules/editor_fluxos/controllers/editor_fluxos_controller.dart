import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/fluxo_invalido_exception.dart';
import '../services/pre_visualizacao_fluxo_service.dart';
import '../services/validador_fluxo_service.dart';

class EditorFluxosController {
  static Future<Response> validarFluxo(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final fluxo = FluxoDto.fromMap(corpo);
      final service = req.make<ValidadorFluxoService>();
      final resultado = service.validar(fluxo);
      return responseJson(
        resultado.toMap(),
        statusCode: resultado.valido ? 200 : 422,
      );
    } catch (e, s) {
      print('EditorFluxosController@validarFluxo $e $s');
      return responseError(
        'Falha ao validar fluxo',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> preVisualizarFluxo(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      if (corpo['fluxo'] == null) {
        return responseError(
          'O campo fluxo e obrigatorio',
          statusCode: 400,
        );
      }

      final requisicao = RequisicaoPreVisualizacaoFluxo.fromMap(corpo);
      final service = req.make<PreVisualizacaoFluxoService>();
      final resultado = await service.preVisualizar(requisicao);
      return responseJson(resultado.toMap());
    } on FluxoInvalidoException catch (e) {
      return responseJson(e.resultado.toMap(), statusCode: 422);
    } catch (e, s) {
      print('EditorFluxosController@preVisualizarFluxo $e $s');
      return responseError(
        'Falha ao pre-visualizar fluxo',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }
}
