import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'dados_no_fluxo.dart';
import 'definicao_pergunta.dart';
import 'secao_formulario_dto.dart';

class DadosNoFormulario extends DadosNoFluxo {
  static const tableName = 'dados_no_formulario';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const secoesCol = 'secoes';
  static const secoesFqCol = '$fqtb.$secoesCol';
  static const perguntasCol = 'perguntas';
  static const perguntasFqCol = '$fqtb.$perguntasCol';

  DadosNoFormulario({
    required this.rotulo,
    this.descricao,
    this.secoes = const <SecaoFormularioDto>[],
    this.perguntas = const <DefinicaoPergunta>[],
  });
  String rotulo;
  String? descricao;
  List<SecaoFormularioDto> secoes;
  List<DefinicaoPergunta> perguntas;
  DadosNoFormulario clone() {
    return DadosNoFormulario(
      rotulo: rotulo,
      descricao: descricao,
      secoes: secoes,
      perguntas: perguntas,
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

  factory DadosNoFormulario.fromMap(Map<String, dynamic> mapa) {
    return DadosNoFormulario(
      rotulo: mapa['rotulo'] as String,
      descricao: mapa['descricao'] as String?,
      secoes: mapearLista(mapa['secoes'], SecaoFormularioDto.fromMap),
      perguntas: mapearLista(mapa['perguntas'], DefinicaoPergunta.fromMap),
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.formulario.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotulo': rotulo,
      'descricao': descricao,
      'secoes': serializarLista(secoes),
      'perguntas': serializarLista(perguntas),
    };
  }
}
