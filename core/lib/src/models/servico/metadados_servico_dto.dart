import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';

class MetadadosServicoDto implements SerializeBase {
  static const tableName = 'metadados_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const categoriaCol = 'categoria';
  static const categoriaFqCol = '$fqtb.$categoriaCol';
  static const canaisCol = 'canais';
  static const canaisFqCol = '$fqtb.$canaisCol';
  static const modoAcessoCol = 'modo_acesso';
  static const modoAcessoFqCol = '$fqtb.$modoAcessoCol';
  static const orgaosPermitidosCol = 'orgaos_permitidos';
  static const orgaosPermitidosFqCol = '$fqtb.$orgaosPermitidosCol';
  static const responsavelServicoCol = 'responsavel_servico';
  static const responsavelServicoFqCol = '$fqtb.$responsavelServicoCol';
  static const exibirResponsavelServicoCol = 'exibir_responsavel_servico';
  static const exibirResponsavelServicoFqCol =
      '$fqtb.$exibirResponsavelServicoCol';
  static const etiquetasCol = 'etiquetas';
  static const etiquetasFqCol = '$fqtb.$etiquetasCol';

  MetadadosServicoDto({
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.canais,
    required this.modoAcesso,
    this.orgaosPermitidos = const <String>[],
    this.responsavelServico,
    this.exibirResponsavelServico = false,
    this.etiquetas = const <String>[],
  });
  String nome;
  String descricao;
  String categoria;
  List<CanalServico> canais;
  ModoAcesso modoAcesso;
  List<String> orgaosPermitidos;
  String? responsavelServico;
  bool exibirResponsavelServico;
  List<String> etiquetas;
  MetadadosServicoDto clone() {
    return MetadadosServicoDto(
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      canais: canais,
      modoAcesso: modoAcesso,
      orgaosPermitidos: orgaosPermitidos,
      responsavelServico: responsavelServico,
      exibirResponsavelServico: exibirResponsavelServico,
      etiquetas: etiquetas,
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

  factory MetadadosServicoDto.fromMap(Map<String, dynamic> mapa) {
    return MetadadosServicoDto(
      nome: mapa['nome'] as String,
      descricao: mapa['descricao'] as String,
      categoria: mapa['categoria'] as String,
      canais: lerListaTexto(mapa['canais'])
          .map(CanalServico.parse)
          .toList(growable: false),
      modoAcesso: ModoAcesso.parse(mapa['modo_acesso'] as String),
      orgaosPermitidos: lerListaTexto(mapa['orgaos_permitidos']),
      responsavelServico: mapa['responsavel_servico'] as String?,
      exibirResponsavelServico:
          (mapa['exibir_responsavel_servico'] as bool?) ?? false,
      etiquetas: lerListaTexto(mapa['etiquetas']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'canais':
          canais.map((CanalServico item) => item.val).toList(growable: false),
      'modo_acesso': modoAcesso.val,
      'orgaos_permitidos': orgaosPermitidos,
      'responsavel_servico': responsavelServico,
      'exibir_responsavel_servico': exibirResponsavelServico,
      'etiquetas': etiquetas,
    };
  }
}
