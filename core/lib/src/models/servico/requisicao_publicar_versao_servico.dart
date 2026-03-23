import 'package:essential_core/essential_core.dart';

class RequisicaoPublicarVersaoServico implements SerializeBase {
  static const tableName = 'requisicao_publicar_versao_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoCol = 'id_versao';
  static const idVersaoFqCol = '$fqtb.$idVersaoCol';

  RequisicaoPublicarVersaoServico({
    required this.idServico,
    required this.idVersao,
  });
  String idServico;
  String idVersao;
  RequisicaoPublicarVersaoServico clone() {
    return RequisicaoPublicarVersaoServico(
      idServico: idServico,
      idVersao: idVersao,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  factory RequisicaoPublicarVersaoServico.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoPublicarVersaoServico(
      idServico: mapa['id_servico'] as String,
      idVersao: mapa['id_versao'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_servico': idServico,
      'id_versao': idVersao,
    };
  }
}
