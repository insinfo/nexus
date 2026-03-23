import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';
import 'servico_dto.dart';

class RequisicaoSalvarRascunhoServico implements SerializeBase {
  static const tableName = 'requisicao_salvar_rascunho_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const servicoCol = 'servico';
  static const servicoFqCol = '$fqtb.$servicoCol';
  static const idVersaoCol = 'id_versao';
  static const idVersaoFqCol = '$fqtb.$idVersaoCol';

  RequisicaoSalvarRascunhoServico({
    required this.servico,
    this.idVersao,
  });
  ServicoDto servico;
  String? idVersao;
  RequisicaoSalvarRascunhoServico clone() {
    return RequisicaoSalvarRascunhoServico(
      servico: servico,
      idVersao: idVersao,
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

  factory RequisicaoSalvarRascunhoServico.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoSalvarRascunhoServico(
      servico: ServicoDto.fromMap(lerMapa(mapa['servico'])),
      idVersao: mapa['id_versao'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'servico': servico.toMap(),
      'id_versao': idVersao,
    };
  }
}
