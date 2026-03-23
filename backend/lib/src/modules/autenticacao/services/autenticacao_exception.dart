class AutenticacaoException implements Exception {
  AutenticacaoException(this.mensagem, {this.statusCode = 422});

  final String mensagem;
  final int statusCode;

  @override
  String toString() {
    return mensagem;
  }
}