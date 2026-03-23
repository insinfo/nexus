import 'package:essential_core/essential_core.dart';

class ArestaFluxoDto implements SerializeBase {
  static const tableName = 'definicao_aresta_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const origemCol = 'origem';
  static const origemFqCol = '$fqtb.$origemCol';
  static const destinoCol = 'destino';
  static const destinoFqCol = '$fqtb.$destinoCol';
  static const handleOrigemCol = 'handle_origem';
  static const handleOrigemFqCol = '$fqtb.$handleOrigemCol';
  static const handleDestinoCol = 'handle_destino';
  static const handleDestinoFqCol = '$fqtb.$handleDestinoCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';

  ArestaFluxoDto({
    required this.id,
    required this.origem,
    required this.destino,
    this.handleOrigem,
    this.handleDestino,
    this.rotulo,
  });
  String id;
  String origem;
  String destino;
  String? handleOrigem;
  String? handleDestino;
  String? rotulo;
  ArestaFluxoDto clone() {
    return ArestaFluxoDto(
      id: id,
      origem: origem,
      destino: destino,
      handleOrigem: handleOrigem,
      handleDestino: handleDestino,
      rotulo: rotulo,
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

  factory ArestaFluxoDto.fromMap(Map<String, dynamic> mapa) {
    return ArestaFluxoDto(
      id: mapa['id'] as String,
      origem: mapa['origem'] as String,
      destino: mapa['destino'] as String,
      handleOrigem: mapa['handle_origem'] as String?,
      handleDestino: mapa['handle_destino'] as String?,
      rotulo: mapa['rotulo'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'origem': origem,
      'destino': destino,
      'handle_origem': handleOrigem,
      'handle_destino': handleDestino,
      'rotulo': rotulo,
    };
  }
}
