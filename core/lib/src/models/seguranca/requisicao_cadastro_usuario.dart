import 'package:essential_core/essential_core.dart';

class RequisicaoCadastroUsuario implements SerializeBase {
  static const tableName = 'requisicao_cadastro_usuario';
  static const fqtb = 'public.$tableName';
  static const nomeUsuarioCol = 'nome_usuario';
  static const emailCol = 'email';
  static const senhaCol = 'senha';
  static const nomeExibicaoCol = 'nome_exibicao';
  static const cpfCol = 'cpf';
  static const telefoneCol = 'telefone';
  static const dataNascimentoCol = 'data_nascimento';

  RequisicaoCadastroUsuario({
    this.nomeUsuario = '',
    this.email = '',
    this.senha = '',
    this.nomeExibicao = '',
    this.cpf,
    this.telefone,
    this.dataNascimento,
  });

  String nomeUsuario;
  String email;
  String senha;
  String nomeExibicao;
  String? cpf;
  String? telefone;
  DateTime? dataNascimento;

  RequisicaoCadastroUsuario clone() {
    return RequisicaoCadastroUsuario(
      nomeUsuario: nomeUsuario,
      email: email,
      senha: senha,
      nomeExibicao: nomeExibicao,
      cpf: cpf,
      telefone: telefone,
      dataNascimento: dataNascimento,
    );
  }

  factory RequisicaoCadastroUsuario.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoCadastroUsuario(
      nomeUsuario: mapa[nomeUsuarioCol]?.toString() ?? '',
      email: mapa[emailCol]?.toString() ?? '',
      senha: mapa[senhaCol]?.toString() ?? '',
      nomeExibicao: mapa[nomeExibicaoCol]?.toString() ?? '',
      cpf: mapa[cpfCol]?.toString(),
      telefone: mapa[telefoneCol]?.toString(),
      dataNascimento: mapa[dataNascimentoCol] == null
          ? null
          : DateTime.tryParse(mapa[dataNascimentoCol].toString()),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      nomeUsuarioCol: nomeUsuario,
      emailCol: email,
      senhaCol: senha,
      nomeExibicaoCol: nomeExibicao,
      cpfCol: cpf,
      telefoneCol: telefone,
      dataNascimentoCol: dataNascimento?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }
}