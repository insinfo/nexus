import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';
import 'dados_no_fluxo.dart';
import 'fabrica_dados_no_fluxo.dart';
import 'posicao_xy.dart';

class NoFluxoDto implements SerializeBase {
  static const tableName = 'definicao_no_fluxo';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const posicaoCol = 'posicao';
  static const posicaoFqCol = '$fqtb.$posicaoCol';
  static const dadosCol = 'dados';
  static const dadosFqCol = '$fqtb.$dadosCol';
  static const larguraCol = 'largura';
  static const larguraFqCol = '$fqtb.$larguraCol';
  static const alturaCol = 'altura';
  static const alturaFqCol = '$fqtb.$alturaCol';

  NoFluxoDto({
    required this.id,
    required this.tipo,
    required this.posicao,
    required this.dados,
    this.largura,
    this.altura,
  });
  String id;
  TipoNoFluxo tipo;
  PosicaoXY posicao;
  DadosNoFluxo dados;
  double? largura;
  double? altura;
  NoFluxoDto clone() {
    return NoFluxoDto(
      id: id,
      tipo: tipo,
      posicao: posicao,
      dados: dados,
      largura: largura,
      altura: altura,
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

  factory NoFluxoDto.fromMap(Map<String, dynamic> mapa) {
    TipoNoFluxo tipo = TipoNoFluxo.parse(mapa['tipo'] as String);
    return NoFluxoDto(
      id: mapa['id'] as String,
      tipo: tipo,
      posicao: PosicaoXY.fromMap(lerMapa(mapa['posicao'])),
      dados: dadosNoFluxoFromMap(tipo: tipo, mapa: lerMapa(mapa['dados'])),
      largura: lerDouble(mapa['largura']),
      altura: lerDouble(mapa['altura']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tipo': tipo.val,
      'posicao': posicao.toMap(),
      'largura': largura,
      'altura': altura,
      'dados': dados.toMap(),
    };
  }
}
