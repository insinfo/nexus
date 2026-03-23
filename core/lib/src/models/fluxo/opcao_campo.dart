import 'package:essential_core/essential_core.dart';

class OpcaoCampo implements SerializeBase {
  static const tableName = 'opcoes_campo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idCampoCol = 'id_campo';
  static const valorOpcaoCol = 'valor_opcao';
  static const rotuloOpcaoCol = 'rotulo_opcao';
  static const ordemCol = 'ordem';
  static const idFqCol = '$fqtb.$idCol';
  static const idCampoFqCol = '$fqtb.$idCampoCol';
  static const valorOpcaoFqCol = '$fqtb.$valorOpcaoCol';
  static const rotuloOpcaoFqCol = '$fqtb.$rotuloOpcaoCol';
  static const ordemFqCol = '$fqtb.$ordemCol';
  int id;
  int idCampo;
  String valorOpcao;
  String rotuloOpcao;
  int ordem;

  OpcaoCampo({
    this.id = 0,
    this.idCampo = 0,
    String? valorOpcao,
    String? valor,
    String? rotuloOpcao,
    String? rotulo,
    this.ordem = 0,
  })  : valorOpcao = valorOpcao ?? valor ?? '',
        rotuloOpcao = rotuloOpcao ?? rotulo ?? valorOpcao ?? valor ?? '';

  String get valor => valorOpcao;
  set valor(String valor) => valorOpcao = valor;

  String get rotulo => rotuloOpcao;
  set rotulo(String rotulo) => rotuloOpcao = rotulo;

  factory OpcaoCampo.fromMap(Map<String, dynamic> map) {
    return OpcaoCampo(
      id: map[idCol] as int? ?? 0,
      idCampo: map[idCampoCol] as int? ?? 0,
      valorOpcao: (map[valorOpcaoCol] ?? map['valor']) as String? ?? '',
      rotuloOpcao: (map[rotuloOpcaoCol] ??
              map['rotulo'] ??
              map[valorOpcaoCol] ??
              map['valor']) as String? ??
          '',
      ordem: map[ordemCol] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'valor': valorOpcao,
      'rotulo': rotuloOpcao,
      'ordem': ordem,
    };
  }

  Map<String, dynamic> _toPersistenciaMap() {
    return <String, dynamic>{
      idCol: id,
      idCampoCol: idCampo,
      valorOpcaoCol: valorOpcao,
      rotuloOpcaoCol: rotuloOpcao,
      ordemCol: ordem,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = _toPersistenciaMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = _toPersistenciaMap()
      ..remove(idCol)
      ..remove(idCampoCol);
    return map;
  }

  OpcaoCampo clone() {
    return OpcaoCampo(
      id: id,
      idCampo: idCampo,
      valorOpcao: valorOpcao,
      rotuloOpcao: rotuloOpcao,
      ordem: ordem,
    );
  }
}
