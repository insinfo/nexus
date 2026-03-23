import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'versao_servico_dto.dart';
import 'metadados_servico_dto.dart';

class ServicoDto implements SerializeBase {
  static const tableName = 'definicao_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const metadadosCol = 'metadados';
  static const metadadosFqCol = '$fqtb.$metadadosCol';
  static const versoesCol = 'versoes';
  static const versoesFqCol = '$fqtb.$versoesCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  ServicoDto({
    required this.id,
    required this.codigo,
    required this.metadados,
    required this.versoes,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  String id;
  String codigo;
  MetadadosServicoDto metadados;
  List<VersaoServicoDto> versoes;
  DateTime criadoEm;
  DateTime atualizadoEm;

  VersaoServicoDto? get versaoPublicada {
    for (final VersaoServicoDto versao in versoes) {
      if (versao.status == StatusVersaoServico.publicada) {
        return versao;
      }
    }
    return null;
  }

  ServicoDto clone() {
    return ServicoDto(
      id: id,
      codigo: codigo,
      metadados: metadados,
      versoes: versoes,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
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

  factory ServicoDto.fromMap(Map<String, dynamic> mapa) {
    return ServicoDto(
      id: mapa['id'] as String,
      codigo: mapa['codigo'] as String,
      metadados: MetadadosServicoDto.fromMap(lerMapa(mapa['metadados'])),
      versoes: mapearLista(mapa['versoes'], VersaoServicoDto.fromMap),
      criadoEm: lerDataHora(mapa['criado_em'])!,
      atualizadoEm: lerDataHora(mapa['atualizado_em'])!,
    );
  }

  Map<String, dynamic> paraResumoMap() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'nome': metadados.nome,
      'descricao': metadados.descricao,
      'categoria': metadados.categoria,
      'modo_acesso': metadados.modoAcesso.val,
      'canais': metadados.canais
          .map((CanalServico item) => item.val)
          .toList(growable: false),
      'versao_publicada': versaoPublicada?.versao,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'metadados': metadados.toMap(),
      'versoes': serializarLista(versoes),
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }
}
