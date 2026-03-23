import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../fluxo/fluxo_dto.dart';
import '../suporte/modelo_utils.dart';

class VersaoServicoDto implements SerializeBase {
  static const tableName = 'definicao_versao_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const versaoCol = 'versao';
  static const versaoFqCol = '$fqtb.$versaoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const fluxosCol = 'fluxos';
  static const fluxosFqCol = '$fqtb.$fluxosCol';
  static const notasCol = 'notas';
  static const notasFqCol = '$fqtb.$notasCol';

  VersaoServicoDto({
    required this.id,
    required this.versao,
    required this.status,
    required this.criadoEm,
    this.fluxos = const <FluxoDto>[],
    this.notas,
  });
  String id;
  int versao;
  StatusVersaoServico status;
  DateTime criadoEm;
  List<FluxoDto> fluxos;
  String? notas;
  VersaoServicoDto clone() {
    return VersaoServicoDto(
      id: id,
      versao: versao,
      status: status,
      criadoEm: criadoEm,
      fluxos: fluxos,
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

  factory VersaoServicoDto.fromMap(Map<String, dynamic> mapa) {
    return VersaoServicoDto(
      id: mapa['id'] as String,
      versao: mapa['versao'] as int,
      status: StatusVersaoServico.parse(mapa['status'] as String),
      criadoEm: lerDataHora(mapa['criado_em'])!,
      fluxos: mapearLista(mapa['fluxos'], FluxoDto.fromMap),
      notas: mapa['notas'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'versao': versao,
      'status': status.val,
      'criado_em': criadoEm.toIso8601String(),
      'fluxos': serializarLista(fluxos),
      'notas': notas,
    };
  }
}
