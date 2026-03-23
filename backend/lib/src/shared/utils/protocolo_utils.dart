class ProtocoloUtils {
  static String gerarNumeroProtocolo(int idSubmissao, DateTime referencia) {
    final data =
        '${referencia.year.toString().padLeft(4, '0')}${referencia.month.toString().padLeft(2, '0')}${referencia.day.toString().padLeft(2, '0')}';
    final sequencia = idSubmissao.toString().padLeft(6, '0');
    return 'NEX-$data-$sequencia';
  }

  static String gerarCodigoPublico(String idPublicoSubmissao) {
    final valor = idPublicoSubmissao.replaceAll('-', '').toUpperCase();
    final recorte = valor.length <= 12 ? valor : valor.substring(0, 12);
    return 'PUB-$recorte';
  }
}
