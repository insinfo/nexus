import 'package:essential_core/essential_core.dart';

class CardMetrica implements SerializeBase {
  static const tableName = 'card_metrica';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const valorCol = 'valor';
  static const valorFqCol = '$fqtb.$valorCol';
  static const rotuloDeltaCol = 'rotulo_delta';
  static const rotuloDeltaFqCol = '$fqtb.$rotuloDeltaCol';
  static const iconeCol = 'icone';
  static const iconeFqCol = '$fqtb.$iconeCol';

  CardMetrica({
    required this.id,
    required this.rotulo,
    required this.valor,
    required this.rotuloDelta,
    required this.icone,
  });
  String id;
  String rotulo;
  String valor;
  String rotuloDelta;
  String icone;
  CardMetrica clone() {
    return CardMetrica(
      id: id,
      rotulo: rotulo,
      valor: valor,
      rotuloDelta: rotuloDelta,
      icone: icone,
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

  factory CardMetrica.fromMap(Map<String, dynamic> mapa) {
    return CardMetrica(
      id: mapa['id'] as String,
      rotulo: mapa['rotulo'] as String,
      valor: mapa['valor'] as String,
      rotuloDelta: mapa['rotulo_delta'] as String,
      icone: mapa['icone'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'rotulo': rotulo,
      'valor': valor,
      'rotulo_delta': rotuloDelta,
      'icone': icone,
    };
  }
}
