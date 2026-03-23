import '../comum/enums_nexus.dart';
import 'dados_no_fluxo.dart';

class DadosNoAtualizacaoStatus extends DadosNoFluxo {
  static const tableName = 'dados_no_atualizacao_status';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const novoStatusCol = 'novo_status';
  static const novoStatusFqCol = '$fqtb.$novoStatusCol';
  static const motivoCol = 'motivo';
  static const motivoFqCol = '$fqtb.$motivoCol';

  DadosNoAtualizacaoStatus({
    required this.rotulo,
    required this.novoStatus,
    this.motivo,
  });

  String rotulo;
  String novoStatus;
  String? motivo;

  DadosNoAtualizacaoStatus clone() {
    return DadosNoAtualizacaoStatus(
      rotulo: rotulo,
      novoStatus: novoStatus,
      motivo: motivo,
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

  factory DadosNoAtualizacaoStatus.fromMap(Map<String, dynamic> mapa) {
    return DadosNoAtualizacaoStatus(
      rotulo: mapa[rotuloCol] as String? ?? '',
      novoStatus: mapa[novoStatusCol] as String? ?? 'submetida',
      motivo: mapa[motivoCol] as String?,
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.atualizacaoStatus.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      rotuloCol: rotulo,
      novoStatusCol: novoStatus,
      motivoCol: motivo,
    };
  }
}
