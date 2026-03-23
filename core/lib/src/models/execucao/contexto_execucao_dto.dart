import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ContextoExecucaoDto implements SerializeBase {
  static const tableName = 'contexto_execucao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const respostasCol = 'respostas';
  static const respostasFqCol = '$fqtb.$respostasCol';
  static const variaveisCol = 'variaveis';
  static const variaveisFqCol = '$fqtb.$variaveisCol';
  static const resultadosIntegracaoCol = 'resultados_integracao';
  static const resultadosIntegracaoFqCol = '$fqtb.$resultadosIntegracaoCol';
  static const contextoUsuarioCol = 'contexto_usuario';
  static const contextoUsuarioFqCol = '$fqtb.$contextoUsuarioCol';
  static const contextoServicoCol = 'contexto_servico';
  static const contextoServicoFqCol = '$fqtb.$contextoServicoCol';
  static const contextoEdicaoCol = 'contexto_edicao';
  static const contextoEdicaoFqCol = '$fqtb.$contextoEdicaoCol';

  ContextoExecucaoDto({
    this.respostas = const <String, dynamic>{},
    this.variaveis = const <String, dynamic>{},
    this.resultadosIntegracao = const <String, dynamic>{},
    this.contextoUsuario = const <String, dynamic>{},
    this.contextoServico = const <String, dynamic>{},
    this.contextoEdicao = const <String, dynamic>{},
  });
  Map<String, dynamic> respostas;
  Map<String, dynamic> variaveis;
  Map<String, dynamic> resultadosIntegracao;
  Map<String, dynamic> contextoUsuario;
  Map<String, dynamic> contextoServico;
  Map<String, dynamic> contextoEdicao;
  ContextoExecucaoDto clone() {
    return ContextoExecucaoDto(
      respostas: respostas,
      variaveis: variaveis,
      resultadosIntegracao: resultadosIntegracao,
      contextoUsuario: contextoUsuario,
      contextoServico: contextoServico,
      contextoEdicao: contextoEdicao,
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

  factory ContextoExecucaoDto.fromMap(Map<String, dynamic> mapa) {
    return ContextoExecucaoDto(
      respostas: lerMapa(mapa['respostas']),
      variaveis: lerMapa(mapa['variaveis']),
      resultadosIntegracao: lerMapa(mapa['resultados_integracao']),
      contextoUsuario: lerMapa(mapa['contexto_usuario']),
      contextoServico: lerMapa(mapa['contexto_servico']),
      contextoEdicao: lerMapa(mapa['contexto_edicao']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'respostas': respostas,
      'variaveis': variaveis,
      'resultados_integracao': resultadosIntegracao,
      'contexto_usuario': contextoUsuario,
      'contexto_servico': contextoServico,
      'contexto_edicao': contextoEdicao,
    };
  }
}
