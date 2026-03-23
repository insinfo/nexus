import 'package:essential_core/essential_core.dart';

class ResultadoIniciarFederacaoOidc implements SerializeBase {
  ResultadoIniciarFederacaoOidc({
    this.nomeProvedor = 'microsoft',
    this.urlAutorizacao = '',
    this.state,
    this.nonce,
    this.habilitado = false,
    this.mensagem,
  });

  String nomeProvedor;
  String urlAutorizacao;
  String? state;
  String? nonce;
  bool habilitado;
  String? mensagem;

  factory ResultadoIniciarFederacaoOidc.fromMap(Map<String, dynamic> map) {
    return ResultadoIniciarFederacaoOidc(
      nomeProvedor: map['nome_provedor']?.toString() ?? 'microsoft',
      urlAutorizacao: map['url_autorizacao']?.toString() ?? '',
      state: map['state']?.toString(),
      nonce: map['nonce']?.toString(),
      habilitado: (map['habilitado'] as bool?) ?? false,
      mensagem: map['mensagem']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nome_provedor': nomeProvedor,
      'url_autorizacao': urlAutorizacao,
      'state': state,
      'nonce': nonce,
      'habilitado': habilitado,
      'mensagem': mensagem,
    };
  }

  ResultadoIniciarFederacaoOidc clone() {
    return ResultadoIniciarFederacaoOidc.fromMap(toMap());
  }
}
