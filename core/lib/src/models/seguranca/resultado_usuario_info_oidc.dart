import 'package:essential_core/essential_core.dart';

class ResultadoUsuarioInfoOidc implements SerializeBase {
  ResultadoUsuarioInfoOidc({
    this.sub = '',
    this.preferredUsername,
    this.name,
    this.email,
    this.emailVerified,
    this.tipoConta,
  });

  String sub;
  String? preferredUsername;
  String? name;
  String? email;
  bool? emailVerified;
  String? tipoConta;

  factory ResultadoUsuarioInfoOidc.fromMap(Map<String, dynamic> map) {
    return ResultadoUsuarioInfoOidc(
      sub: map['sub']?.toString() ?? '',
      preferredUsername: map['preferred_username']?.toString(),
      name: map['name']?.toString(),
      email: map['email']?.toString(),
      emailVerified: map['email_verified'] as bool?,
      tipoConta: map['tipo_conta']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sub': sub,
      'preferred_username': preferredUsername,
      'name': name,
      'email': email,
      'email_verified': emailVerified,
      'tipo_conta': tipoConta,
    };
  }

  ResultadoUsuarioInfoOidc clone() {
    return ResultadoUsuarioInfoOidc.fromMap(toMap());
  }
}
