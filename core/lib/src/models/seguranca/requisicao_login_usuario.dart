import 'package:essential_core/essential_core.dart';

class RequisicaoLoginUsuario implements SerializeBase {
  static const tableName = 'requisicao_login_usuario';
  static const fqtb = 'public.$tableName';
  static const identificadorCol = 'identificador';
  static const senhaCol = 'senha';

  RequisicaoLoginUsuario({
    this.identificador = '',
    this.senha = '',
  });

  String identificador;
  String senha;

  RequisicaoLoginUsuario clone() {
    return RequisicaoLoginUsuario(
      identificador: identificador,
      senha: senha,
    );
  }

  factory RequisicaoLoginUsuario.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoLoginUsuario(
      identificador: mapa[identificadorCol]?.toString() ?? '',
      senha: mapa[senhaCol]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      identificadorCol: identificador,
      senhaCol: senha,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }
}