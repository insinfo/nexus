import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../repositories/catalogo_servicos_repository.dart';

class CatalogoServicosController {
  static Future<Response> listar(Request req) async {
    try {
      final repo = req.make<CatalogoServicosRepository>();
      final data = await repo.list();
      return responseDataFrame(data);
    } catch (e, s) {
      print('CatalogoServicosController@listar $e $s');
      return responseError(
        'Falha ao listar serviços',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> buscarPorId(Request req, String id) async {
    try {
      final repo = req.make<CatalogoServicosRepository>();
      final item = await repo.findById(id);
      if (item == null) {
        return responseError('Serviço não encontrado: $id', statusCode: 404);
      }
      return responseJson(item.toMap());
    } catch (e, s) {
      print('CatalogoServicosController@buscarPorId $e $s');
      return responseError(
        'Falha ao carregar serviço',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> listarVersoes(Request req, String id) async {
    try {
      final repo = req.make<CatalogoServicosRepository>();
      final data = await repo.listVersoes(id);
      return responseDataFrame(data);
    } catch (e, s) {
      print('CatalogoServicosController@listarVersoes $e $s');
      return responseError(
        'Falha ao listar versões do serviço',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> listarFluxos(Request req, String id) async {
    try {
      final idVersao = req.url.queryParameters['id_versao'];
      final repo = req.make<CatalogoServicosRepository>();
      final data = await repo.listFluxos(id, idVersao: idVersao);
      return responseDataFrame(data);
    } catch (e, s) {
      print('CatalogoServicosController@listarFluxos $e $s');
      return responseError(
        'Falha ao listar fluxos do serviço',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }
}
