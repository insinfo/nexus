import 'dart:convert';

import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../extensions/eloquent.dart';

import '../utils/json_utils.dart';

class ReconstrutorFormularioPersistidoService {
  const ReconstrutorFormularioPersistidoService(this._db);

  final Connection _db;

  Future<DadosNoFormulario> carregarPorIdNo(
    int idNoFluxo, {
    Map<String, dynamic> dadosBase = const <String, dynamic>{},
  }) async {
    final formularios = await carregarPorIdsNos(
      <int>[idNoFluxo],
      dadosBasePorNo: <int, Map<String, dynamic>>{idNoFluxo: dadosBase},
    );

    return formularios[idNoFluxo] ?? _criarFormularioVazio(dadosBase);
  }

  Future<Map<int, DadosNoFormulario>> carregarPorIdsNos(
    List<int> idsNos, {
    Map<int, Map<String, dynamic>> dadosBasePorNo =
        const <int, Map<String, dynamic>>{},
  }) async {
    if (idsNos.isEmpty) {
      return const <int, DadosNoFormulario>{};
    }

    final secoesRows = await _db
        .table(SecaoFormulario.fqtn)
        .whereIn(SecaoFormulario.idNoFluxoCol, idsNos)
        .orderBy(SecaoFormulario.idNoFluxoCol, OrderDir.asc)
        .orderBy(SecaoFormulario.ordemCol, OrderDir.asc)
        .get();
    final secoes = secoesRows
        .map((row) => SecaoFormulario.fromMap(row))
        .toList(growable: false);

    final camposRows = await _db
        .table(CampoFormulario.fqtn)
        .whereIn(CampoFormulario.idNoFluxoCol, idsNos)
        .orderBy(CampoFormulario.idNoFluxoCol, OrderDir.asc)
        .orderBy(CampoFormulario.ordemCol, OrderDir.asc)
        .get();
    final campos = camposRows
        .map((row) => CampoFormulario.fromMap(row))
        .toList(growable: false);

    final idsCampo = campos.map((item) => item.id).toList(growable: false);
    final opcoesPorCampo = await _carregarOpcoesPorCampo(idsCampo);
    final validacoesPorCampo = await _carregarValidacoesPorCampo(idsCampo);
    final regrasPorCampo = await _carregarRegrasPorCampo(idsCampo);
    final calculosPorCampo = await _carregarCalculosPorCampo(idsCampo);

    final secoesPorNo = <int, List<SecaoFormularioDto>>{};
    final secoesPorId = <int, SecaoFormulario>{};
    for (final secao in secoes) {
      secoesPorId[secao.id] = secao;
      secoesPorNo
          .putIfAbsent(secao.idNoFluxo, () => <SecaoFormularioDto>[])
          .add(
            SecaoFormularioDto(
              id: secao.chaveSecao,
              chave: secao.chaveSecao,
              titulo: secao.titulo,
              descricao: secao.descricao,
              ordem: secao.ordem,
              repetivel: secao.repetivel,
            ),
          );
    }

    final perguntasPorNo = <int, List<DefinicaoPergunta>>{};
    for (final campo in campos) {
      final secao = campo.idSecao == null ? null : secoesPorId[campo.idSecao!];
      perguntasPorNo
          .putIfAbsent(campo.idNoFluxo, () => <DefinicaoPergunta>[])
          .add(
            DefinicaoPergunta(
              id: campo.chaveCampo,
              campo: campo.chaveCampo,
              rotulo: campo.rotulo,
              tipo: TipoCampoFormulario.parse(campo.tipoCampo),
              idSecao: secao?.chaveSecao,
              descricao: campo.descricao,
              obrigatorio: campo.obrigatorio,
              placeholder: campo.placeholder,
              mascara: campo.mascara,
              valorPadrao: _lerValor(campo.valorPadraoJson),
              origemDados: JsonUtils.lerMapa(campo.origemDadosJson),
              participaRanking: campo.participaRanking,
              opcoes: opcoesPorCampo[campo.id] ?? const <OpcaoCampo>[],
              validacoes:
                  validacoesPorCampo[campo.id] ?? const <ValidacaoCampo>[],
              regrasVisibilidade: regrasPorCampo[campo.id] ??
                  const <RegraVisibilidadeFormulario>[],
              calculos: calculosPorCampo[campo.id] ?? const <CalculoCampo>[],
            ),
          );
    }

    final formularios = <int, DadosNoFormulario>{};
    for (final idNo in idsNos) {
      final dadosBase = dadosBasePorNo[idNo] ?? const <String, dynamic>{};
      final rotulo = dadosBase['rotulo']?.toString() ?? 'Formulario';
      formularios[idNo] = DadosNoFormulario(
        rotulo: rotulo,
        descricao: dadosBase['descricao']?.toString(),
        secoes: secoesPorNo[idNo] ?? const <SecaoFormularioDto>[],
        perguntas: perguntasPorNo[idNo] ?? const <DefinicaoPergunta>[],
      );
    }

    return formularios;
  }

  Future<Map<int, List<OpcaoCampo>>> _carregarOpcoesPorCampo(
      List<int> idsCampo) async {
    if (idsCampo.isEmpty) {
      return const <int, List<OpcaoCampo>>{};
    }

    final rows = await _db
        .table(OpcaoCampo.fqtn)
        .whereIn(OpcaoCampo.idCampoCol, idsCampo)
        .orderBy(OpcaoCampo.idCampoCol, OrderDir.asc)
        .orderBy(OpcaoCampo.ordemCol, OrderDir.asc)
        .get();

    final mapa = <int, List<OpcaoCampo>>{};
    for (final row in rows) {
      final opcao = OpcaoCampo.fromMap(row);
      mapa.putIfAbsent(opcao.idCampo, () => <OpcaoCampo>[]).add(
            OpcaoCampo(
              valor: opcao.valorOpcao,
              rotulo: opcao.rotuloOpcao,
              ordem: opcao.ordem,
            ),
          );
    }
    return mapa;
  }

  Future<Map<int, List<ValidacaoCampo>>> _carregarValidacoesPorCampo(
      List<int> idsCampo) async {
    if (idsCampo.isEmpty) {
      return const <int, List<ValidacaoCampo>>{};
    }

    final rows = await _db
        .table(ValidacaoCampo.fqtn)
        .whereIn(ValidacaoCampo.idCampoCol, idsCampo)
        .orderBy(ValidacaoCampo.idCampoCol, OrderDir.asc)
        .orderBy(ValidacaoCampo.idCol, OrderDir.asc)
        .get();

    final mapa = <int, List<ValidacaoCampo>>{};
    for (final row in rows) {
      final validacao = ValidacaoCampo.fromMap(row);
      mapa.putIfAbsent(validacao.idCampo, () => <ValidacaoCampo>[]).add(
            ValidacaoCampo(
              tipo: validacao.tipoValidacao,
              configuracao: JsonUtils.lerMapa(validacao.configuracaoJson),
              mensagem: validacao.mensagem,
            ),
          );
    }
    return mapa;
  }

  Future<Map<int, List<RegraVisibilidadeFormulario>>> _carregarRegrasPorCampo(
      List<int> idsCampo) async {
    if (idsCampo.isEmpty) {
      return const <int, List<RegraVisibilidadeFormulario>>{};
    }

    final rows = await _db
        .table(RegraVisibilidadeCampo.fqtn)
        .whereIn(RegraVisibilidadeCampo.idCampoCol, idsCampo)
        .orderBy(RegraVisibilidadeCampo.idCampoCol, OrderDir.asc)
        .orderBy(RegraVisibilidadeCampo.idCol, OrderDir.asc)
        .get();

    final mapa = <int, List<RegraVisibilidadeFormulario>>{};
    for (final row in rows) {
      final regra = RegraVisibilidadeCampo.fromMap(row);
      mapa
          .putIfAbsent(regra.idCampo, () => <RegraVisibilidadeFormulario>[])
          .add(
            RegraVisibilidadeFormulario(
              expressao: JsonUtils.lerMapa(regra.expressaoJson),
            ),
          );
    }
    return mapa;
  }

  Future<Map<int, List<CalculoCampo>>> _carregarCalculosPorCampo(
      List<int> idsCampo) async {
    if (idsCampo.isEmpty) {
      return const <int, List<CalculoCampo>>{};
    }

    final rows = await _db
        .table(CalculoCampo.fqtn)
        .whereIn(CalculoCampo.idCampoCol, idsCampo)
        .orderBy(CalculoCampo.idCampoCol, OrderDir.asc)
        .orderBy(CalculoCampo.idCol, OrderDir.asc)
        .get();

    final mapa = <int, List<CalculoCampo>>{};
    for (final row in rows) {
      final calculo = CalculoCampo.fromMap(row);
      mapa.putIfAbsent(calculo.idCampo, () => <CalculoCampo>[]).add(
            CalculoCampo(
              expressao: JsonUtils.lerMapa(calculo.expressaoJson),
              escopoDestino: calculo.escopoDestino,
            ),
          );
    }
    return mapa;
  }

  DadosNoFormulario _criarFormularioVazio(Map<String, dynamic> dadosBase) {
    return DadosNoFormulario(
      rotulo: dadosBase['rotulo']?.toString() ?? 'Formulario',
      descricao: dadosBase['descricao']?.toString(),
    );
  }

  static dynamic _lerValor(dynamic valor) {
    if (valor == null) {
      return null;
    }
    if (valor is String && valor.isNotEmpty) {
      return jsonDecode(valor);
    }
    return valor;
  }
}
