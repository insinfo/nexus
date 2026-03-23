import 'dart:html' as html;

class RestConfig {
  String backendProtocol = 'http';
  String backendDomain = '127.0.0.1';
  int backendPort = 8086;
  String backendApiBasePath = '/api/v1';

  bool get isBackendDefaultPort =>
      (backendProtocol == 'https' && backendPort == 443) ||
      (backendProtocol == 'http' && backendPort == 80);

  String get apiBaseUrl => getBackendUri().toString();

  String get currentFrontHost => html.window.location.hostname ?? '';

  String get currentFrontProtocol => html.window.location.protocol;

  RestConfig() {
    final host = currentFrontHost;
    final protocol = currentFrontProtocol.replaceAll(':', '');
    if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
      backendDomain = host;
      backendProtocol = protocol.isEmpty ? backendProtocol : protocol;
      backendPort = backendProtocol == 'https' ? 443 : 80;
    }
  }

  Uri getBackendUri({
    String? endpoint,
    Map<String, dynamic>? queryParameters,
  }) {
    Map<String, String>? qp;
    if (queryParameters != null) {
      qp = <String, String>{
        for (final entry in queryParameters.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      };
      if (qp.isEmpty) {
        qp = null;
      }
    }

    final segments = <String>[
      ..._toSegments(backendApiBasePath),
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

  String _normalizePart(String? value) {
    if (value == null) {
      return '';
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.replaceAll(RegExp(r'^/+|/+$'), '');
  }

  List<String> _toSegments(String? value) {
    final normalized = _normalizePart(value);
    if (normalized.isEmpty) {
      return const <String>[];
    }
    return normalized
        .split('/')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}