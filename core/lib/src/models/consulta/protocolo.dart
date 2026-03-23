class Protocolo {
  static const tableName = 'protocolos';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idSubmissaoCol = 'id_submissao';
  static const numeroProtocoloCol = 'numero_protocolo';
  static const codigoPublicoCol = 'codigo_publico';
  static const idFqCol = '$fqtb.$idCol';
  static const idSubmissaoFqCol = '$fqtb.$idSubmissaoCol';
  static const numeroProtocoloFqCol = '$fqtb.$numeroProtocoloCol';
  static const codigoPublicoFqCol = '$fqtb.$codigoPublicoCol';
  int id;
  int idSubmissao;
  String numeroProtocolo;
  String codigoPublico;
  Protocolo({
    required this.id,
    required this.idSubmissao,
    required this.numeroProtocolo,
    required this.codigoPublico,
  });

  factory Protocolo.fromMap(Map<String, dynamic> map) {
    return Protocolo(
      id: map[idCol] as int? ?? 0,
      idSubmissao: map[idSubmissaoCol] as int? ?? 0,
      numeroProtocolo: map[numeroProtocoloCol] as String? ?? '',
      codigoPublico: map[codigoPublicoCol] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      idSubmissaoCol: idSubmissao,
      numeroProtocoloCol: numeroProtocolo,
      codigoPublicoCol: codigoPublico,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()
      ..remove(idCol)
      ..remove(idSubmissaoCol);
    return map;
  }

  Protocolo clone() {
    return Protocolo(
      id: id,
      idSubmissao: idSubmissao,
      numeroProtocolo: numeroProtocolo,
      codigoPublico: codigoPublico,
    );
  }
}
