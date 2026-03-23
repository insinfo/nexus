import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class BlocoConteudoRico implements SerializeBase {
  static const tableName = 'bloco_conteudo_rico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const dadosCol = 'dados';
  static const dadosFqCol = '$fqtb.$dadosCol';

  BlocoConteudoRico({
    required this.tipo,
    this.dados = const <String, dynamic>{},
  });
  String tipo;
  Map<String, dynamic> dados;
  BlocoConteudoRico clone() {
    return BlocoConteudoRico(
      tipo: tipo,
      dados: dados,
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

  factory BlocoConteudoRico.fromMap(Map<String, dynamic> mapa) {
    return BlocoConteudoRico(
      tipo: mapa['tipo'] as String,
      dados: lerMapa(mapa['dados']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tipo': tipo,
      'dados': dados,
    };
  }
}
