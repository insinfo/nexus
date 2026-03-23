import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'calculo_campo.dart';
import 'opcao_campo.dart';
import 'regra_visibilidade_formulario.dart';
import 'validacao_campo.dart';

class DefinicaoPergunta implements SerializeBase {
  static const tableName = 'definicao_pergunta';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const campoCol = 'campo';
  static const campoFqCol = '$fqtb.$campoCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const idSecaoCol = 'id_secao';
  static const idSecaoFqCol = '$fqtb.$idSecaoCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const obrigatorioCol = 'obrigatorio';
  static const obrigatorioFqCol = '$fqtb.$obrigatorioCol';
  static const placeholderCol = 'placeholder';
  static const placeholderFqCol = '$fqtb.$placeholderCol';
  static const mascaraCol = 'mascara';
  static const mascaraFqCol = '$fqtb.$mascaraCol';
  static const valorPadraoCol = 'valor_padrao';
  static const valorPadraoFqCol = '$fqtb.$valorPadraoCol';
  static const origemDadosCol = 'origem_dados';
  static const origemDadosFqCol = '$fqtb.$origemDadosCol';
  static const participaRankingCol = 'participa_ranking';
  static const participaRankingFqCol = '$fqtb.$participaRankingCol';
  static const opcoesCol = 'opcoes';
  static const opcoesFqCol = '$fqtb.$opcoesCol';
  static const validacoesCol = 'validacoes';
  static const validacoesFqCol = '$fqtb.$validacoesCol';
  static const regrasVisibilidadeCol = 'regras_visibilidade';
  static const regrasVisibilidadeFqCol = '$fqtb.$regrasVisibilidadeCol';
  static const calculosCol = 'calculos';
  static const calculosFqCol = '$fqtb.$calculosCol';

  DefinicaoPergunta({
    required this.id,
    required this.campo,
    required this.rotulo,
    required this.tipo,
    this.idSecao,
    this.descricao,
    this.obrigatorio = false,
    this.placeholder,
    this.mascara,
    this.valorPadrao,
    this.origemDados = const <String, dynamic>{},
    this.participaRanking = false,
    this.opcoes = const <OpcaoCampo>[],
    this.validacoes = const <ValidacaoCampo>[],
    this.regrasVisibilidade = const <RegraVisibilidadeFormulario>[],
    this.calculos = const <CalculoCampo>[],
  });
  String id;
  String campo;
  String rotulo;
  TipoCampoFormulario tipo;
  String? idSecao;
  String? descricao;
  bool obrigatorio;
  String? placeholder;
  String? mascara;
  dynamic valorPadrao;
  Map<String, dynamic> origemDados;
  bool participaRanking;
  List<OpcaoCampo> opcoes;
  List<ValidacaoCampo> validacoes;
  List<RegraVisibilidadeFormulario> regrasVisibilidade;
  List<CalculoCampo> calculos;
  DefinicaoPergunta clone() {
    return DefinicaoPergunta(
      id: id,
      campo: campo,
      rotulo: rotulo,
      tipo: tipo,
      idSecao: idSecao,
      descricao: descricao,
      obrigatorio: obrigatorio,
      placeholder: placeholder,
      mascara: mascara,
      valorPadrao: valorPadrao,
      origemDados: origemDados,
      participaRanking: participaRanking,
      opcoes: opcoes,
      validacoes: validacoes,
      regrasVisibilidade: regrasVisibilidade,
      calculos: calculos,
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

  factory DefinicaoPergunta.fromMap(Map<String, dynamic> mapa) {
    final opcoesRaw = (mapa['opcoes'] as List<dynamic>?) ?? const <dynamic>[];
    return DefinicaoPergunta(
      id: mapa['id'] as String,
      campo: mapa['campo'] as String,
      rotulo: mapa['rotulo'] as String,
      tipo: TipoCampoFormulario.parse(mapa['tipo'] as String),
      idSecao: mapa['id_secao'] as String?,
      descricao: mapa['descricao'] as String?,
      obrigatorio: (mapa['obrigatorio'] as bool?) ?? false,
      placeholder: mapa['placeholder'] as String?,
      mascara: mapa['mascara'] as String?,
      valorPadrao: mapa['valor_padrao'],
      origemDados: lerMapa(mapa['origem_dados']),
      participaRanking: mapa['participa_ranking'] as bool? ?? false,
      opcoes: opcoesRaw.map((item) {
        if (item is Map) {
          return OpcaoCampo.fromMap(Map<String, dynamic>.from(item));
        }
        return OpcaoCampo(valor: item.toString(), rotulo: item.toString());
      }).toList(growable: false),
      validacoes: mapearLista(mapa['validacoes'], ValidacaoCampo.fromMap),
      regrasVisibilidade: mapearLista(
        mapa['regras_visibilidade'],
        RegraVisibilidadeFormulario.fromMap,
      ),
      calculos: mapearLista(mapa['calculos'], CalculoCampo.fromMap),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'campo': campo,
      'rotulo': rotulo,
      'tipo': tipo.val,
      'id_secao': idSecao,
      'descricao': descricao,
      'obrigatorio': obrigatorio,
      'placeholder': placeholder,
      'mascara': mascara,
      'valor_padrao': valorPadrao,
      'origem_dados': origemDados,
      'participa_ranking': participaRanking,
      'opcoes': serializarLista(opcoes),
      'validacoes': serializarLista(validacoes),
      'regras_visibilidade': serializarLista(regrasVisibilidade),
      'calculos': serializarLista(calculos),
    };
  }
}
