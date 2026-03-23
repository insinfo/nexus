import '../comum/enums_nexus.dart';
import '../conteudo_rico/documento_conteudo_rico.dart';
import '../suporte/modelo_utils.dart';
import 'dados_no_fluxo.dart';

class DadosNoConteudoDinamico extends DadosNoFluxo {
  static const tableName = 'dados_no_conteudo_dinamico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const metodoCol = 'metodo';
  static const metodoFqCol = '$fqtb.$metodoCol';
  static const urlCol = 'url';
  static const urlFqCol = '$fqtb.$urlCol';
  static const modeloConteudoCol = 'modelo_conteudo';
  static const modeloConteudoFqCol = '$fqtb.$modeloConteudoCol';
  static const cabecalhosCol = 'cabecalhos';
  static const cabecalhosFqCol = '$fqtb.$cabecalhosCol';
  static const modeloPayloadCol = 'modelo_payload';
  static const modeloPayloadFqCol = '$fqtb.$modeloPayloadCol';
  static const timeoutMsCol = 'timeout_ms';
  static const timeoutMsFqCol = '$fqtb.$timeoutMsCol';
  static const finalizaFluxoCol = 'finaliza_fluxo';
  static const finalizaFluxoFqCol = '$fqtb.$finalizaFluxoCol';

  DadosNoConteudoDinamico({
    required this.rotulo,
    required this.metodo,
    required this.url,
    required this.modeloConteudo,
    this.cabecalhos = const <String, String>{},
    this.modeloPayload,
    this.timeoutMs,
    this.finalizaFluxo = false,
  });
  String rotulo;
  String metodo;
  String url;
  DocumentoConteudoRico modeloConteudo;
  Map<String, String> cabecalhos;
  String? modeloPayload;
  int? timeoutMs;
  bool finalizaFluxo;
  DadosNoConteudoDinamico clone() {
    return DadosNoConteudoDinamico(
      rotulo: rotulo,
      metodo: metodo,
      url: url,
      modeloConteudo: modeloConteudo,
      cabecalhos: cabecalhos,
      modeloPayload: modeloPayload,
      timeoutMs: timeoutMs,
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

  factory DadosNoConteudoDinamico.fromMap(Map<String, dynamic> mapa) {
    return DadosNoConteudoDinamico(
      rotulo: mapa['rotulo'] as String,
      metodo: mapa['metodo'] as String,
      url: mapa['url'] as String,
      modeloConteudo:
          DocumentoConteudoRico.fromMap(lerMapa(mapa['modelo_conteudo'])),
      cabecalhos: Map<String, String>.from(
        (mapa['cabecalhos'] as Map?) ?? const <String, String>{},
      ),
      modeloPayload: mapa['modelo_payload'] as String?,
      timeoutMs: mapa['timeout_ms'] as int?,
      finalizaFluxo: (mapa['finaliza_fluxo'] as bool?) ?? false,
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.conteudoDinamico.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotulo': rotulo,
      'metodo': metodo,
      'url': url,
      'modelo_conteudo': modeloConteudo.toMap(),
      'cabecalhos': cabecalhos,
      'modelo_payload': modeloPayload,
      'timeout_ms': timeoutMs,
      'finaliza_fluxo': finalizaFluxo,
    };
  }
}
