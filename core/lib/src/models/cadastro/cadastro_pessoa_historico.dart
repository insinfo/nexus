import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class CadastroPessoaHistorico implements SerializeBase {
  static const tableName = 'cadastro_pessoa_historico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const numeroCadastroCol = 'numero_cadastro';
  static const numeroCadastroFqCol = '$fqtb.$numeroCadastroCol';
  static const versaoCol = 'versao';
  static const versaoFqCol = '$fqtb.$versaoCol';
  static const atualCol = 'atual';
  static const atualFqCol = '$fqtb.$atualCol';
  static const motivoAtualizacaoCol = 'motivo_atualizacao';
  static const motivoAtualizacaoFqCol = '$fqtb.$motivoAtualizacaoCol';
  static const justificativaCol = 'justificativa';
  static const justificativaFqCol = '$fqtb.$justificativaCol';
  static const alteradoPorCol = 'alterado_por';
  static const alteradoPorFqCol = '$fqtb.$alteradoPorCol';
  static const vigenteDeCol = 'vigente_de';
  static const vigenteDeFqCol = '$fqtb.$vigenteDeCol';
  static const vigenteAteCol = 'vigente_ate';
  static const vigenteAteFqCol = '$fqtb.$vigenteAteCol';
  static const tipoCadastroCol = 'tipo_cadastro';
  static const tipoCadastroFqCol = '$fqtb.$tipoCadastroCol';
  static const tipoPessoaCol = 'tipo_pessoa';
  static const tipoPessoaFqCol = '$fqtb.$tipoPessoaCol';
  static const nomeCivilCol = 'nome_civil';
  static const nomeCivilFqCol = '$fqtb.$nomeCivilCol';
  static const nomeSocialCol = 'nome_social';
  static const nomeSocialFqCol = '$fqtb.$nomeSocialCol';
  static const razaoSocialCol = 'razao_social';
  static const razaoSocialFqCol = '$fqtb.$razaoSocialCol';
  static const nomeFantasiaCol = 'nome_fantasia';
  static const nomeFantasiaFqCol = '$fqtb.$nomeFantasiaCol';
  static const cpfCol = 'cpf';
  static const cpfFqCol = '$fqtb.$cpfCol';
  static const cnpjCol = 'cnpj';
  static const cnpjFqCol = '$fqtb.$cnpjCol';
  static const inscricaoEstadualCol = 'inscricao_estadual';
  static const inscricaoEstadualFqCol = '$fqtb.$inscricaoEstadualCol';
  static const rgCol = 'rg';
  static const rgFqCol = '$fqtb.$rgCol';
  static const orgaoEmissorCol = 'orgao_emissor';
  static const orgaoEmissorFqCol = '$fqtb.$orgaoEmissorCol';
  static const idUfOrgaoEmissorCol = 'id_uf_orgao_emissor';
  static const idUfOrgaoEmissorFqCol = '$fqtb.$idUfOrgaoEmissorCol';
  static const dataEmissaoRgCol = 'data_emissao_rg';
  static const dataEmissaoRgFqCol = '$fqtb.$dataEmissaoRgCol';
  static const numeroCnhCol = 'numero_cnh';
  static const numeroCnhFqCol = '$fqtb.$numeroCnhCol';
  static const idCategoriaCnhCol = 'id_categoria_cnh';
  static const idCategoriaCnhFqCol = '$fqtb.$idCategoriaCnhCol';
  static const dataValidadeCnhCol = 'data_validade_cnh';
  static const dataValidadeCnhFqCol = '$fqtb.$dataValidadeCnhCol';
  static const pisPasepCol = 'pis_pasep';
  static const pisPasepFqCol = '$fqtb.$pisPasepCol';
  static const idPaisNacionalidadeCol = 'id_pais_nacionalidade';
  static const idPaisNacionalidadeFqCol = '$fqtb.$idPaisNacionalidadeCol';
  static const idEscolaridadeCol = 'id_escolaridade';
  static const idEscolaridadeFqCol = '$fqtb.$idEscolaridadeCol';
  static const dataNascimentoCol = 'data_nascimento';
  static const dataNascimentoFqCol = '$fqtb.$dataNascimentoCol';
  static const sexoCol = 'sexo';
  static const sexoFqCol = '$fqtb.$sexoCol';
  static const idTipoLogradouroCol = 'id_tipo_logradouro';
  static const idTipoLogradouroFqCol = '$fqtb.$idTipoLogradouroCol';
  static const logradouroCol = 'logradouro';
  static const logradouroFqCol = '$fqtb.$logradouroCol';
  static const numeroEnderecoCol = 'numero_endereco';
  static const numeroEnderecoFqCol = '$fqtb.$numeroEnderecoCol';
  static const complementoCol = 'complemento';
  static const complementoFqCol = '$fqtb.$complementoCol';
  static const bairroCol = 'bairro';
  static const bairroFqCol = '$fqtb.$bairroCol';
  static const cepCol = 'cep';
  static const cepFqCol = '$fqtb.$cepCol';
  static const idPaisCol = 'id_pais';
  static const idPaisFqCol = '$fqtb.$idPaisCol';
  static const idUnidadeFederativaCol = 'id_unidade_federativa';
  static const idUnidadeFederativaFqCol = '$fqtb.$idUnidadeFederativaCol';
  static const idMunicipioCol = 'id_municipio';
  static const idMunicipioFqCol = '$fqtb.$idMunicipioCol';
  static const telefoneResidencialCol = 'telefone_residencial';
  static const telefoneResidencialFqCol = '$fqtb.$telefoneResidencialCol';
  static const telefoneComercialCol = 'telefone_comercial';
  static const telefoneComercialFqCol = '$fqtb.$telefoneComercialCol';
  static const ramalComercialCol = 'ramal_comercial';
  static const ramalComercialFqCol = '$fqtb.$ramalComercialCol';
  static const telefoneCelularCol = 'telefone_celular';
  static const telefoneCelularFqCol = '$fqtb.$telefoneCelularCol';
  static const emailCol = 'email';
  static const emailFqCol = '$fqtb.$emailCol';
  static const emailAdicionalCol = 'email_adicional';
  static const emailAdicionalFqCol = '$fqtb.$emailAdicionalCol';
  static const metadadosCol = 'metadados';
  static const metadadosFqCol = '$fqtb.$metadadosCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  CadastroPessoaHistorico({
    this.id,
    this.numeroCadastro,
    this.versao,
    this.atual = true,
    this.motivoAtualizacao = 'cadastro_inicial',
    this.justificativa,
    this.alteradoPor,
    this.vigenteDe,
    this.vigenteAte,
    this.tipoCadastro = 'padrao',
    this.tipoPessoa = 'indefinido',
    this.nomeCivil,
    this.nomeSocial,
    this.razaoSocial,
    this.nomeFantasia,
    this.cpf,
    this.cnpj,
    this.inscricaoEstadual,
    this.rg,
    this.orgaoEmissor,
    this.idUfOrgaoEmissor,
    this.dataEmissaoRg,
    this.numeroCnh,
    this.idCategoriaCnh,
    this.dataValidadeCnh,
    this.pisPasep,
    this.idPaisNacionalidade,
    this.idEscolaridade,
    this.dataNascimento,
    this.sexo,
    this.idTipoLogradouro,
    this.logradouro,
    this.numeroEndereco,
    this.complemento,
    this.bairro,
    this.cep,
    this.idPais,
    this.idUnidadeFederativa,
    this.idMunicipio,
    this.telefoneResidencial,
    this.telefoneComercial,
    this.ramalComercial,
    this.telefoneCelular,
    this.email,
    this.emailAdicional,
    this.metadados = const <String, dynamic>{},
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  int? numeroCadastro;
  int? versao;
  bool atual;
  String motivoAtualizacao;
  String? justificativa;
  int? alteradoPor;
  DateTime? vigenteDe;
  DateTime? vigenteAte;
  String tipoCadastro;
  String tipoPessoa;
  String? nomeCivil;
  String? nomeSocial;
  String? razaoSocial;
  String? nomeFantasia;
  String? cpf;
  String? cnpj;
  String? inscricaoEstadual;
  String? rg;
  String? orgaoEmissor;
  int? idUfOrgaoEmissor;
  DateTime? dataEmissaoRg;
  String? numeroCnh;
  int? idCategoriaCnh;
  DateTime? dataValidadeCnh;
  String? pisPasep;
  int? idPaisNacionalidade;
  int? idEscolaridade;
  DateTime? dataNascimento;
  String? sexo;
  int? idTipoLogradouro;
  String? logradouro;
  String? numeroEndereco;
  String? complemento;
  String? bairro;
  String? cep;
  int? idPais;
  int? idUnidadeFederativa;
  int? idMunicipio;
  String? telefoneResidencial;
  String? telefoneComercial;
  String? ramalComercial;
  String? telefoneCelular;
  String? email;
  String? emailAdicional;
  Map<String, dynamic> metadados;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  CadastroPessoaHistorico clone() {
    return CadastroPessoaHistorico(
      id: id,
      numeroCadastro: numeroCadastro,
      versao: versao,
      atual: atual,
      motivoAtualizacao: motivoAtualizacao,
      justificativa: justificativa,
      alteradoPor: alteradoPor,
      vigenteDe: vigenteDe,
      vigenteAte: vigenteAte,
      tipoCadastro: tipoCadastro,
      tipoPessoa: tipoPessoa,
      nomeCivil: nomeCivil,
      nomeSocial: nomeSocial,
      razaoSocial: razaoSocial,
      nomeFantasia: nomeFantasia,
      cpf: cpf,
      cnpj: cnpj,
      inscricaoEstadual: inscricaoEstadual,
      rg: rg,
      orgaoEmissor: orgaoEmissor,
      idUfOrgaoEmissor: idUfOrgaoEmissor,
      dataEmissaoRg: dataEmissaoRg,
      numeroCnh: numeroCnh,
      idCategoriaCnh: idCategoriaCnh,
      dataValidadeCnh: dataValidadeCnh,
      pisPasep: pisPasep,
      idPaisNacionalidade: idPaisNacionalidade,
      idEscolaridade: idEscolaridade,
      dataNascimento: dataNascimento,
      sexo: sexo,
      idTipoLogradouro: idTipoLogradouro,
      logradouro: logradouro,
      numeroEndereco: numeroEndereco,
      complemento: complemento,
      bairro: bairro,
      cep: cep,
      idPais: idPais,
      idUnidadeFederativa: idUnidadeFederativa,
      idMunicipio: idMunicipio,
      telefoneResidencial: telefoneResidencial,
      telefoneComercial: telefoneComercial,
      ramalComercial: ramalComercial,
      telefoneCelular: telefoneCelular,
      email: email,
      emailAdicional: emailAdicional,
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

  factory CadastroPessoaHistorico.fromMap(Map<String, dynamic> mapa) {
    return CadastroPessoaHistorico(
      id: mapa['id'] as int?,
      numeroCadastro: mapa['numeroCadastro'] as int?,
      versao: mapa['versao'] as int?,
      atual: (mapa['atual'] as bool?) ?? true,
      motivoAtualizacao:
          (mapa['motivoAtualizacao'] as String?) ?? 'cadastro_inicial',
      justificativa: mapa['justificativa'] as String?,
      alteradoPor: mapa['alteradoPor'] as int?,
      vigenteDe: lerDataHora(mapa['vigenteDe']),
      vigenteAte: lerDataHora(mapa['vigenteAte']),
      tipoCadastro: (mapa['tipoCadastro'] as String?) ?? 'padrao',
      tipoPessoa: (mapa['tipoPessoa'] as String?) ?? 'indefinido',
      nomeCivil: mapa['nomeCivil'] as String?,
      nomeSocial: mapa['nomeSocial'] as String?,
      razaoSocial: mapa['razaoSocial'] as String?,
      nomeFantasia: mapa['nomeFantasia'] as String?,
      cpf: mapa['cpf'] as String?,
      cnpj: mapa['cnpj'] as String?,
      inscricaoEstadual: mapa['inscricaoEstadual'] as String?,
      rg: mapa['rg'] as String?,
      orgaoEmissor: mapa['orgaoEmissor'] as String?,
      idUfOrgaoEmissor: mapa['idUfOrgaoEmissor'] as int?,
      dataEmissaoRg: lerDataHora(mapa['dataEmissaoRg']),
      numeroCnh: mapa['numeroCnh'] as String?,
      idCategoriaCnh: mapa['idCategoriaCnh'] as int?,
      dataValidadeCnh: lerDataHora(mapa['dataValidadeCnh']),
      pisPasep: mapa['pisPasep'] as String?,
      idPaisNacionalidade: mapa['idPaisNacionalidade'] as int?,
      idEscolaridade: mapa['idEscolaridade'] as int?,
      dataNascimento: lerDataHora(mapa['dataNascimento']),
      sexo: mapa['sexo'] as String?,
      idTipoLogradouro: mapa['idTipoLogradouro'] as int?,
      logradouro: mapa['logradouro'] as String?,
      numeroEndereco: mapa['numeroEndereco'] as String?,
      complemento: mapa['complemento'] as String?,
      bairro: mapa['bairro'] as String?,
      cep: mapa['cep'] as String?,
      idPais: mapa['idPais'] as int?,
      idUnidadeFederativa: mapa['idUnidadeFederativa'] as int?,
      idMunicipio: mapa['idMunicipio'] as int?,
      telefoneResidencial: mapa['telefoneResidencial'] as String?,
      telefoneComercial: mapa['telefoneComercial'] as String?,
      ramalComercial: mapa['ramalComercial'] as String?,
      telefoneCelular: mapa['telefoneCelular'] as String?,
      email: mapa['email'] as String?,
      emailAdicional: mapa['emailAdicional'] as String?,
      metadados: lerMapa(mapa['metadados']),
      criadoEm: lerDataHora(mapa['criadoEm']),
      atualizadoEm: lerDataHora(mapa['atualizadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'numeroCadastro': numeroCadastro,
      'versao': versao,
      'atual': atual,
      'motivoAtualizacao': motivoAtualizacao,
      'justificativa': justificativa,
      'alteradoPor': alteradoPor,
      'vigenteDe': vigenteDe?.toIso8601String(),
      'vigenteAte': vigenteAte?.toIso8601String(),
      'tipoCadastro': tipoCadastro,
      'tipoPessoa': tipoPessoa,
      'nomeCivil': nomeCivil,
      'nomeSocial': nomeSocial,
      'razaoSocial': razaoSocial,
      'nomeFantasia': nomeFantasia,
      'cpf': cpf,
      'cnpj': cnpj,
      'inscricaoEstadual': inscricaoEstadual,
      'rg': rg,
      'orgaoEmissor': orgaoEmissor,
      'idUfOrgaoEmissor': idUfOrgaoEmissor,
      'dataEmissaoRg': dataEmissaoRg?.toIso8601String(),
      'numeroCnh': numeroCnh,
      'idCategoriaCnh': idCategoriaCnh,
      'dataValidadeCnh': dataValidadeCnh?.toIso8601String(),
      'pisPasep': pisPasep,
      'idPaisNacionalidade': idPaisNacionalidade,
      'idEscolaridade': idEscolaridade,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'sexo': sexo,
      'idTipoLogradouro': idTipoLogradouro,
      'logradouro': logradouro,
      'numeroEndereco': numeroEndereco,
      'complemento': complemento,
      'bairro': bairro,
      'cep': cep,
      'idPais': idPais,
      'idUnidadeFederativa': idUnidadeFederativa,
      'idMunicipio': idMunicipio,
      'telefoneResidencial': telefoneResidencial,
      'telefoneComercial': telefoneComercial,
      'ramalComercial': ramalComercial,
      'telefoneCelular': telefoneCelular,
      'email': email,
      'emailAdicional': emailAdicional,
      'metadados': metadados,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
    };
  }
}
