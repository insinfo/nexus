import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';
import 'bloco_conteudo_rico.dart';

class DocumentoConteudoRico implements SerializeBase {
  static const tableName = 'documento_conteudo_rico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const blocosCol = 'blocos';
  static const blocosFqCol = '$fqtb.$blocosCol';
  static const versaoCol = 'versao';
  static const versaoFqCol = '$fqtb.$versaoCol';
  static const criadoEmEpochMsCol = 'criado_em_epoch_ms';
  static const criadoEmEpochMsFqCol = '$fqtb.$criadoEmEpochMsCol';

  DocumentoConteudoRico({
    this.blocos = const <BlocoConteudoRico>[],
    this.versao = '1.0.0',
    this.criadoEmEpochMs,
  });
  List<BlocoConteudoRico> blocos;
  String versao;
  int? criadoEmEpochMs;

  bool get vazio => blocos.isEmpty;
  DocumentoConteudoRico clone() {
    return DocumentoConteudoRico(
      blocos: blocos,
      versao: versao,
      criadoEmEpochMs: criadoEmEpochMs,
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

  factory DocumentoConteudoRico.fromMap(Map<String, dynamic> mapa) {
    return DocumentoConteudoRico(
      versao: (mapa['versao'] as String?) ?? '1.0.0',
      criadoEmEpochMs: mapa['tempo'] as int?,
      blocos: mapearLista(
        mapa['blocos'],
        BlocoConteudoRico.fromMap,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'versao': versao,
      'tempo': criadoEmEpochMs,
      'blocos': serializarLista(blocos),
    };
  }
}
