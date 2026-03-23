import 'package:essential_core/essential_core.dart';

class RequisicaoExecutarClassificacao implements SerializeBase {
  static const tableName = 'requisicao_executar_classificacao';
  static const fqtb = 'public.$tableName';
  static const idServicoCol = 'id_servico';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const notasCol = 'notas';

  RequisicaoExecutarClassificacao({
    required this.idServico,
    this.idVersaoServico,
    this.idVersaoConjuntoRegras,
    this.notas,
  });

  String idServico;
  String? idVersaoServico;
  String? idVersaoConjuntoRegras;
  String? notas;

  RequisicaoExecutarClassificacao clone() {
    return RequisicaoExecutarClassificacao(
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      notas: notas,
    );
  }

  Map<String, dynamic> toInsertMap() => toMap();

  Map<String, dynamic> toUpdateMap() => toMap();

  factory RequisicaoExecutarClassificacao.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoExecutarClassificacao(
      idServico: mapa[idServicoCol] as String? ?? '',
      idVersaoServico: mapa[idVersaoServicoCol] as String?,
      idVersaoConjuntoRegras: mapa[idVersaoConjuntoRegrasCol] as String?,
      notas: mapa[notasCol] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idServicoCol: idServico,
      idVersaoServicoCol: idVersaoServico,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      notasCol: notas,
    };
  }
}
