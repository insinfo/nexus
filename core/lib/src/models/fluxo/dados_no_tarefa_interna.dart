import '../comum/enums_nexus.dart';
import 'dados_no_fluxo.dart';

class DadosNoTarefaInterna extends DadosNoFluxo {
  static const tableName = 'dados_no_tarefa_interna';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const prioridadeCol = 'prioridade';
  static const prioridadeFqCol = '$fqtb.$prioridadeCol';

  DadosNoTarefaInterna({
    required this.rotulo,
    required this.titulo,
    this.descricao,
    this.prioridade = 'normal',
  });

  String rotulo;
  String titulo;
  String? descricao;
  String prioridade;

  DadosNoTarefaInterna clone() {
    return DadosNoTarefaInterna(
      rotulo: rotulo,
      titulo: titulo,
      descricao: descricao,
      prioridade: prioridade,
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

  factory DadosNoTarefaInterna.fromMap(Map<String, dynamic> mapa) {
    final rotulo = mapa[rotuloCol] as String? ?? '';
    return DadosNoTarefaInterna(
      rotulo: rotulo,
      titulo: mapa[tituloCol] as String? ?? rotulo,
      descricao: mapa[descricaoCol] as String?,
      prioridade: mapa[prioridadeCol] as String? ?? 'normal',
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.tarefaInterna.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      rotuloCol: rotulo,
      tituloCol: titulo,
      descricaoCol: descricao,
      prioridadeCol: prioridade,
    };
  }
}
