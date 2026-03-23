import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class AtributoCadastroPessoa implements SerializeBase {
  static const tableName = 'atributos_cadastro_pessoa';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const codigoCol = 'codigo';
  static const nomeCol = 'nome';
  static const tipoValorCol = 'tipo_valor';
  static const descricaoCol = 'descricao';
  static const obrigatorioCol = 'obrigatorio';
  static const ativoCol = 'ativo';
  static const criadoEmCol = 'criado_em';

  static const idFqCol = '$tableName.$idCol';
  static const codigoFqCol = '$tableName.$codigoCol';
  static const nomeFqCol = '$tableName.$nomeCol';
  static const tipoValorFqCol = '$tableName.$tipoValorCol';
  static const descricaoFqCol = '$tableName.$descricaoCol';
  static const obrigatorioFqCol = '$tableName.$obrigatorioCol';
  static const ativoFqCol = '$tableName.$ativoCol';
  static const criadoEmFqCol = '$tableName.$criadoEmCol';

  AtributoCadastroPessoa({
    this.id,
    this.codigo,
    this.nome,
    this.tipoValor = 'texto',
    this.descricao,
    this.obrigatorio = false,
    this.ativo = true,
    this.criadoEm,
  });

  int? id;
  String? codigo;
  String? nome;
  String tipoValor;
  String? descricao;
  bool obrigatorio;
  bool ativo;
  DateTime? criadoEm;

  factory AtributoCadastroPessoa.fromMap(Map<String, dynamic> mapa) {
    return AtributoCadastroPessoa(
      id: lerInt(mapa[idCol]),
      codigo: mapa[codigoCol]?.toString(),
      nome: mapa[nomeCol]?.toString(),
      tipoValor: mapa[tipoValorCol]?.toString() ?? 'texto',
      descricao: mapa[descricaoCol]?.toString(),
      obrigatorio: lerBool(mapa[obrigatorioCol]) ?? false,
      ativo: lerBool(mapa[ativoCol]) ?? true,
      criadoEm: lerDataHora(mapa[criadoEmCol]),
    );
  }
  AtributoCadastroPessoa clone() {
    return AtributoCadastroPessoa(
      id: id,
      codigo: codigo,
      nome: nome,
      tipoValor: tipoValor,
      descricao: descricao,
      obrigatorio: obrigatorio,
      ativo: ativo,
      criadoEm: criadoEm,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      codigoCol: codigo,
      nomeCol: nome,
      tipoValorCol: tipoValor,
      descricaoCol: descricao,
      obrigatorioCol: obrigatorio,
      ativoCol: ativo,
      criadoEmCol: criadoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap()..remove(idCol);
    return map;
  }
}
