import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class RegraVisibilidadeFormulario implements SerializeBase {
  static const tableName = 'regra_visibilidade_formulario';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const expressaoCol = 'expressao';
  static const expressaoFqCol = '$fqtb.$expressaoCol';

  RegraVisibilidadeFormulario({
    required this.expressao,
  });
  Map<String, dynamic> expressao;
  RegraVisibilidadeFormulario clone() {
    return RegraVisibilidadeFormulario(
      expressao: expressao,
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

  factory RegraVisibilidadeFormulario.fromMap(Map<String, dynamic> mapa) {
    return RegraVisibilidadeFormulario(
      expressao: lerMapa(mapa['expressao']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expressao': expressao,
    };
  }
}
