import 'dart:convert';

import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';
import '../../../shared/utils/identificador_binding_utils.dart';
import '../../../shared/utils/texto_utils.dart';

class EditorServicosRepository {
  EditorServicosRepository(this.db);

  final Connection db;

  Future<String> saveRascunho({
    required ServicoDto servico,
    required VersaoServicoDto versaoOrigem,
  }) async {
    return (await db.transaction((Connection ctx) async {
      final categoriaId = await _obterOuCriarCategoria(
        ctx,
        servico.metadados.categoria,
      );
      final servicoSalvo = await _salvarServico(
        ctx,
        servico,
        categoriaId,
      );
      final versaoRascunho = await _obterOuCriarVersaoRascunho(
        ctx,
        servicoSalvo.id,
        servico.metadados,
        versaoOrigem.notas,
      );

      await _sincronizarCanais(
          ctx, versaoRascunho.id, servico.metadados.canais);
      await _sincronizarEtiquetas(
          ctx, servicoSalvo.id, servico.metadados.etiquetas);
      await _sincronizarFluxos(ctx, versaoRascunho.id, versaoOrigem.fluxos);

      return servicoSalvo.idPublico ?? servicoSalvo.codigo;
    }))
        .toString();
  }

  Future<String> publishVersao({
    required String idServico,
    required String idVersao,
  }) async {
    return (await db.transaction((Connection ctx) async {
      final servico = await _buscarServico(ctx, idServico, idServico);
      if (servico == null) {
        throw StateError('Servico nao encontrado para publicacao: $idServico');
      }

      final versao = await _buscarVersao(ctx, servico.id, idVersao);
      if (versao == null) {
        throw StateError('Versao nao encontrada para publicacao: $idVersao');
      }

      final publicadaAtual = await ctx
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idServicoCol, Operator.equal, servico.id)
          .where(
            VersaoServico.statusCol,
            Operator.equal,
            StatusVersaoServico.publicada.val,
          )
          .first();
      if (publicadaAtual != null &&
          publicadaAtual[VersaoServico.idCol] != versao.id) {
        final versaoArquivada = VersaoServico.fromMap(publicadaAtual);
        await ctx
            .table(VersaoServico.fqtn)
            .where(VersaoServico.idCol, Operator.equal, versaoArquivada.id)
            .update(
              VersaoServico(
                id: versaoArquivada.id,
                idPublico: versaoArquivada.idPublico,
                idServico: versaoArquivada.idServico,
                numeroVersao: versaoArquivada.numeroVersao,
                status: StatusVersaoServico.arquivada.val,
                notas: versaoArquivada.notas,
                snapshotMetadadosJson: versaoArquivada.snapshotMetadadosJson,
                publicadoEm: versaoArquivada.publicadoEm,
                criadoEm: versaoArquivada.criadoEm,
                atualizadoEm: DateTime.now(),
              ).toUpdateMap(),
            );
      }

      final versaoPublicada = VersaoServico(
        id: versao.id,
        idPublico: versao.idPublico,
        idServico: versao.idServico,
        numeroVersao: versao.numeroVersao,
        status: StatusVersaoServico.publicada.val,
        notas: versao.notas,
        snapshotMetadadosJson: versao.snapshotMetadadosJson,
        publicadoEm: DateTime.now(),
        criadoEm: versao.criadoEm,
        atualizadoEm: DateTime.now(),
      );

      await ctx
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idCol, Operator.equal, versao.id)
          .update(versaoPublicada.toUpdateMap());

      return servico.idPublico ?? servico.codigo;
    }))
        .toString();
  }

  Future<int?> _obterOuCriarCategoria(
    Connection ctx,
    String codigoCategoria,
  ) async {
    if (codigoCategoria.trim().isEmpty || codigoCategoria == 'geral') {
      return null;
    }

    final existente = await ctx
        .table(CategoriaServico.fqtn)
        .where(CategoriaServico.codigoCol, Operator.equal, codigoCategoria)
        .first();
    if (existente != null) {
      return existente[CategoriaServico.idCol] as int;
    }

    final categoria = CategoriaServico(
      id: 0,
      codigo: codigoCategoria,
      nome: codigoCategoria
          .split('-')
          .where((item) => item.isNotEmpty)
          .map((item) => '${item[0].toUpperCase()}${item.substring(1)}')
          .join(' '),
    );
    return await ctx.table(CategoriaServico.fqtn).insertGetId(
          categoria.toInsertMap(),
          CategoriaServico.idCol,
        ) as int;
  }

  Future<Servico> _salvarServico(
    Connection ctx,
    ServicoDto servico,
    int? categoriaId,
  ) async {
    final existente = await _buscarServico(ctx, servico.id, servico.codigo);
    final persistencia = Servico(
      id: existente?.id ?? 0,
      idPublico: existente?.idPublico,
      codigo: servico.codigo,
      nome: servico.metadados.nome,
      slug: TextoUtils.slugificar(servico.metadados.nome.isNotEmpty
          ? servico.metadados.nome
          : servico.codigo),
      descricao: servico.metadados.descricao,
      idCategoria: categoriaId,
      modoAcesso: servico.metadados.modoAcesso.val,
      responsavelServico: servico.metadados.responsavelServico,
      exibirResponsavelServico: servico.metadados.exibirResponsavelServico,
      ativo: true,
      criadoEm: existente?.criadoEm,
      atualizadoEm: DateTime.now(),
    );

    if (existente == null) {
      final id = await ctx.table(Servico.fqtn).insertGetId(
            persistencia.toInsertMap(),
            Servico.idCol,
          ) as int;
      final inserido = await ctx
          .table(Servico.fqtn)
          .where(Servico.idCol, Operator.equal, id)
          .first();
      return Servico.fromMap(inserido!);
    }

    await ctx
        .table(Servico.fqtn)
        .where(Servico.idCol, Operator.equal, existente.id)
        .update(persistencia.toUpdateMap());
    final atualizado = await ctx
        .table(Servico.fqtn)
        .where(Servico.idCol, Operator.equal, existente.id)
        .first();
    return Servico.fromMap(atualizado!);
  }

  Future<Servico?> _buscarServico(
    Connection ctx,
    String idPublico,
    String codigo,
  ) async {
    Map<String, dynamic>? row;
    final uuid = IdentificadorBindingUtils.uuidOuNull(idPublico);
    if (uuid != null) {
      row = await ctx
          .table(Servico.fqtn)
          .where(Servico.idPublicoCol, Operator.equal, uuid)
          .first();
    }

    row ??= await ctx
        .table(Servico.fqtn)
        .where(Servico.codigoCol, Operator.equal, codigo)
        .first();

    if (row == null) {
      return null;
    }
    return Servico.fromMap(row);
  }

  Future<VersaoServico> _obterOuCriarVersaoRascunho(
    Connection ctx,
    int idServico,
    MetadadosServicoDto metadados,
    String? notas,
  ) async {
    final existente = await ctx
        .table(VersaoServico.fqtn)
        .where(VersaoServico.idServicoCol, Operator.equal, idServico)
        .where(
          VersaoServico.statusCol,
          Operator.equal,
          StatusVersaoServico.rascunho.val,
        )
        .orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc)
        .first();

    if (existente != null) {
      final versaoExistente = VersaoServico.fromMap(existente);
      final atualizada = VersaoServico(
        id: versaoExistente.id,
        idPublico: versaoExistente.idPublico,
        idServico: versaoExistente.idServico,
        numeroVersao: versaoExistente.numeroVersao,
        status: StatusVersaoServico.rascunho.val,
        notas: notas,
        snapshotMetadadosJson: jsonEncode(metadados.toMap()),
        criadoEm: versaoExistente.criadoEm,
        atualizadoEm: DateTime.now(),
      );
      await ctx
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idCol, Operator.equal, versaoExistente.id)
          .update(atualizada.toUpdateMap());
      final recarregada = await ctx
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idCol, Operator.equal, versaoExistente.id)
          .first();
      return VersaoServico.fromMap(recarregada!);
    }

    final ultimaVersao = await ctx
        .table(VersaoServico.fqtn)
        .where(VersaoServico.idServicoCol, Operator.equal, idServico)
        .orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc)
        .first();
    final proximaVersao = ultimaVersao == null
        ? 1
        : (ultimaVersao[VersaoServico.numeroVersaoCol] as int) + 1;
    final novaVersao = VersaoServico(
      id: 0,
      idServico: idServico,
      numeroVersao: proximaVersao,
      status: StatusVersaoServico.rascunho.val,
      notas: notas,
      snapshotMetadadosJson: jsonEncode(metadados.toMap()),
    );
    final idVersao = await ctx.table(VersaoServico.fqtn).insertGetId(
          novaVersao.toInsertMap(),
          VersaoServico.idCol,
        ) as int;
    final recarregada = await ctx
        .table(VersaoServico.fqtn)
        .where(VersaoServico.idCol, Operator.equal, idVersao)
        .first();
    return VersaoServico.fromMap(recarregada!);
  }

  Future<VersaoServico?> _buscarVersao(
    Connection ctx,
    int idServico,
    String idVersao,
  ) async {
    QueryBuilder criarQueryBase() {
      return ctx
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idServicoCol, Operator.equal, idServico);
    }

    final idPublico = IdentificadorBindingUtils.uuidOuNull(idVersao);
    final numeroVersao = IdentificadorBindingUtils.inteiroOuNull(idVersao);
    Map<String, dynamic>? row;

    if (idPublico != null) {
      final queryPorId = criarQueryBase();
      queryPorId.where(VersaoServico.idPublicoCol, Operator.equal, idPublico);
      queryPorId.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
      row = await queryPorId.first();
    }

    if (row == null && numeroVersao != null) {
      final queryPorNumero = criarQueryBase();
      queryPorNumero.where(
          VersaoServico.numeroVersaoCol, Operator.equal, numeroVersao);
      queryPorNumero.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
      row = await queryPorNumero.first();
    }

    if (row == null) {
      return null;
    }
    return VersaoServico.fromMap(row);
  }

  Future<void> _sincronizarCanais(
    Connection ctx,
    int idVersao,
    List<CanalServico> canais,
  ) async {
    await ctx
        .table(CanalVersaoServico.fqtn)
        .where(CanalVersaoServico.idVersaoServicoCol, Operator.equal, idVersao)
        .delete();

    for (final canal in canais) {
      final persistencia = CanalVersaoServico(
        id: 0,
        idVersaoServico: idVersao,
        canal: canal.val,
        visivel: true,
        configuracaoJson: '{}',
      );
      await ctx.table(CanalVersaoServico.fqtn).insert(
            persistencia.toInsertMap(),
          );
    }
  }

  Future<void> _sincronizarEtiquetas(
    Connection ctx,
    int idServico,
    List<String> etiquetas,
  ) async {
    await ctx
        .table(ServicoEtiqueta.fqtn)
        .where(ServicoEtiqueta.idServicoCol, Operator.equal, idServico)
        .delete();

    for (final codigoEtiqueta in etiquetas) {
      final idEtiqueta = await _obterOuCriarEtiqueta(ctx, codigoEtiqueta);
      final vinculo = ServicoEtiqueta(
        id: 0,
        idServico: idServico,
        idEtiqueta: idEtiqueta,
      );
      await ctx.table(ServicoEtiqueta.fqtn).insert(
            vinculo.toInsertMap(),
          );
    }
  }

  Future<int> _obterOuCriarEtiqueta(
      Connection ctx, String codigoEtiqueta) async {
    final existente = await ctx
        .table(EtiquetaServico.fqtn)
        .where(EtiquetaServico.codigoCol, Operator.equal, codigoEtiqueta)
        .first();
    if (existente != null) {
      return existente[EtiquetaServico.idCol] as int;
    }

    final etiqueta = EtiquetaServico(
      id: 0,
      codigo: codigoEtiqueta,
      nome: codigoEtiqueta,
    );
    return await ctx.table(EtiquetaServico.fqtn).insertGetId(
          etiqueta.toInsertMap(),
          EtiquetaServico.idCol,
        ) as int;
  }

  Future<void> _sincronizarFluxos(
    Connection ctx,
    int idVersao,
    List<FluxoDto> fluxos,
  ) async {
    final fluxosExistentes = await ctx
        .table(DefinicaoFluxo.fqtn)
        .select([DefinicaoFluxo.idCol])
        .where(DefinicaoFluxo.idVersaoServicoCol, Operator.equal, idVersao)
        .get();
    final idsFluxo = fluxosExistentes
        .map((row) => row[DefinicaoFluxo.idCol] as int)
        .toList(growable: false);

    if (idsFluxo.isNotEmpty) {
      final nosExistentes = await ctx
          .table(NoFluxo.fqtn)
          .select([NoFluxo.idCol])
          .whereIn(NoFluxo.idDefinicaoFluxoCol, idsFluxo)
          .get();
      final idsNos = nosExistentes
          .map((row) => row[NoFluxo.idCol] as int)
          .toList(growable: false);

      if (idsNos.isNotEmpty) {
        final secoesExistentes = await ctx
            .table(SecaoFormulario.fqtn)
            .select([SecaoFormulario.idCol])
            .whereIn(SecaoFormulario.idNoFluxoCol, idsNos)
            .get();
        final idsSecao = secoesExistentes
            .map((row) => row[SecaoFormulario.idCol] as int)
            .toList(growable: false);

        final camposExistentes = await ctx
            .table(CampoFormulario.fqtn)
            .select([CampoFormulario.idCol])
            .whereIn(CampoFormulario.idNoFluxoCol, idsNos)
            .get();
        final idsCampo = camposExistentes
            .map((row) => row[CampoFormulario.idCol] as int)
            .toList(growable: false);

        if (idsCampo.isNotEmpty) {
          await ctx
              .table(OpcaoCampo.fqtn)
              .whereIn(OpcaoCampo.idCampoCol, idsCampo)
              .delete();
          await ctx
              .table(ValidacaoCampo.fqtn)
              .whereIn(ValidacaoCampo.idCampoCol, idsCampo)
              .delete();
          await ctx
              .table(RegraVisibilidadeCampo.fqtn)
              .whereIn(RegraVisibilidadeCampo.idCampoCol, idsCampo)
              .delete();
          await ctx
              .table(CalculoCampo.fqtn)
              .whereIn(CalculoCampo.idCampoCol, idsCampo)
              .delete();
        }

        await ctx
            .table(CampoFormulario.fqtn)
            .whereIn(CampoFormulario.idNoFluxoCol, idsNos)
            .delete();

        if (idsSecao.isNotEmpty) {
          await ctx
              .table(SecaoFormulario.fqtn)
              .whereIn(SecaoFormulario.idCol, idsSecao)
              .delete();
        }
      }

      await ctx
          .table(ArestaFluxo.fqtn)
          .whereIn(ArestaFluxo.idDefinicaoFluxoCol, idsFluxo)
          .delete();
      await ctx
          .table(NoFluxo.fqtn)
          .whereIn(NoFluxo.idDefinicaoFluxoCol, idsFluxo)
          .delete();
      await ctx
          .table(DefinicaoFluxo.fqtn)
          .whereIn(DefinicaoFluxo.idCol, idsFluxo)
          .delete();
    }

    var indiceFluxo = 0;
    for (final fluxo in fluxos) {
      final fluxoPersistencia = DefinicaoFluxo(
        id: 0,
        idVersaoServico: idVersao,
        chaveFluxo: fluxo.chave,
        tipoFluxo: fluxo.tipo.val,
        titulo: fluxo.chave,
        pontoEntrada: indiceFluxo == 0,
      );
      final idFluxo = await ctx.table(DefinicaoFluxo.fqtn).insertGetId(
            fluxoPersistencia.toInsertMap(),
            DefinicaoFluxo.idCol,
          ) as int;

      final idsNosPorChave = <String, int>{};
      for (final no in fluxo.nos) {
        final dadosNo = no.dados.toMap();
        final noPersistencia = NoFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveNo: no.id,
          tipoNo: no.tipo.val,
          rotulo: dadosNo['rotulo']?.toString(),
          posicaoX: no.posicao.x,
          posicaoY: no.posicao.y,
          largura: no.largura,
          altura: no.altura,
          dadosJson: jsonEncode(dadosNo),
        );
        final idNo = await ctx.table(NoFluxo.fqtn).insertGetId(
              noPersistencia.toInsertMap(),
              NoFluxo.idCol,
            ) as int;
        idsNosPorChave[no.id] = idNo;

        if (no.tipo == TipoNoFluxo.formulario) {
          final dadosFormulario = no.dados as DadosNoFormulario;
          await _sincronizarCamposFormulario(
            ctx,
            idNo,
            dadosFormulario.secoes,
            dadosFormulario.perguntas,
          );
        }
      }

      for (final aresta in fluxo.arestas) {
        final arestaPersistencia = ArestaFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveAresta: aresta.id,
          idNoOrigem: idsNosPorChave[aresta.origem]!,
          idNoDestino: idsNosPorChave[aresta.destino]!,
          handleOrigem: aresta.handleOrigem,
          handleDestino: aresta.handleDestino,
          rotulo: aresta.rotulo,
        );
        await ctx.table(ArestaFluxo.fqtn).insert(
              arestaPersistencia.toInsertMap(),
            );
      }
      indiceFluxo++;
    }
  }

  Future<void> _sincronizarCamposFormulario(
    Connection ctx,
    int idNoFluxo,
    List<SecaoFormularioDto> secoes,
    List<DefinicaoPergunta> perguntas,
  ) async {
    final idsSecaoPorChave = <String, int>{};
    for (var indiceSecao = 0; indiceSecao < secoes.length; indiceSecao++) {
      final secao = secoes[indiceSecao];
      final secaoPersistencia = SecaoFormulario(
        id: 0,
        idNoFluxo: idNoFluxo,
        chaveSecao: secao.chave,
        titulo: secao.titulo,
        descricao: secao.descricao,
        ordem: secao.ordem,
        repetivel: secao.repetivel,
      );
      final idSecao = await ctx.table(SecaoFormulario.fqtn).insertGetId(
            secaoPersistencia.toInsertMap(),
            SecaoFormulario.idCol,
          ) as int;
      idsSecaoPorChave[secao.id] = idSecao;
      idsSecaoPorChave[secao.chave] = idSecao;
    }

    for (var indice = 0; indice < perguntas.length; indice++) {
      final pergunta = perguntas[indice];
      final campo = CampoFormulario(
        id: 0,
        idNoFluxo: idNoFluxo,
        idSecao: pergunta.idSecao == null
            ? null
            : idsSecaoPorChave[pergunta.idSecao!],
        chaveCampo: pergunta.campo,
        rotulo: pergunta.rotulo,
        tipoCampo: pergunta.tipo.val,
        descricao: pergunta.descricao,
        placeholder: pergunta.placeholder,
        mascara: pergunta.mascara,
        valorPadraoJson: pergunta.valorPadrao == null
            ? null
            : jsonEncode(pergunta.valorPadrao),
        origemDadosJson: jsonEncode(pergunta.origemDados),
        participaRanking: pergunta.participaRanking,
        obrigatorio: pergunta.obrigatorio,
        ordem: indice,
      );
      final idCampo = await ctx.table(CampoFormulario.fqtn).insertGetId(
            campo.toInsertMap(),
            CampoFormulario.idCol,
          ) as int;

      for (var indiceOpcao = 0;
          indiceOpcao < pergunta.opcoes.length;
          indiceOpcao++) {
        final opcao = pergunta.opcoes[indiceOpcao];
        await ctx.table(OpcaoCampo.fqtn).insert(
              OpcaoCampo(
                id: 0,
                idCampo: idCampo,
                valorOpcao: opcao.valor,
                rotuloOpcao: opcao.rotulo,
                ordem: opcao.ordem,
              ).toInsertMap(),
            );
      }

      for (final validacao in pergunta.validacoes) {
        await ctx.table(ValidacaoCampo.fqtn).insert(
              ValidacaoCampo(
                id: 0,
                idCampo: idCampo,
                tipoValidacao: validacao.tipo,
                configuracaoJson: jsonEncode(validacao.configuracao),
                mensagem: validacao.mensagem,
              ).toInsertMap(),
            );
      }

      for (final regra in pergunta.regrasVisibilidade) {
        await ctx.table(RegraVisibilidadeCampo.fqtn).insert(
              RegraVisibilidadeCampo(
                id: 0,
                idCampo: idCampo,
                expressaoJson: jsonEncode(regra.expressao),
              ).toInsertMap(),
            );
      }

      for (final calculo in pergunta.calculos) {
        await ctx.table(CalculoCampo.fqtn).insert(
              CalculoCampo(
                id: 0,
                idCampo: idCampo,
                expressaoJson: jsonEncode(calculo.expressao),
                escopoDestino: calculo.escopoDestino,
              ).toInsertMap(),
            );
      }
    }
  }
}
