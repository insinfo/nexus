import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class CadastroPessoa implements SerializeBase {
  static const tableName = 'cadastro_pessoa';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const numeroCadastroCol = 'numero_cadastro';
  static const numeroCadastroFqCol = '$fqtb.$numeroCadastroCol';
  static const idPublicoCol = 'id_publico';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const tipoCadastroCol = 'tipo_cadastro';
  static const tipoCadastroFqCol = '$fqtb.$tipoCadastroCol';
  static const tipoPessoaAtualCol = 'tipo_pessoa_atual';
  static const tipoPessoaAtualFqCol = '$fqtb.$tipoPessoaAtualCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const idUsuarioVinculadoCol = 'id_usuario_vinculado';
  static const idUsuarioVinculadoFqCol = '$fqtb.$idUsuarioVinculadoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  CadastroPessoa({
    this.numeroCadastro,
    this.idPublico,
    this.tipoCadastro = 'padrao',
    this.tipoPessoaAtual = 'indefinido',
    this.ativo = true,
    this.idUsuarioVinculado,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? numeroCadastro;
  String? idPublico;
  String tipoCadastro;
  String tipoPessoaAtual;
  bool ativo;
  int? idUsuarioVinculado;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  CadastroPessoa clone() {
    return CadastroPessoa(
      numeroCadastro: numeroCadastro,
      idPublico: idPublico,
      tipoCadastro: tipoCadastro,
      tipoPessoaAtual: tipoPessoaAtual,
      ativo: ativo,
      idUsuarioVinculado: idUsuarioVinculado,
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

  factory CadastroPessoa.fromMap(Map<String, dynamic> mapa) {
    return CadastroPessoa(
      numeroCadastro: mapa['numero_cadastro'] as int?,
      idPublico: mapa['id_publico'] as String?,
      tipoCadastro: (mapa['tipo_cadastro'] as String?) ?? 'padrao',
      tipoPessoaAtual: (mapa['tipo_pessoa_atual'] as String?) ?? 'indefinido',
      ativo: (mapa['ativo'] as bool?) ?? true,
      idUsuarioVinculado: mapa['id_usuario_vinculado'] as int?,
      criadoEm: lerDataHora(mapa['criado_em']),
      atualizadoEm: lerDataHora(mapa['atualizado_em']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'numero_cadastro': numeroCadastro,
        'id_publico': idPublico,
        'tipo_cadastro': tipoCadastro,
        'tipo_pessoa_atual': tipoPessoaAtual,
        'ativo': ativo,
        'id_usuario_vinculado': idUsuarioVinculado,
        'criado_em': criadoEm?.toIso8601String(),
        'atualizado_em': atualizadoEm?.toIso8601String(),
      };
}
