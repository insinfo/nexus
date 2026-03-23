import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';

import '../../di/dependency_injector.dart';

/// Extensão de DI para requisições Shelf
extension NexusRequestDI on Request {
  /// Cria (ou obtém) uma instância de [T] usando o contêiner de DI.
  ///
  /// O middleware [withDbShelfMiddleware] garante que o [ioc] esteja
  /// operando em um escopo isolado para esta requisição, com uma
  /// [Connection] dedicada registrada nele.
  T make<T extends Object>() {
    final requestIoc = context['ioc'] as GetIt?;
    return (requestIoc ?? ioc).get<T>();
  }
}

/// Extensão de parsing de corpo para requisições Shelf
extension NexusRequestExtension on Request {
  Future<Map<String, dynamic>> bodyAsMap() async {
    final corpo = await readAsString();
    return json.decode(corpo) as Map<String, dynamic>;
  }

  Future<List<dynamic>> bodyAsList() async {
    final corpo = await readAsString();
    return (json.decode(corpo) as List?) ?? [];
  }
}
