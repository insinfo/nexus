import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../servico/servico_dto.dart';
import '../suporte/modelo_utils.dart';

class ResumoServico implements SerializeBase {
  static const tableName = 'resumo_servico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const categoriaCol = 'categoria';
  static const categoriaFqCol = '$fqtb.$categoriaCol';
  static const modoAcessoCol = 'modo_acesso';
  static const modoAcessoFqCol = '$fqtb.$modoAcessoCol';
  static const canaisCol = 'canais';
  static const canaisFqCol = '$fqtb.$canaisCol';
  static const versaoPublicadaCol = 'versao_publicada';
  static const versaoPublicadaFqCol = '$fqtb.$versaoPublicadaCol';

  ResumoServico({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.modoAcesso,
    required this.canais,
    this.versaoPublicada,
  });
  String id;
  String codigo;
  String nome;
  String descricao;
  String categoria;
  ModoAcesso modoAcesso;
  List<CanalServico> canais;
  int? versaoPublicada;

  factory ResumoServico.fromDefinicao(ServicoDto servico) {
    return ResumoServico(
      id: servico.id,
      codigo: servico.codigo,
      nome: servico.metadados.nome,
      descricao: servico.metadados.descricao,
      categoria: servico.metadados.categoria,
      modoAcesso: servico.metadados.modoAcesso,
      canais: servico.metadados.canais,
      versaoPublicada: servico.versaoPublicada?.versao,
    );
  }
  ResumoServico clone() {
    return ResumoServico(
      id: id,
      codigo: codigo,
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      modoAcesso: modoAcesso,
      canais: canais,
      versaoPublicada: versaoPublicada,
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

  factory ResumoServico.fromMap(Map<String, dynamic> mapa) {
    return ResumoServico(
      id: mapa['id'] as String,
      codigo: mapa['codigo'] as String,
      nome: mapa['nome'] as String,
      descricao: mapa['descricao'] as String,
      categoria: mapa['categoria'] as String,
      modoAcesso: ModoAcesso.parse(mapa['modo_acesso'] as String),
      canais: lerListaTexto(mapa['canais'])
          .map(CanalServico.parse)
          .toList(growable: false),
      versaoPublicada: mapa['versao_publicada'] as int?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'modo_acesso': modoAcesso.val,
      'canais':
          canais.map((CanalServico item) => item.val).toList(growable: false),
      'versao_publicada': versaoPublicada,
    };
  }
}
