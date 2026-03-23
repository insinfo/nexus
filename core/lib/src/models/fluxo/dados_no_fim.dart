import '../comum/enums_nexus.dart';
import '../conteudo_rico/documento_conteudo_rico.dart';
import '../suporte/modelo_utils.dart';
import 'dados_no_fluxo.dart';

class DadosNoFim extends DadosNoFluxo {
  static const tableName = 'dados_no_fim';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const conteudoCol = 'conteudo';
  static const conteudoFqCol = '$fqtb.$conteudoCol';
  static const finalizaFluxoCol = 'finaliza_fluxo';
  static const finalizaFluxoFqCol = '$fqtb.$finalizaFluxoCol';

  DadosNoFim({
    required this.rotulo,
    this.conteudo,
    this.finalizaFluxo = true,
  });
  String rotulo;
  DocumentoConteudoRico? conteudo;
  bool finalizaFluxo;
  DadosNoFim clone() {
    return DadosNoFim(
      rotulo: rotulo,
      conteudo: conteudo,
      finalizaFluxo: finalizaFluxo,
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

  factory DadosNoFim.fromMap(Map<String, dynamic> mapa) {
    return DadosNoFim(
      rotulo: mapa['rotulo'] as String,
      conteudo: mapa['conteudo'] == null
          ? null
          : DocumentoConteudoRico.fromMap(lerMapa(mapa['conteudo'])),
      finalizaFluxo: (mapa['finaliza_fluxo'] as bool?) ?? true,
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.fim.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotulo': rotulo,
      'conteudo': serializarOpcional(conteudo),
      'finaliza_fluxo': finalizaFluxo,
    };
  }
}
