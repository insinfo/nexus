import 'dart:convert';

import 'package:essential_core/essential_core.dart';
import 'package:shelf/shelf.dart';

const Map<String, String> _defaultHeaders = {
  'Content-Type': 'application/json; charset=utf-8',
};
const Map<String, String> _problemHeaders = {
  'Content-Type': 'application/problem+json; charset=utf-8',
};

/// Resposta JSON genérica (RFC 7807 simplificado)
Response responseProblem({
  required int status,
  required String titulo,
  required String detalhe,
  dynamic exception,
  dynamic stackTrace,
}) {
  final body = <String, dynamic>{
    'type': 'about:blank',
    'title': titulo,
    'status': status,
    'detail': detalhe,
    if (exception != null) 'exception': exception.toString(),
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
  };
  return Response(
    status,
    body: jsonEncode(body, toEncodable: _encoderJson),
    headers: _problemHeaders,
  );
}

/// Erro genérico (422 por padrão)
Response responseError(
  String detalhe, {
  dynamic exception,
  dynamic stackTrace,
  int statusCode = 422,
}) {
  return responseProblem(
    status: statusCode,
    titulo: _tituloPadrao(statusCode),
    detalhe: detalhe,
    exception: exception,
    stackTrace: stackTrace,
  );
}

/// Resposta JSON simples
Response responseJson(Object? payload, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(payload, toEncodable: _encoderJson),
    headers: _defaultHeaders,
  );
}

/// Resposta padronizada para listagens em DataFrame.
Response responseDataFrame(DataFrame dataFrame, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: dataFrame.toJson(),
    headers: <String, String>{
      ..._defaultHeaders,
      'total-records': '${dataFrame.totalRecords}',
    },
  );
}

/// Resposta de sucesso sem corpo
Response responseSuccess({String mensagem = 'Sucesso', int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode({'mensagem': mensagem}, toEncodable: _encoderJson),
    headers: _defaultHeaders,
  );
}

dynamic _encoderJson(dynamic item) {
  if (item is num || item is String || item is bool) return item;
  if (item is DateTime) return item.toIso8601String();
  return item.toString();
}

String _tituloPadrao(int code) {
  switch (code) {
    case 400:
      return 'Requisição inválida';
    case 401:
      return 'Não autorizado';
    case 403:
      return 'Acesso negado';
    case 404:
      return 'Não encontrado';
    case 409:
      return 'Conflito';
    case 422:
      return 'Entidade não processável';
    default:
      return 'Erro interno do servidor';
  }
}
