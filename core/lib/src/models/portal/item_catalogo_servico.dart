import 'package:essential_core/essential_core.dart';

import '../consulta/resumo_servico.dart';
import '../servico/servico_dto.dart';

class ItemCatalogoServico implements SerializeBase {
  static const tableName = 'item_catalogo_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const resumoCol = 'resumo';
  static const resumoFqCol = '$fqtb.$resumoCol';
  static const categoriaCol = 'categoria';
  static const categoriaFqCol = '$fqtb.$categoriaCol';
  static const publicoCol = 'publico';
  static const publicoFqCol = '$fqtb.$publicoCol';
  static const tempoEstimadoCol = 'tempo_estimado';
  static const tempoEstimadoFqCol = '$fqtb.$tempoEstimadoCol';

  ItemCatalogoServico({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.resumo,
    required this.categoria,
    required this.publico,
    this.tempoEstimado,
  });
  String id;
  String codigo;
  String titulo;
  String resumo;
  String categoria;
  String publico;
  String? tempoEstimado;

  factory ItemCatalogoServico.fromDefinicao(ServicoDto servico) {
    return ItemCatalogoServico(
      id: servico.id,
      codigo: servico.codigo,
      titulo: servico.metadados.nome,
      resumo: servico.metadados.descricao,
      categoria: servico.metadados.categoria,
      publico: servico.metadados.modoAcesso.val,
    );
  }

  factory ItemCatalogoServico.fromResumo(
    ResumoServico resumo, {
    String? tempoEstimado,
  }) {
    return ItemCatalogoServico(
      id: resumo.id,
      codigo: resumo.codigo,
      titulo: resumo.nome,
      resumo: resumo.descricao,
      categoria: resumo.categoria,
      publico: resumo.modoAcesso.label,
      tempoEstimado: tempoEstimado,
    );
  }
  ItemCatalogoServico clone() {
    return ItemCatalogoServico(
      id: id,
      codigo: codigo,
      titulo: titulo,
      resumo: resumo,
      categoria: categoria,
      publico: publico,
      tempoEstimado: tempoEstimado,
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

  factory ItemCatalogoServico.fromMap(Map<String, dynamic> mapa) {
    return ItemCatalogoServico(
      id: mapa['id'] as String,
      codigo: mapa['codigo'] as String,
      titulo: mapa['titulo'] as String,
      resumo: mapa['resumo'] as String,
      categoria: mapa['categoria'] as String,
      publico: mapa['publico'] as String,
      tempoEstimado: mapa['tempo_estimado'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'titulo': titulo,
      'resumo': resumo,
      'categoria': categoria,
      'publico': publico,
      'tempo_estimado': tempoEstimado,
    };
  }
}
