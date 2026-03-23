import 'package:essential_core/essential_core.dart';

class RequisicaoTokenOidc implements SerializeBase {
  RequisicaoTokenOidc({
    this.grantType = 'authorization_code',
    this.clientId = '',
    this.clientSecret,
    this.code,
    this.redirectUri,
    this.codeVerifier,
    this.refreshToken,
  });

  String grantType;
  String clientId;
  String? clientSecret;
  String? code;
  String? redirectUri;
  String? codeVerifier;
  String? refreshToken;

  factory RequisicaoTokenOidc.fromMap(Map<String, dynamic> map) {
    return RequisicaoTokenOidc(
      grantType: map['grant_type']?.toString() ?? 'authorization_code',
      clientId: map['client_id']?.toString() ?? '',
      clientSecret: map['client_secret']?.toString(),
      code: map['code']?.toString(),
      redirectUri: map['redirect_uri']?.toString(),
      codeVerifier: map['code_verifier']?.toString(),
      refreshToken: map['refresh_token']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'grant_type': grantType,
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
      'redirect_uri': redirectUri,
      'code_verifier': codeVerifier,
      'refresh_token': refreshToken,
    };
  }

  RequisicaoTokenOidc clone() {
    return RequisicaoTokenOidc.fromMap(toMap());
  }
}
