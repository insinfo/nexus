import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../repositories/portal_publico_repository.dart';

class PortalPublicoController {
  static Future<Response> buscarPaginaInicial(Request req) async {
    try {
      final repo = req.make<PortalPublicoRepository>();
      final dados = await repo.buscarPaginaInicial();
      return responseJson(dados.toMap());
    } catch (e, s) {
      print('PortalPublicoController@buscarPaginaInicial $e $s');
      return responseError(
        'Falha ao carregar a pagina inicial do portal.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> listarNoticias(Request req) async {
    try {
      final repo = req.make<PortalPublicoRepository>();
      final data = await repo.listarNoticias();
      return responseDataFrame(data);
    } catch (e, s) {
      print('PortalPublicoController@listarNoticias $e $s');
      return responseError(
        'Falha ao listar noticias do portal.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> listarPublicacoesOficiais(Request req) async {
    try {
      final repo = req.make<PortalPublicoRepository>();
      final data = await repo.listarPublicacoesOficiais();
      return responseDataFrame(data);
    } catch (e, s) {
      print('PortalPublicoController@listarPublicacoesOficiais $e $s');
      return responseError(
        'Falha ao listar publicacoes oficiais.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> listarPaginasInstitucionais(Request req) async {
    try {
      final repo = req.make<PortalPublicoRepository>();
      final data = await repo.listarPaginasInstitucionais();
      return responseDataFrame(data);
    } catch (e, s) {
      print('PortalPublicoController@listarPaginasInstitucionais $e $s');
      return responseError(
        'Falha ao listar paginas institucionais.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }
}
