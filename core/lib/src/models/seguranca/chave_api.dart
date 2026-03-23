import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ChaveApi implements SerializeBase {
  static const tableName = 'chave_api';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoCol = 'id_publico';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const hashChaveCol = 'hash_chave';
  static const hashChaveFqCol = '$fqtb.$hashChaveCol';
  static const idUsuarioResponsavelCol = 'id_usuario_responsavel';
  static const idUsuarioResponsavelFqCol = '$fqtb.$idUsuarioResponsavelCol';
  static const idOrganogramaResponsavelCol = 'id_organograma_responsavel';
  static const idOrganogramaResponsavelFqCol =
      '$fqtb.$idOrganogramaResponsavelCol';
  static const escoposCol = 'escopos';
  static const escoposFqCol = '$fqtb.$escoposCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const ultimoUsoEmCol = 'ultimo_uso_em';
  static const ultimoUsoEmFqCol = '$fqtb.$ultimoUsoEmCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  ChaveApi({
    this.id,
    this.idPublico,
    this.nome,
    this.hashChave,
    this.idUsuarioResponsavel,
    this.idOrganogramaResponsavel,
    this.escopos = const <String>[],
    this.ativo = true,
    this.ultimoUsoEm,
    this.expiraEm,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  String? idPublico;
  String? nome;
  String? hashChave;
  int? idUsuarioResponsavel;
  int? idOrganogramaResponsavel;
  List<String> escopos;
  bool ativo;
  DateTime? ultimoUsoEm;
  DateTime? expiraEm;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  ChaveApi clone() {
    return ChaveApi(
      id: id,
      idPublico: idPublico,
      nome: nome,
      hashChave: hashChave,
      idUsuarioResponsavel: idUsuarioResponsavel,
      idOrganogramaResponsavel: idOrganogramaResponsavel,
      escopos: escopos,
      ativo: ativo,
      ultimoUsoEm: ultimoUsoEm,
      expiraEm: expiraEm,
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

  factory ChaveApi.fromMap(Map<String, dynamic> mapa) {
    return ChaveApi(
      id: mapa['id'] as int?,
      idPublico: mapa['idPublico'] as String?,
      nome: mapa['nome'] as String?,
      hashChave: mapa['hashChave'] as String?,
      idUsuarioResponsavel: mapa['idUsuarioResponsavel'] as int?,
      idOrganogramaResponsavel: mapa['idOrganogramaResponsavel'] as int?,
      escopos: lerListaTexto(mapa['escopos']),
      ativo: (mapa['ativo'] as bool?) ?? true,
      ultimoUsoEm: lerDataHora(mapa['ultimoUsoEm']),
      expiraEm: lerDataHora(mapa['expiraEm']),
      criadoEm: lerDataHora(mapa['criadoEm']),
      atualizadoEm: lerDataHora(mapa['atualizadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'idPublico': idPublico,
        'nome': nome,
        'hashChave': hashChave,
        'idUsuarioResponsavel': idUsuarioResponsavel,
        'idOrganogramaResponsavel': idOrganogramaResponsavel,
        'escopos': escopos,
        'ativo': ativo,
        'ultimoUsoEm': ultimoUsoEm?.toIso8601String(),
        'expiraEm': expiraEm?.toIso8601String(),
        'criadoEm': criadoEm?.toIso8601String(),
        'atualizadoEm': atualizadoEm?.toIso8601String(),
      };
}
