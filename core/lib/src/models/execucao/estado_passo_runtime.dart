import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../fluxo/no_fluxo_dto.dart';
import '../suporte/modelo_utils.dart';
import 'contexto_execucao_dto.dart';
import 'registro_submissao.dart';

/// Payload retornado pelo runtime ao avançar para um nó.
/// Representa o estado atual da sessão + o conteúdo do nó ativo.
class EstadoPassoRuntime implements SerializeBase {
  static const tableName = 'estado_passo_runtime';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idSessaoCol = 'id_sessao';
  static const idSessaoFqCol = '$fqtb.$idSessaoCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const idVersaoServicoCol = 'id_versao_servico';
  static const idVersaoServicoFqCol = '$fqtb.$idVersaoServicoCol';
  static const chaveFluxoAtualCol = 'chave_fluxo_atual';
  static const chaveFluxoAtualFqCol = '$fqtb.$chaveFluxoAtualCol';
  static const noAtualCol = 'no_atual';
  static const noAtualFqCol = '$fqtb.$noAtualCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const contextoCol = 'contexto';
  static const contextoFqCol = '$fqtb.$contextoCol';
  static const registroSubmissaoCol = 'registro_submissao';
  static const registroSubmissaoFqCol = '$fqtb.$registroSubmissaoCol';
  static const erroValidacaoCol = 'erro_validacao';
  static const erroValidacaoFqCol = '$fqtb.$erroValidacaoCol';

  EstadoPassoRuntime({
    required this.idSessao,
    required this.idServico,
    required this.idVersaoServico,
    required this.chaveFluxoAtual,
    required this.noAtual,
    required this.status,
    required this.contexto,
    this.registroSubmissao,
    this.erroValidacao,
  });

  /// ID público da sessão de execução.
  String idSessao;
  String idServico;
  String idVersaoServico;
  String chaveFluxoAtual;

  /// Nó atual que deve ser renderizado pelo frontend.
  NoFluxoDto noAtual;
  StatusExecucao status;
  ContextoExecucaoDto contexto;
  RegistroSubmissao? registroSubmissao;

  /// Mensagem de validação, caso o avanço tenha sido recusado.
  String? erroValidacao;
  EstadoPassoRuntime clone() {
    return EstadoPassoRuntime(
      idSessao: idSessao,
      idServico: idServico,
      idVersaoServico: idVersaoServico,
      chaveFluxoAtual: chaveFluxoAtual,
      noAtual: noAtual,
      status: status,
      contexto: contexto,
      registroSubmissao: registroSubmissao,
      erroValidacao: erroValidacao,
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

  factory EstadoPassoRuntime.fromMap(Map<String, dynamic> mapa) {
    return EstadoPassoRuntime(
      idSessao: mapa['id_sessao'] as String,
      idServico: mapa['id_servico'] as String,
      idVersaoServico: mapa['id_versao_servico'] as String,
      chaveFluxoAtual: mapa['chave_fluxo_atual'] as String,
      noAtual: NoFluxoDto.fromMap(lerMapa(mapa['no_atual'])),
      status: StatusExecucao.parse(mapa['status'] as String),
      contexto: ContextoExecucaoDto.fromMap(lerMapa(mapa['contexto'])),
      registroSubmissao: mapa['registro_submissao'] == null
          ? null
          : RegistroSubmissao.fromMap(lerMapa(mapa['registro_submissao'])),
      erroValidacao: mapa['erro_validacao'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_sessao': idSessao,
      'id_servico': idServico,
      'id_versao_servico': idVersaoServico,
      'chave_fluxo_atual': chaveFluxoAtual,
      'no_atual': noAtual.toMap(),
      'status': status.val,
      'contexto': contexto.toMap(),
      'registro_submissao': registroSubmissao?.toMap(),
      'erro_validacao': erroValidacao,
    };
  }
}
