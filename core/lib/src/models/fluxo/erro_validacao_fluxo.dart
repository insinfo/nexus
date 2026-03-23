import 'package:essential_core/essential_core.dart';

class ErroValidacaoFluxo implements SerializeBase {
  static const tableName = 'erro_validacao_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const mensagemCol = 'mensagem';
  static const mensagemFqCol = '$fqtb.$mensagemCol';
  static const idNoCol = 'id_no';
  static const idNoFqCol = '$fqtb.$idNoCol';
  static const idArestaCol = 'id_aresta';
  static const idArestaFqCol = '$fqtb.$idArestaCol';

  ErroValidacaoFluxo({
    required this.codigo,
    required this.mensagem,
    this.idNo,
    this.idAresta,
  });
  String codigo;
  String mensagem;
  String? idNo;
  String? idAresta;
  ErroValidacaoFluxo clone() {
    return ErroValidacaoFluxo(
      codigo: codigo,
      mensagem: mensagem,
      idNo: idNo,
      idAresta: idAresta,
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

  factory ErroValidacaoFluxo.fromMap(Map<String, dynamic> mapa) {
    return ErroValidacaoFluxo(
      codigo: mapa['codigo'] as String,
      mensagem: mapa['mensagem'] as String,
      idNo: mapa['id_no'] as String?,
      idAresta: mapa['id_aresta'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'codigo': codigo,
      'mensagem': mensagem,
      'id_no': idNo,
      'id_aresta': idAresta,
    };
  }
}
