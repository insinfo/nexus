import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/runtime_port.dart';

/// Controlador do módulo de runtime de execução de fluxos.
class RuntimeController {
  static Future<Response> iniciarSessao(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final idServico = corpo['id_servico'] as String?;
      if (idServico == null || idServico.isEmpty) {
        return responseError('O campo id_servico é obrigatório',
            statusCode: 400);
      }
      final canal = (corpo['canal'] as String?) ?? 'portal_cidadao';
      final contextoInicial =
          (corpo['contexto_inicial'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{};

      final repo = req.make<RuntimePort>();
      final estado =
          await repo.iniciarSessao(idServico, canal, contextoInicial);
      return responseJson(estado.toMap(), statusCode: 201);
    } catch (e, s) {
      print('RuntimeController@iniciarSessao $e $s');
      return responseError(
        'Falha ao iniciar sessão',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> obterEstado(Request req, String id) async {
    try {
      final repo = req.make<RuntimePort>();
      final estado = await repo.obterEstado(id);
      if (estado == null) {
        return responseError('Sessão não encontrada: $id', statusCode: 404);
      }
      return responseJson(estado.toMap());
    } catch (e, s) {
      print('RuntimeController@obterEstado $e $s');
      return responseError(
        'Falha ao obter estado da sessão',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> avancarPasso(Request req, String id) async {
    try {
      final corpo = await req.bodyAsMap();
      final respostas = (corpo['respostas'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      final repo = req.make<RuntimePort>();
      final estado = await repo.avancarPasso(id, respostas);
      return responseJson(estado.toMap());
    } catch (e, s) {
      print('RuntimeController@avancarPasso $e $s');
      return responseError(
        'Falha ao avançar passo da sessão',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }
}
