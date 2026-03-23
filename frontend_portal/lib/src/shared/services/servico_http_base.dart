import 'dart:convert';
import 'dart:html';

import 'package:ngdart/angular.dart';

import '../rest_config.dart';

@Injectable()
class ServicoHttpBase {
  ServicoHttpBase(this.restConfig);

  final RestConfig restConfig;

  String get apiBaseUrl => restConfig.apiBaseUrl;

  Future<Map<String, dynamic>> getJsonMap(String caminho) async {
    final resposta = await HttpRequest.getString('$apiBaseUrl$caminho');
    return Map<String, dynamic>.from(jsonDecode(resposta) as Map);
  }

  Future<Map<String, dynamic>> sendJsonMap(
    String caminho, {
    required String metodo,
    Map<String, dynamic>? corpo,
    Map<String, String>? headers,
  }) async {
    final resposta = await HttpRequest.request(
      '$apiBaseUrl$caminho',
      method: metodo,
      sendData: corpo == null ? null : jsonEncode(corpo),
      requestHeaders: <String, String>{
        if (corpo != null) 'Content-Type': 'application/json',
        ...?headers,
      },
    );
    return Map<String, dynamic>.from(
      jsonDecode(resposta.responseText ?? '{}') as Map,
    );
  }
}