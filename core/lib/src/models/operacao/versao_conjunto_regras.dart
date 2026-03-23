import '../comum/enums_nexus.dart';

class VersaoConjuntoRegras {
  static const tableName = 'versoes_conjunto_regras';
  static const fqtn = 'public.$tableName';

  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idPublicoCol = 'id_publico';
  static const idConjuntoRegrasCol = 'id_conjunto_regras';
  static const numeroVersaoCol = 'numero_versao';
  static const statusCol = 'status';
  static const descricaoCol = 'descricao';
  static const definicaoJsonCol = 'definicao_json';
  static const criadoEmCol = 'criado_em';
  static const publicadoEmCol = 'publicado_em';

  static const idFqCol = '$tableName.$idCol';
  static const idPublicoFqCol = '$tableName.$idPublicoCol';
  static const idConjuntoRegrasFqCol = '$tableName.$idConjuntoRegrasCol';
  static const numeroVersaoFqCol = '$tableName.$numeroVersaoCol';
  static const statusFqCol = '$tableName.$statusCol';
  static const descricaoFqCol = '$tableName.$descricaoCol';
  static const definicaoJsonFqCol = '$tableName.$definicaoJsonCol';
  static const criadoEmFqCol = '$tableName.$criadoEmCol';
  static const publicadoEmFqCol = '$tableName.$publicadoEmCol';

  VersaoConjuntoRegras({
    required this.id,
    this.idPublico,
    required this.idConjuntoRegras,
    required this.numeroVersao,
    required this.status,
    this.descricao,
    this.definicaoJson = '{}',
    this.criadoEm,
    this.publicadoEm,
  });

  int id;
  String? idPublico;
  int idConjuntoRegras;
  int numeroVersao;
  String status;
  String? descricao;
  String definicaoJson;
  DateTime? criadoEm;
  DateTime? publicadoEm;

  VersaoConjuntoRegras clone() {
    return VersaoConjuntoRegras(
      id: id,
      idPublico: idPublico,
      idConjuntoRegras: idConjuntoRegras,
      numeroVersao: numeroVersao,
      status: status,
      descricao: descricao,
      definicaoJson: definicaoJson,
      criadoEm: criadoEm,
      publicadoEm: publicadoEm,
    );
  }

  factory VersaoConjuntoRegras.fromMap(Map<String, dynamic> map) {
    return VersaoConjuntoRegras(
      id: map[idCol] as int? ?? 0,
      idPublico: map[idPublicoCol]?.toString(),
      idConjuntoRegras: map[idConjuntoRegrasCol] as int? ?? 0,
      numeroVersao: map[numeroVersaoCol] as int? ?? 0,
      status:
          map[statusCol] as String? ?? StatusVersaoConjuntoRegras.rascunho.val,
      descricao: map[descricaoCol] as String?,
      definicaoJson: map[definicaoJsonCol]?.toString() ?? '{}',
      criadoEm: map[criadoEmCol] is DateTime
          ? map[criadoEmCol] as DateTime
          : DateTime.tryParse(map[criadoEmCol]?.toString() ?? ''),
      publicadoEm: map[publicadoEmCol] is DateTime
          ? map[publicadoEmCol] as DateTime
          : DateTime.tryParse(map[publicadoEmCol]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idPublicoCol: idPublico,
      idConjuntoRegrasCol: idConjuntoRegras,
      numeroVersaoCol: numeroVersao,
      statusCol: status,
      descricaoCol: descricao,
      definicaoJsonCol: definicaoJson,
      criadoEmCol: criadoEm?.toIso8601String(),
      publicadoEmCol: publicadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idPublicoCol);
    map.remove(criadoEmCol);
    map.remove(publicadoEmCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idPublicoCol);
    map.remove(idConjuntoRegrasCol);
    return map;
  }
}
