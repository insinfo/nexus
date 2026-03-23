import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class MovimentacaoCadastroPessoa implements SerializeBase {
  static const tableName = 'movimentacao_cadastro_pessoa';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const numeroCadastroCol = 'numero_cadastro';
  static const numeroCadastroFqCol = '$fqtb.$numeroCadastroCol';
  static const idHistoricoOrigemCol = 'id_historico_origem';
  static const idHistoricoOrigemFqCol = '$fqtb.$idHistoricoOrigemCol';
  static const idHistoricoDestinoCol = 'id_historico_destino';
  static const idHistoricoDestinoFqCol = '$fqtb.$idHistoricoDestinoCol';
  static const tipoMovimentacaoCol = 'tipo_movimentacao';
  static const tipoMovimentacaoFqCol = '$fqtb.$tipoMovimentacaoCol';
  static const geraHistoricoCol = 'gera_historico';
  static const geraHistoricoFqCol = '$fqtb.$geraHistoricoCol';
  static const justificativaCol = 'justificativa';
  static const justificativaFqCol = '$fqtb.$justificativaCol';
  static const alteradoPorCol = 'alterado_por';
  static const alteradoPorFqCol = '$fqtb.$alteradoPorCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  MovimentacaoCadastroPessoa({
    this.id,
    this.numeroCadastro,
    this.idHistoricoOrigem,
    this.idHistoricoDestino,
    this.tipoMovimentacao,
    this.geraHistorico = false,
    this.justificativa,
    this.alteradoPor,
    this.criadoEm,
  });
  int? id;
  int? numeroCadastro;
  int? idHistoricoOrigem;
  int? idHistoricoDestino;
  String? tipoMovimentacao;
  bool geraHistorico;
  String? justificativa;
  int? alteradoPor;
  DateTime? criadoEm;
  MovimentacaoCadastroPessoa clone() {
    return MovimentacaoCadastroPessoa(
      id: id,
      numeroCadastro: numeroCadastro,
      idHistoricoOrigem: idHistoricoOrigem,
      idHistoricoDestino: idHistoricoDestino,
      tipoMovimentacao: tipoMovimentacao,
      geraHistorico: geraHistorico,
      justificativa: justificativa,
      alteradoPor: alteradoPor,
      criadoEm: criadoEm,
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

  factory MovimentacaoCadastroPessoa.fromMap(Map<String, dynamic> mapa) {
    return MovimentacaoCadastroPessoa(
      id: mapa['id'] as int?,
      numeroCadastro: mapa['numero_cadastro'] as int?,
      idHistoricoOrigem: mapa['id_historico_origem'] as int?,
      idHistoricoDestino: mapa['id_historico_destino'] as int?,
      tipoMovimentacao: mapa['tipo_movimentacao'] as String?,
      geraHistorico: (mapa['gera_historico'] as bool?) ?? false,
      justificativa: mapa['justificativa'] as String?,
      alteradoPor: mapa['alterado_por'] as int?,
      criadoEm: lerDataHora(mapa['criado_em']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'numero_cadastro': numeroCadastro,
        'id_historico_origem': idHistoricoOrigem,
        'id_historico_destino': idHistoricoDestino,
        'tipo_movimentacao': tipoMovimentacao,
        'gera_historico': geraHistorico,
        'justificativa': justificativa,
        'alterado_por': alteradoPor,
        'criado_em': criadoEm?.toIso8601String(),
      };
}
