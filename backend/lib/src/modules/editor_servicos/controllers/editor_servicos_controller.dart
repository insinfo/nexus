import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/editor_servicos_port.dart';
import '../services/servico_rascunho_invalido_exception.dart';

class EditorServicosController {
  static Future<Response> salvarRascunho(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final requisicao = RequisicaoSalvarRascunhoServico.fromMap(corpo);
      final service = req.make<EditorServicosPort>();
      final resultado = await service.salvarRascunho(requisicao);
      return responseJson(resultado.toMap());
    } on ServicoRascunhoInvalidoException catch (e) {
      return responseJson(e.toMap(), statusCode: 422);
    } catch (e, s) {
      print('EditorServicosController@salvarRascunho $e $s');
      return responseError(
        'Falha ao salvar rascunho do servico',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> publicarVersao(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final requisicao = RequisicaoPublicarVersaoServico.fromMap(corpo);
      final service = req.make<EditorServicosPort>();
      final resultado = await service.publicarVersao(requisicao);
      return responseJson(resultado.toMap());
    } catch (e, s) {
      print('EditorServicosController@publicarVersao $e $s');
      return responseError(
        'Falha ao publicar versao do servico',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }
}
