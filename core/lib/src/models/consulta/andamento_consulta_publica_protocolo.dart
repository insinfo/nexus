import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class AndamentoConsultaPublicaProtocolo implements SerializeBase {
  static const tableName = 'andamento_consulta_publica_protocolo';
  static const fqtb = 'public.$tableName';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const situacaoCol = 'situacao';
  static const situacaoFqCol = '$fqtb.$situacaoCol';
  static const dataCol = 'data';
  static const dataFqCol = '$fqtb.$dataCol';

  AndamentoConsultaPublicaProtocolo({
    required this.titulo,
    required this.descricao,
    required this.situacao,
    this.data,
  });

  String titulo;
  String descricao;
  String situacao;
  DateTime? data;

  AndamentoConsultaPublicaProtocolo clone() {
    return AndamentoConsultaPublicaProtocolo(
      titulo: titulo,
      descricao: descricao,
      situacao: situacao,
      data: data,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }

  factory AndamentoConsultaPublicaProtocolo.fromMap(Map<String, dynamic> mapa) {
    return AndamentoConsultaPublicaProtocolo(
      titulo: mapa[tituloCol] as String? ?? '',
      descricao: mapa[descricaoCol] as String? ?? '',
      situacao: mapa[situacaoCol] as String? ?? 'pendente',
      data: lerDataHora(mapa[dataCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      tituloCol: titulo,
      descricaoCol: descricao,
      situacaoCol: situacao,
      dataCol: data?.toIso8601String(),
    };
  }
}
