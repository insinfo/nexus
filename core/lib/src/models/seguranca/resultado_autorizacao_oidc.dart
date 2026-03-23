import 'package:essential_core/essential_core.dart';

class ResultadoAutorizacaoOidc implements SerializeBase {
  ResultadoAutorizacaoOidc({
    this.codigo = '',
    this.redirectUri = '',
    this.state,
    this.nonce,
  });

  String codigo;
  String redirectUri;
  String? state;
  String? nonce;

  factory ResultadoAutorizacaoOidc.fromMap(Map<String, dynamic> map) {
    return ResultadoAutorizacaoOidc(
      codigo: map['code']?.toString() ?? '',
      redirectUri: map['redirect_uri']?.toString() ?? '',
      state: map['state']?.toString(),
      nonce: map['nonce']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': codigo,
      'redirect_uri': redirectUri,
      'state': state,
      'nonce': nonce,
    };
  }

  ResultadoAutorizacaoOidc clone() {
    return ResultadoAutorizacaoOidc.fromMap(toMap());
  }
}
