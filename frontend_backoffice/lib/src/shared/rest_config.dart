import 'dart:html' as html;
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Configuração de conexão com o backend do Nexus.
///
/// Segue o mesmo padrão do Salus RestConfig com injeção lazy do Router
/// para evitar dependência cíclica no ngrouter.
class RestConfig {
  Future<Map<String, String>> getHeadersWithAuth() async {
    return {
      'Authorization': 'Bearer 123',
      'Accept': 'application/json',
      'Content-type': 'application/json;charset=utf-8',
    };
  }

  String backendProtocol = 'http';
  String backendDomain = 'localhost';
  int backendPort = 8086;
  String get domainWithPort => '$backendDomain:$backendPort';

  /// Alias ou location configurado no nginx.
  String backendAliasBasePath = '';
  String backendApiBasePath = '/api/v1';

  // Lazily inject `Router` to avoid cyclic dependency.
  final Injector _injector;
  Router? _router;
  Router get router => _router ??= _injector.provideType(Router);

  String get currentFrontHost => html.window.location.hostname ?? '';
  String get currentFrontPort => html.window.location.port;
  String get currentFrontProtocol => html.window.location.protocol;

  RestConfig(this._injector) {
    // Produção futura: configurar domínio, porta e protocolo por hostname.
    // Por enquanto, usa localhost:8086 como padrão de desenvolvimento.
    if (html.window.location.hostname?.startsWith('nexus') == true &&
        html.window.location.protocol.contains('https')) {
      backendProtocol = 'https';
      backendPort = 443;
      backendAliasBasePath = '/backend';
    }
  }

  bool get isBackendDefaultPort =>
      (backendProtocol == 'https' && backendPort == 443) ||
      (backendProtocol == 'http' && backendPort == 80);

  String get backendUrlNoApiBasePath {
    return getBackendUri(withApiBasePath: false).toString();
  }

  /// Retorna a [Uri] do backend.
  /// [withApiBasePath] se true traz o base path da API.
  Uri getBackendUri({
    String? endpoint,
    Map<String, dynamic>? queryParameters,
    bool withApiBasePath = true,
  }) {
    Map<String, String>? qp;
    if (queryParameters != null) {
      qp = {
        for (final entry in queryParameters.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      };
      if (qp.isEmpty) qp = null;
    }

    final segments = <String>[
      ..._toSegments(backendAliasBasePath),
      if (withApiBasePath) ..._toSegments(backendApiBasePath),
      ..._toSegments(endpoint),
    ];

    return Uri(
      scheme: backendProtocol,
      host: backendDomain,
      port: isBackendDefaultPort ? null : backendPort,
      pathSegments: segments,
      queryParameters: qp,
    );
  }

  String _normalizePart(String? p) {
    if (p == null) return '';
    final s = p.trim();
    if (s.isEmpty) return '';
    return s.replaceAll(RegExp(r'^/+|/+$'), '');
  }

  List<String> _toSegments(String? p) {
    final s = _normalizePart(p);
    if (s.isEmpty) return const [];
    return s.split('/').where((e) => e.isNotEmpty).toList();
  }

  String buildFrontUrl([String? path]) {
    final scheme = currentFrontProtocol.replaceAll(':', '');
    final host = currentFrontHost;
    final portStr = currentFrontPort;
    final int? port = portStr.isEmpty ? null : int.tryParse(portStr);
    final base = Uri(scheme: scheme, host: host, port: port);
    if (path == null || path.trim().isEmpty) {
      return base.toString();
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return base.replace(path: normalized).toString();
  }
}
