import 'package:essential_core/essential_core.dart';

class ResultadoTokenOidc implements SerializeBase {
  ResultadoTokenOidc({
    this.accessToken = '',
    this.tokenType = 'Bearer',
    this.expiresIn = 0,
    this.refreshToken,
    this.idToken,
    this.scope = '',
    this.sessionState,
  });

  String accessToken;
  String tokenType;
  int expiresIn;
  String? refreshToken;
  String? idToken;
  String scope;
  String? sessionState;

  factory ResultadoTokenOidc.fromMap(Map<String, dynamic> map) {
    return ResultadoTokenOidc(
      accessToken: map['access_token']?.toString() ?? '',
      tokenType: map['token_type']?.toString() ?? 'Bearer',
      expiresIn: (map['expires_in'] as num?)?.toInt() ?? 0,
      refreshToken: map['refresh_token']?.toString(),
      idToken: map['id_token']?.toString(),
      scope: map['scope']?.toString() ?? '',
      sessionState: map['session_state']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'id_token': idToken,
      'scope': scope,
      'session_state': sessionState,
    };
  }

  ResultadoTokenOidc clone() {
    return ResultadoTokenOidc.fromMap(toMap());
  }
}
