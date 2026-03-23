import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ContaCidadao implements SerializeBase {
  static const tableName = 'contas_cidadao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const numeroCadastroPessoaCol = 'numero_cadastro_pessoa';
  static const numeroCadastroPessoaFqCol = '$fqtb.$numeroCadastroPessoaCol';
  static const cpfCol = 'cpf';
  static const cpfFqCol = '$fqtb.$cpfCol';
  static const cnpjCol = 'cnpj';
  static const cnpjFqCol = '$fqtb.$cnpjCol';
  static const nisCol = 'nis';
  static const nisFqCol = '$fqtb.$nisCol';
  static const assuntoGovbrCol = 'assunto_govbr';
  static const assuntoGovbrFqCol = '$fqtb.$assuntoGovbrCol';
  static const telefoneCol = 'telefone';
  static const telefoneFqCol = '$fqtb.$telefoneCol';
  static const dataNascimentoCol = 'data_nascimento';
  static const dataNascimentoFqCol = '$fqtb.$dataNascimentoCol';
  static const metadadosCol = 'metadados';
  static const metadadosFqCol = '$fqtb.$metadadosCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  ContaCidadao({
    this.id,
    this.idUsuario,
    this.numeroCadastroPessoa,
    this.cpf,
    this.cnpj,
    this.nis,
    this.assuntoGovbr,
    this.telefone,
    this.dataNascimento,
    this.metadados = const <String, dynamic>{},
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  int? idUsuario;
  int? numeroCadastroPessoa;
  String? cpf;
  String? cnpj;
  String? nis;
  String? assuntoGovbr;
  String? telefone;
  DateTime? dataNascimento;
  Map<String, dynamic> metadados;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  ContaCidadao clone() {
    return ContaCidadao(
      id: id,
      idUsuario: idUsuario,
      numeroCadastroPessoa: numeroCadastroPessoa,
      cpf: cpf,
      cnpj: cnpj,
      nis: nis,
      assuntoGovbr: assuntoGovbr,
      telefone: telefone,
      dataNascimento: dataNascimento,
      metadados: metadados,
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

  factory ContaCidadao.fromMap(Map<String, dynamic> mapa) {
    return ContaCidadao(
      id: mapa[idCol] as int?,
      idUsuario: mapa[idUsuarioCol] as int?,
      numeroCadastroPessoa: mapa[numeroCadastroPessoaCol] as int?,
      cpf: mapa[cpfCol] as String?,
      cnpj: mapa[cnpjCol] as String?,
      nis: mapa[nisCol] as String?,
      assuntoGovbr: mapa[assuntoGovbrCol] as String?,
      telefone: mapa[telefoneCol] as String?,
      dataNascimento: lerDataHora(mapa[dataNascimentoCol]),
      metadados: lerMapa(mapa['metadados_json'] ?? mapa[metadadosCol]),
      criadoEm: lerDataHora(mapa[criadoEmCol]),
      atualizadoEm: lerDataHora(mapa[atualizadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      idCol: id,
      idUsuarioCol: idUsuario,
      numeroCadastroPessoaCol: numeroCadastroPessoa,
      cpfCol: cpf,
      cnpjCol: cnpj,
      nisCol: nis,
      assuntoGovbrCol: assuntoGovbr,
      telefoneCol: telefone,
      dataNascimentoCol: dataNascimento?.toIso8601String(),
      'metadados_json': metadados,
      criadoEmCol: criadoEm?.toIso8601String(),
      atualizadoEmCol: atualizadoEm?.toIso8601String(),
      };
}
