import 'package:essential_core/essential_core.dart';

class SecaoFormularioDto implements SerializeBase {
  static const tableName = 'secao_formulario';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const chaveCol = 'chave';
  static const chaveFqCol = '$fqtb.$chaveCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const ordemCol = 'ordem';
  static const ordemFqCol = '$fqtb.$ordemCol';
  static const repetivelCol = 'repetivel';
  static const repetivelFqCol = '$fqtb.$repetivelCol';

  SecaoFormularioDto({
    required this.id,
    required this.chave,
    required this.titulo,
    this.descricao,
    this.ordem = 0,
    this.repetivel = false,
  });
  String id;
  String chave;
  String titulo;
  String? descricao;
  int ordem;
  bool repetivel;
  SecaoFormularioDto clone() {
    return SecaoFormularioDto(
      id: id,
      chave: chave,
      titulo: titulo,
      descricao: descricao,
      ordem: ordem,
      repetivel: repetivel,
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

  factory SecaoFormularioDto.fromMap(Map<String, dynamic> mapa) {
    return SecaoFormularioDto(
      id: mapa['id'] as String,
      chave: mapa['chave'] as String,
      titulo: mapa['titulo'] as String,
      descricao: mapa['descricao'] as String?,
      ordem: mapa['ordem'] as int? ?? 0,
      repetivel: mapa['repetivel'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chave': chave,
      'titulo': titulo,
      'descricao': descricao,
      'ordem': ordem,
      'repetivel': repetivel,
    };
  }
}
