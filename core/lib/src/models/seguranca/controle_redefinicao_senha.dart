import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ControleRedefinicaoSenha implements SerializeBase {
  static const tableName = 'controle_redefinicao_senha';
  static const fqtb = 'public.$tableName';
  static const identificadorUsuarioCol = 'identificador_usuario';
  static const identificadorUsuarioFqCol = '$fqtb.$identificadorUsuarioCol';
  static const ultimaSolicitacaoEmCol = 'ultima_solicitacao_em';
  static const ultimaSolicitacaoEmFqCol = '$fqtb.$ultimaSolicitacaoEmCol';
  static const ultimoIpCol = 'ultimo_ip';
  static const ultimoIpFqCol = '$fqtb.$ultimoIpCol';

  ControleRedefinicaoSenha({
    this.identificadorUsuario = '',
    this.ultimaSolicitacaoEm,
    this.ultimoIp,
  });
  String identificadorUsuario;
  DateTime? ultimaSolicitacaoEm;
  String? ultimoIp;
  ControleRedefinicaoSenha clone() {
    return ControleRedefinicaoSenha(
      identificadorUsuario: identificadorUsuario,
      ultimaSolicitacaoEm: ultimaSolicitacaoEm,
      ultimoIp: ultimoIp,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }

  factory ControleRedefinicaoSenha.fromMap(Map<String, dynamic> mapa) {
    return ControleRedefinicaoSenha(
      identificadorUsuario:
          (mapa[identificadorUsuarioCol] as String?) ?? '',
      ultimaSolicitacaoEm: lerDataHora(mapa[ultimaSolicitacaoEmCol]),
      ultimoIp: mapa[ultimoIpCol] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      identificadorUsuarioCol: identificadorUsuario,
      ultimaSolicitacaoEmCol: ultimaSolicitacaoEm?.toIso8601String(),
      ultimoIpCol: ultimoIp,
      };
}
