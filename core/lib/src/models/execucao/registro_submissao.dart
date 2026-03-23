import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class RegistroSubmissao implements SerializeBase {
  static const tableName = 'registro_submissao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const numeroProtocoloCol = 'numero_protocolo';
  static const numeroProtocoloFqCol = '$fqtb.$numeroProtocoloCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const snapshotCol = 'snapshot';
  static const snapshotFqCol = '$fqtb.$snapshotCol';

  RegistroSubmissao({
    required this.id,
    required this.idServico,
    required this.idVersaoServico,
    required this.numeroProtocolo,
    required this.criadoEm,
    this.snapshot = const <String, dynamic>{},
  });
  String id;
  String idServico;
  String idVersaoServico;
  String numeroProtocolo;
  DateTime criadoEm;
  Map<String, dynamic> snapshot;
  RegistroSubmissao clone() {
    return RegistroSubmissao(
      id: id,
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      numeroProtocolo: numeroProtocolo,
      criadoEm: criadoEm,
      snapshot: snapshot,
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

  factory RegistroSubmissao.fromMap(Map<String, dynamic> mapa) {
    return RegistroSubmissao(
      id: mapa['id'] as String,
      idServico: mapa['id_servico'] as String,
      idVersaoServico: mapa['id_versao_servico'] as String,
      numeroProtocolo: mapa['numero_protocolo'] as String,
      criadoEm: lerDataHora(mapa['criado_em'])!,
      snapshot: lerMapa(mapa['snapshot']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'id_servico': idServico,
      'id_versao_servico': idVersaoServico,
      'numero_protocolo': numeroProtocolo,
      'criado_em': criadoEm.toIso8601String(),
      'snapshot': snapshot,
    };
  }
}
