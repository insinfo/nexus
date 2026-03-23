import 'package:essential_core/essential_core.dart';

class Organograma implements SerializeBase {
  static const tableName = 'organograma';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';

  Organograma({this.id, this.ativo = true});
  int? id;
  bool ativo;
  Organograma clone() {
    return Organograma(
      id: id,
      ativo: ativo,
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

  factory Organograma.fromMap(Map<String, dynamic> mapa) {
    return Organograma(
      id: mapa['id'] as int?,
      ativo: (mapa['ativo'] as bool?) ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{'id': id, 'ativo': ativo};
}
