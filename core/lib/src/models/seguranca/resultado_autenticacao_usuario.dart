import 'package:essential_core/essential_core.dart';

import 'conta_cidadao.dart';
import 'usuario.dart';

class ResultadoAutenticacaoUsuario implements SerializeBase {
  static const tableName = 'resultado_autenticacao_usuario';
  static const fqtb = 'public.$tableName';
  static const usuarioCol = 'usuario';
  static const contaCidadaoCol = 'conta_cidadao';
  static const tokenAcessoCol = 'token_acesso';
  static const refreshTokenCol = 'refresh_token';
  static const tipoTokenCol = 'tipo_token';
  static const expiraEmCol = 'expira_em';

  ResultadoAutenticacaoUsuario({
    required this.usuario,
    this.contaCidadao,
    this.tokenAcesso = '',
    this.refreshToken = '',
    this.tipoToken = 'bearer',
    this.expiraEm,
  });

  Usuario usuario;
  ContaCidadao? contaCidadao;
  String tokenAcesso;
  String refreshToken;
  String tipoToken;
  DateTime? expiraEm;

  ResultadoAutenticacaoUsuario clone() {
    return ResultadoAutenticacaoUsuario(
      usuario: usuario.clone(),
      contaCidadao: contaCidadao?.clone(),
      tokenAcesso: tokenAcesso,
      refreshToken: refreshToken,
      tipoToken: tipoToken,
      expiraEm: expiraEm,
    );
  }

  factory ResultadoAutenticacaoUsuario.fromMap(Map<String, dynamic> mapa) {
    return ResultadoAutenticacaoUsuario(
      usuario: Usuario.fromMap(
        Map<String, dynamic>.from(mapa[usuarioCol] as Map? ?? <String, dynamic>{}),
      ),
      contaCidadao: mapa[contaCidadaoCol] == null
          ? null
          : ContaCidadao.fromMap(
              Map<String, dynamic>.from(mapa[contaCidadaoCol] as Map),
            ),
      tokenAcesso: mapa[tokenAcessoCol]?.toString() ?? '',
      refreshToken: mapa[refreshTokenCol]?.toString() ?? '',
      tipoToken: mapa[tipoTokenCol]?.toString() ?? 'bearer',
      expiraEm: mapa[expiraEmCol] == null
          ? null
          : DateTime.tryParse(mapa[expiraEmCol].toString()),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      usuarioCol: usuario.toMap(),
      contaCidadaoCol: contaCidadao?.toMap(),
      tokenAcessoCol: tokenAcesso,
      refreshTokenCol: refreshToken,
      tipoTokenCol: tipoToken,
      expiraEmCol: expiraEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }
}