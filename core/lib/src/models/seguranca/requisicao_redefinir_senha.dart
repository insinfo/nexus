import 'package:essential_core/essential_core.dart';

class RequisicaoRedefinirSenha implements SerializeBase {
  static const tableName = 'requisicao_redefinir_senha';
  static const fqtb = 'public.$tableName';
  static const tokenCol = 'token';
  static const novaSenhaCol = 'nova_senha';

  RequisicaoRedefinirSenha({
    this.token = '',
    this.novaSenha = '',
  });

  String token;
  String novaSenha;

  RequisicaoRedefinirSenha clone() {
    return RequisicaoRedefinirSenha(
      token: token,
      novaSenha: novaSenha,
    );
  }

  factory RequisicaoRedefinirSenha.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoRedefinirSenha(
      token: mapa[tokenCol]?.toString() ?? '',
      novaSenha: mapa[novaSenhaCol]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      tokenCol: token,
      novaSenhaCol: novaSenha,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }
}