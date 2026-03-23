import 'package:essential_core/essential_core.dart';

class ResumoNoCanvasBuilder implements SerializeBase {
  static const tableName = 'resumo_no_canvas_builder';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const quantidadeCol = 'quantidade';
  static const quantidadeFqCol = '$fqtb.$quantidadeCol';

  ResumoNoCanvasBuilder({
    required this.rotulo,
    required this.tipo,
    required this.quantidade,
  });
  String rotulo;
  String tipo;
  int quantidade;
  ResumoNoCanvasBuilder clone() {
    return ResumoNoCanvasBuilder(
      rotulo: rotulo,
      tipo: tipo,
      quantidade: quantidade,
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

  factory ResumoNoCanvasBuilder.fromMap(Map<String, dynamic> mapa) {
    return ResumoNoCanvasBuilder(
      rotulo: mapa['rotulo'] as String,
      tipo: mapa['tipo'] as String,
      quantidade: mapa['quantidade'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotulo': rotulo,
      'tipo': tipo,
      'quantidade': quantidade,
    };
  }
}
