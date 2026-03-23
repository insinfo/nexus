import 'dart:convert';

/// Exceção RFC 7807 (Problem Details for HTTP APIs).
class ApiProblemException implements Exception {
  final Uri? type;
  final int status;
  final String title;
  final String detail;
  final String? instance;
  final String? errorCode;
  final Map<String, dynamic> extensions;

  ApiProblemException({
    this.type,
    required this.status,
    required this.title,
    required this.detail,
    this.instance,
    this.errorCode,
    Map<String, dynamic>? extensions,
  }) : extensions = extensions ?? const {};

  @override
  String toString() => '$status $title: $detail';

  factory ApiProblemException.fromMap(Map<String, dynamic> map) {
    const knownKeys = {
      'type',
      'status',
      'title',
      'detail',
      'instance',
      'error_code',
    };

    return ApiProblemException(
      type: map['type'] != null ? Uri.tryParse(map['type'].toString()) : null,
      status: (map['status'] as num?)?.toInt() ?? 500,
      title: map['title']?.toString() ?? 'Erro',
      detail: map['detail']?.toString() ?? 'Ocorreu um erro inesperado.',
      instance: map['instance']?.toString(),
      errorCode: map['error_code']?.toString(),
      extensions: {
        for (final entry in map.entries)
          if (!knownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  factory ApiProblemException.fromJson(String source) =>
      ApiProblemException.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
