import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class RequisicaoIniciarSessao implements SerializeBase {
  static const tableName = 'requisicao_iniciar_sessao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idServicoCol = 'id_servico';
  static const idServicoFqCol = '$fqtb.$idServicoCol';
  static const canalCol = 'canal';
  static const canalFqCol = '$fqtb.$canalCol';
  static const contextoInicialCol = 'contexto_inicial';
  static const contextoInicialFqCol = '$fqtb.$contextoInicialCol';

  RequisicaoIniciarSessao({
    required this.idServico,
    this.canal = 'portal_cidadao',
    this.contextoInicial = const <String, dynamic>{},
  });

  String idServico;
  String canal;
  Map<String, dynamic> contextoInicial;

  RequisicaoIniciarSessao clone() {
    return RequisicaoIniciarSessao(
      idServico: idServico,
      canal: canal,
      contextoInicial: contextoInicial,
    );
  }

  factory RequisicaoIniciarSessao.fromMap(Map<String, dynamic> mapa) {
    return RequisicaoIniciarSessao(
      idServico: mapa[idServicoCol] as String,
      canal: mapa[canalCol]?.toString() ?? 'portal_cidadao',
      contextoInicial: lerMapa(mapa[contextoInicialCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idServicoCol: idServico,
      canalCol: canal,
      contextoInicialCol: contextoInicial,
    };
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
}
