import 'package:essential_core/essential_core.dart';

class AtalhoPortal implements SerializeBase {
  static const tableName = 'atalho_portal';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const iconeCol = 'icone';
  static const iconeFqCol = '$fqtb.$iconeCol';
  static const rotaCol = 'rota';
  static const rotaFqCol = '$fqtb.$rotaCol';

  AtalhoPortal({
    required this.id,
    required this.rotulo,
    required this.descricao,
    required this.icone,
    required this.rota,
  });
  String id;
  String rotulo;
  String descricao;
  String icone;
  String rota;
  AtalhoPortal clone() {
    return AtalhoPortal(
      id: id,
      rotulo: rotulo,
      descricao: descricao,
      icone: icone,
      rota: rota,
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

  factory AtalhoPortal.fromMap(Map<String, dynamic> mapa) {
    return AtalhoPortal(
      id: mapa['id']?.toString() ?? '',
      rotulo: mapa['rotulo'] as String,
      descricao: mapa['descricao'] as String,
      icone: mapa['icone'] as String,
      rota: mapa['rota'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'rotulo': rotulo,
      'descricao': descricao,
      'icone': icone,
      'rota': rota,
    };
  }
}
