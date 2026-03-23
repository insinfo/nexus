import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Usuario implements SerializeBase {
  static const tableName = 'usuarios';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoCol = 'id_publico';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const nomeUsuarioCol = 'nome_usuario';
  static const nomeUsuarioFqCol = '$fqtb.$nomeUsuarioCol';
  static const emailCol = 'email';
  static const emailFqCol = '$fqtb.$emailCol';
  static const hashSenhaCol = 'hash_senha';
  static const hashSenhaFqCol = '$fqtb.$hashSenhaCol';
  static const nomeExibicaoCol = 'nome_exibicao';
  static const nomeExibicaoFqCol = '$fqtb.$nomeExibicaoCol';
  static const tipoContaCol = 'tipo_conta';
  static const tipoContaFqCol = '$fqtb.$tipoContaCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const ultimoLoginEmCol = 'ultimo_login_em';
  static const ultimoLoginEmFqCol = '$fqtb.$ultimoLoginEmCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  Usuario({
    this.id,
    this.idPublico,
    this.nomeUsuario = '',
    this.email = '',
    this.hashSenha,
    this.nomeExibicao = '',
    this.tipoConta = 'interno',
    this.ativo = true,
    this.ultimoLoginEm,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  String? idPublico;
  String nomeUsuario;
  String email;
  String? hashSenha;
  String nomeExibicao;
  String tipoConta;
  bool ativo;
  DateTime? ultimoLoginEm;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  Usuario clone() {
    return Usuario(
      id: id,
      idPublico: idPublico,
      nomeUsuario: nomeUsuario,
      email: email,
      hashSenha: hashSenha,
      nomeExibicao: nomeExibicao,
      tipoConta: tipoConta,
      ativo: ativo,
      ultimoLoginEm: ultimoLoginEm,
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

  factory Usuario.fromMap(Map<String, dynamic> mapa) {
    return Usuario(
      id: mapa[idCol] as int?,
      idPublico: mapa[idPublicoCol]?.toString(),
      nomeUsuario: (mapa[nomeUsuarioCol] as String?) ?? '',
      email: (mapa[emailCol] as String?) ?? '',
      hashSenha: mapa[hashSenhaCol] as String?,
      nomeExibicao: (mapa[nomeExibicaoCol] as String?) ?? '',
      tipoConta: (mapa[tipoContaCol] as String?) ?? 'interno',
      ativo: (mapa['ativo'] as bool?) ?? true,
      ultimoLoginEm: lerDataHora(mapa[ultimoLoginEmCol]),
      criadoEm: lerDataHora(mapa[criadoEmCol]),
      atualizadoEm: lerDataHora(mapa[atualizadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      idCol: id,
      idPublicoCol: idPublico,
      nomeUsuarioCol: nomeUsuario,
      emailCol: email,
      hashSenhaCol: hashSenha,
      nomeExibicaoCol: nomeExibicao,
      tipoContaCol: tipoConta,
      ativoCol: ativo,
      ultimoLoginEmCol: ultimoLoginEm?.toIso8601String(),
      criadoEmCol: criadoEm?.toIso8601String(),
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
      };
}
