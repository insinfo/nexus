import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../servico/versao_servico_dto.dart';
import '../suporte/modelo_utils.dart';

class ResumoVersaoServico implements SerializeBase {
  static const tableName = 'resumo_versao_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const versaoCol = 'versao';
  static const versaoFqCol = '$fqtb.$versaoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const quantidadeFluxosCol = 'quantidade_fluxos';
  static const quantidadeFluxosFqCol = '$fqtb.$quantidadeFluxosCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const notasCol = 'notas';
  static const notasFqCol = '$fqtb.$notasCol';

  ResumoVersaoServico({
    required this.id,
    required this.versao,
    required this.status,
    required this.quantidadeFluxos,
    required this.criadoEm,
    this.notas,
  });
  String id;
  int versao;
  StatusVersaoServico status;
  int quantidadeFluxos;
  DateTime criadoEm;
  String? notas;

  factory ResumoVersaoServico.fromDefinicao(VersaoServicoDto versao) {
    return ResumoVersaoServico(
      id: versao.id,
      versao: versao.versao,
      status: versao.status,
      quantidadeFluxos: versao.fluxos.length,
      criadoEm: versao.criadoEm,
      notas: versao.notas,
    );
  }
  ResumoVersaoServico clone() {
    return ResumoVersaoServico(
      id: id,
      versao: versao,
      status: status,
      quantidadeFluxos: quantidadeFluxos,
      criadoEm: criadoEm,
      notas: notas,
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

  factory ResumoVersaoServico.fromMap(Map<String, dynamic> mapa) {
    return ResumoVersaoServico(
      id: mapa['id'] as String,
      versao: mapa['versao'] as int,
      status: StatusVersaoServico.parse(mapa['status'] as String),
      quantidadeFluxos: mapa['quantidade_fluxos'] as int,
      criadoEm: lerDataHora(mapa['criado_em'])!,
      notas: mapa['notas'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'versao': versao,
      'status': status.val,
      'quantidade_fluxos': quantidadeFluxos,
      'criado_em': criadoEm.toIso8601String(),
      'notas': notas,
    };
  }
}
