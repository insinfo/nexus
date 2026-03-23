import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'dados_no_fluxo.dart';
import '../conteudo_rico/documento_conteudo_rico.dart';

class DadosNoApresentacao extends DadosNoFluxo {
  static const tableName = 'dados_no_apresentacao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const conteudoApresentacaoCol = 'conteudo_apresentacao';
  static const conteudoApresentacaoFqCol = '$fqtb.$conteudoApresentacaoCol';
  static const conteudoAdicionalCol = 'conteudo_adicional';
  static const conteudoAdicionalFqCol = '$fqtb.$conteudoAdicionalCol';

  DadosNoApresentacao({
    required this.rotulo,
    required this.conteudoApresentacao,
    this.conteudoAdicional,
  });
  String rotulo;
  DocumentoConteudoRico conteudoApresentacao;
  DocumentoConteudoRico? conteudoAdicional;
  DadosNoApresentacao clone() {
    return DadosNoApresentacao(
      rotulo: rotulo,
      conteudoApresentacao: conteudoApresentacao,
      conteudoAdicional: conteudoAdicional,
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

  factory DadosNoApresentacao.fromMap(Map<String, dynamic> mapa) {
    return DadosNoApresentacao(
      rotulo: mapa['rotulo'] as String,
      conteudoApresentacao: DocumentoConteudoRico.fromMap(
        lerMapa(mapa['conteudo_apresentacao']),
      ),
      conteudoAdicional: mapa['conteudo_adicional'] == null
          ? null
          : DocumentoConteudoRico.fromMap(lerMapa(mapa['conteudo_adicional'])),
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.apresentacao.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotulo': rotulo,
      'conteudo_apresentacao': conteudoApresentacao.toMap(),
      'conteudo_adicional': serializarOpcional(conteudoAdicional),
    };
  }
}
