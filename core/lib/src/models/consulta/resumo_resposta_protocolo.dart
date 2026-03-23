import 'package:essential_core/essential_core.dart';

class ResumoRespostaProtocolo implements SerializeBase {
  static const tableName = 'resumo_resposta_protocolo';
  static const fqtb = 'public.$tableName';
  static const chaveCol = 'chave';
  static const chaveFqCol = '$fqtb.$chaveCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const valorCol = 'valor';
  static const valorFqCol = '$fqtb.$valorCol';

  ResumoRespostaProtocolo({
    required this.chave,
    required this.rotulo,
    required this.valor,
  });

  String chave;
  String rotulo;
  String valor;

  ResumoRespostaProtocolo clone() {
    return ResumoRespostaProtocolo(
      chave: chave,
      rotulo: rotulo,
      valor: valor,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }

  factory ResumoRespostaProtocolo.fromMap(Map<String, dynamic> mapa) {
    return ResumoRespostaProtocolo(
      chave: mapa[chaveCol] as String? ?? '',
      rotulo: mapa[rotuloCol] as String? ?? '',
      valor: mapa[valorCol]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      chaveCol: chave,
      rotuloCol: rotulo,
      valorCol: valor,
    };
  }
}
