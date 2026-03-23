import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';

class ItemFilaTrabalho implements SerializeBase {
  static const tableName = 'item_fila_trabalho';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const departamentoCol = 'departamento';
  static const departamentoFqCol = '$fqtb.$departamentoCol';
  static const codigoServicoCol = 'codigo_servico';
  static const codigoServicoFqCol = '$fqtb.$codigoServicoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const rotuloResponsavelCol = 'rotulo_responsavel';
  static const rotuloResponsavelFqCol = '$fqtb.$rotuloResponsavelCol';
  static const rotuloPrazoCol = 'rotulo_prazo';
  static const rotuloPrazoFqCol = '$fqtb.$rotuloPrazoCol';

  ItemFilaTrabalho({
    required this.id,
    required this.titulo,
    required this.departamento,
    required this.codigoServico,
    required this.status,
    required this.rotuloResponsavel,
    required this.rotuloPrazo,
  });
  String id;
  String titulo;
  String departamento;
  String codigoServico;
  StatusItemTrabalhoRetaguarda status;
  String rotuloResponsavel;
  String rotuloPrazo;
  ItemFilaTrabalho clone() {
    return ItemFilaTrabalho(
      id: id,
      titulo: titulo,
      departamento: departamento,
      codigoServico: codigoServico,
      status: status,
      rotuloResponsavel: rotuloResponsavel,
      rotuloPrazo: rotuloPrazo,
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

  factory ItemFilaTrabalho.fromMap(Map<String, dynamic> mapa) {
    return ItemFilaTrabalho(
      id: mapa['id'] as String,
      titulo: mapa['titulo'] as String,
      departamento: mapa['departamento'] as String,
      codigoServico: mapa['codigo_servico'] as String,
      status: StatusItemTrabalhoRetaguarda.parse(mapa['status'] as String),
      rotuloResponsavel: mapa['rotulo_responsavel'] as String,
      rotuloPrazo: mapa['rotulo_prazo'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'departamento': departamento,
      'codigo_servico': codigoServico,
      'status': status.val,
      'rotulo_responsavel': rotuloResponsavel,
      'rotulo_prazo': rotuloPrazo,
    };
  }
}
