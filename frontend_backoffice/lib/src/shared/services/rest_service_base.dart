import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:essential_core/essential_core.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/src/shared/extensions/http_response_extension.dart';
import 'package:nexus_frontend_backoffice/src/shared/rest_config.dart';

class RestServiceBase {
  final RestConfig conf;
  RestServiceBase(this.conf);

  Never _throwForErrorResponse(http.Response resp) {
    try {
      final decoded = jsonDecode(resp.bodyUtf8);
      if (decoded is Map<String, dynamic>) {
        throw ApiProblemException.fromMap(decoded);
      }
    } catch (e) {
      if (e is ApiProblemException) {
        throw e;
      }
    }

    throw ApiProblemException(
      status: resp.statusCode,
      title: 'Erro HTTP',
      detail: resp.bodyUtf8.isNotEmpty
          ? resp.bodyUtf8
          : 'O servidor retornou um erro sem corpo.',
    );
  }

  Future<List<Map<String, dynamic>>> getAllJson(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, String>? headers}) async {
    final resp = await rawGet(
      conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
      headers: headers,
    );

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.bodyUtf8);
      if (json is! List) {
        throw Exception(
            'RestServiceBase@getAllJson os dados não são uma lista $path ${resp.bodyUtf8}');
      }
      return json.map((e) => e as Map<String, dynamic>).toList();
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> getJson(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, String>? headers}) async {
    final resp = await rawGet(
      conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
      headers: headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<DataFrame<T>> getDataFrame<T>(String path,
      {T Function(Map<String, dynamic>)? builder,
      Filters? filtros,
      Map<String, String?>? queryParameters,
      Map<String, String>? headers}) async {
    Map<String, dynamic>? queryPara = {};
    if (filtros != null) {
      queryPara.addAll(filtros.getParams());
    }
    if (queryParameters != null) {
      queryPara.addAll(queryParameters);
    }
    if (queryPara.isEmpty) {
      queryPara = null;
    }

    final json = await getJson(
      path,
      queryParameters: queryPara,
      headers: headers,
    );
    return DataFrame<T>.fromMapWithFactory(json, builder);
  }

  Future<List<T>> getListEntity<T>(String path,
      {required T Function(Map<String, dynamic>) builder,
      Filters? filtros,
      Map<String, String?>? queryParameters,
      Map<String, String>? headers}) async {
    Map<String, dynamic>? queryPara = {};
    if (filtros != null) {
      queryPara.addAll(filtros.getParams());
    }
    if (queryParameters != null) {
      queryPara.addAll(queryParameters);
    }
    if (queryPara.isEmpty) {
      queryPara = null;
    }

    final json = await getJson(
      path,
      queryParameters: queryPara,
      headers: headers,
    );
    return List<T>.from((json as List).map((e) => builder(e)));
  }

  Future<List<Map<String, dynamic>>> getListMap(String path,
      {Filters? filtros, Map<String, String>? headers}) async {
    final json = await getJson(
      path,
      queryParameters: filtros?.getParams(),
      headers: headers,
    );
    return (json as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<T> getEntity<T>(String path,
      {required T Function(Map<String, dynamic>) builder,
      Map<String, dynamic>? queryParameters,
      Map<String, String>? headers}) async {
    final json = await getJson(
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    return builder(json);
  }

  Future<dynamic> insertEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    final resp = await rawPost(
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
        body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> postEntity(Map<String, dynamic> entity, String path,
      {Map<String, String>? queryParameters}) async {
    final resp = await rawPost(
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
        body: jsonEncode(entity));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> updateEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    final resp = await rawPut(
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
        body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> patchEntity(String path,
      {Map<String, String>? queryParameters, SerializeBase? entity}) async {
    final resp = await rawPatch(
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
        body: entity != null ? jsonEncode(entity.toMap()) : null);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> patchMap(String path,
      {Map<String, String>? queryParameters, Map<String, dynamic>? map}) async {
    final resp = await rawPatch(
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters),
        body: map != null ? jsonEncode(map) : null);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> deleteAllEntity(List<SerializeBase> entities, String path,
      {Map<String, String>? queryParameters}) async {
    final uri =
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters);
    final body = jsonEncode(entities.map((e) => e.toMap()).toList());

    final resp = await rawDelete(uri, body: body);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<dynamic> deleteEntity(
    String path, {
    SerializeBase? entity,
    Map<String, String>? queryParameters,
  }) async {
    final uri =
        conf.getBackendUri(endpoint: path, queryParameters: queryParameters);
    final body = entity != null ? jsonEncode(entity.toMap()) : null;
    final resp = await rawDelete(uri, body: body);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      _throwForErrorResponse(resp);
    }
  }

  Future<http.Response> rawGet(Uri url, {Map<String, String>? headers}) async {
    final resp = await sendWithRetry(
      (auth) => http.get(url, headers: {...auth, ...?headers}),
    );
    return resp;
  }

  Future<http.Response> rawPost(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding = utf8,
  }) async {
    final resp = await sendWithRetry(
      (auth) => http.post(
        url,
        headers: {...auth, ...?headers},
        body: body,
        encoding: encoding,
      ),
    );
    return resp;
  }

  Future<http.Response> rawPut(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding = utf8,
  }) async {
    final resp = await sendWithRetry(
      (auth) => http.put(
        url,
        headers: {...auth, ...?headers},
        body: body,
        encoding: encoding,
      ),
    );
    return resp;
  }

  Future<http.Response> rawPatch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding = utf8,
  }) async {
    final resp = await sendWithRetry(
      (auth) => http.patch(
        url,
        headers: {...auth, ...?headers},
        body: body,
        encoding: encoding,
      ),
    );
    return resp;
  }

  Future<http.Response> rawDelete(
    Uri uri, {
    Object? body,
    Map<String, String>? headers,
    Encoding encoding = utf8,
  }) async {
    final resp = await sendWithRetry((auth) async {
      final request = http.Request('DELETE', uri);
      request.headers.addAll({...auth, ...?headers});

      if (body != null) {
        if (body is String) {
          request.body = body;
        } else if (body is List) {
          request.bodyBytes = body.cast<int>();
        } else if (body is Map) {
          request.bodyFields = body.cast<String, String>();
        } else {
          throw ArgumentError('Invalid request body "$body".');
        }
      } else {
        request.headers.remove('Content-type');
      }

      return http.Response.fromStream(await request.send());
    });

    return resp;
  }

  Future<http.Response> sendWithRetry(
    Future<http.Response> Function(Map<String, String> h) send,
  ) async {
    final h1 = await conf.getHeadersWithAuth();
    final resp1 = await send(h1);
    if (resp1.statusCode != 401) return resp1;

    final h2 = await conf.getHeadersWithAuth();
    return await send(h2);
  }
}
