import 'dart:convert';

import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/autenticacao_exception.dart';
import '../services/provedor_open_id_connect_port.dart';

class ProvedorOpenIdConnectController {
  static Response discovery(Request req) {
    final service = req.make<ProvedorOpenIdConnectPort>();
    final documento = service.obterDocumentoDescoberta();
    return responseJson(documento.toMap());
  }

  static Response jwks(Request req) {
    final service = req.make<ProvedorOpenIdConnectPort>();
    final chaves = service.obterConjuntoChaves();
    return responseJson(chaves.toMap());
  }

  static Future<Response> authorize(Request req) async {
    try {
      final corpo = req.method == 'GET'
          ? Map<String, dynamic>.from(req.url.queryParameters)
          : await req.bodyAsMap();
      final service = req.make<ProvedorOpenIdConnectPort>();
      final resultado = await service.autorizar(
        RequisicaoAutorizarOidc.fromMap(corpo),
        enderecoIp: _enderecoIp(req),
        userAgent: req.headers['user-agent'],
      );
      if (req.method == 'GET') {
        final redirect = Uri.parse(resultado.redirectUri).replace(
          queryParameters: <String, String>{
            'code': resultado.codigo,
            if ((resultado.state ?? '').isNotEmpty) 'state': resultado.state!,
          },
        );
        return Response.found(redirect.toString());
      }
      return responseJson(resultado.toMap(), statusCode: 201);
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('ProvedorOpenIdConnectController@authorize $e $s');
      return responseError(
        'Falha ao executar /oidc/authorize.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> token(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final service = req.make<ProvedorOpenIdConnectPort>();
      final resultado = await service.trocarToken(
        _completarCredenciaisCliente(req, corpo),
        enderecoIp: _enderecoIp(req),
        userAgent: req.headers['user-agent'],
      );
      return responseJson(resultado.toMap());
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('ProvedorOpenIdConnectController@token $e $s');
      return responseError(
        'Falha ao executar /oidc/token.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> userInfo(Request req) async {
    try {
      final service = req.make<ProvedorOpenIdConnectPort>();
      final resultado = await service.obterUsuarioInfo(
        _extrairBearerToken(req.headers['authorization'] ?? ''),
      );
      return responseJson(resultado.toMap());
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('ProvedorOpenIdConnectController@userInfo $e $s');
      return responseError(
        'Falha ao executar /oidc/userinfo.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> logout(Request req) async {
    try {
      final corpoBruto = await req.readAsString();
      final corpo = corpoBruto.trim().isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(corpoBruto) as Map);
      final service = req.make<ProvedorOpenIdConnectPort>();
      await service.encerrarSessao(
        sessionState: corpo['session_state']?.toString(),
        accessToken: _extrairBearerToken(req.headers['authorization'] ?? ''),
      );
      return responseSuccess(
        mensagem: 'Sessao OIDC removida do Redis compartilhado.',
      );
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('ProvedorOpenIdConnectController@logout $e $s');
      return responseError(
        'Falha ao executar /oidc/logout.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> iniciarFederacaoMicrosoft(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final service = req.make<ProvedorOpenIdConnectPort>();
      final resultado = service.iniciarFederacao(
        RequisicaoIniciarFederacaoOidc.fromMap(corpo),
      );
      return responseJson(resultado.toMap());
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('ProvedorOpenIdConnectController@iniciarFederacaoMicrosoft $e $s');
      return responseError(
        'Falha ao iniciar a federacao Microsoft.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static RequisicaoTokenOidc _completarCredenciaisCliente(
    Request req,
    Map<String, dynamic> corpo,
  ) {
    final requisicao = RequisicaoTokenOidc.fromMap(corpo);
    if (requisicao.clientId.trim().isNotEmpty) {
      return requisicao;
    }
    final auth = req.headers['authorization'] ?? '';
    if (!auth.toLowerCase().startsWith('basic ')) {
      return requisicao;
    }
    try {
      final encoded = auth.substring(6).trim();
      final decoded = utf8.decode(base64Decode(encoded));
      final parts = decoded.split(':');
      if (parts.length < 2) {
        return requisicao;
      }
      return requisicao
        ..clientId = parts.first
        ..clientSecret = parts.sublist(1).join(':');
    } catch (_) {
      return requisicao;
    }
  }

  static String _extrairBearerToken(String authorization) {
    final header = authorization.trim();
    if (!header.toLowerCase().startsWith('bearer ')) {
      return '';
    }
    return header.substring(7).trim();
  }

  static String? _enderecoIp(Request req) {
    final forwarded = req.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.trim().isNotEmpty) {
      return forwarded.split(',').first.trim();
    }
    final realIp = req.headers['x-real-ip'];
    if (realIp != null && realIp.trim().isNotEmpty) {
      return realIp.trim();
    }
    return null;
  }
}
