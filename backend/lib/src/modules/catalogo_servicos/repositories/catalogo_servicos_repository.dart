import 'package:eloquent/eloquent.dart';
import 'package:essential_core/essential_core.dart';
import 'package:nexus_backend/src/shared/extensions/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/services/reconstrutor_formulario_persistido_service.dart';
import '../../../shared/utils/identificador_binding_utils.dart';
import '../../../shared/utils/json_utils.dart';

class CatalogoServicosRepository {
  final Connection db;
  final ReconstrutorFormularioPersistidoService
      _reconstrutorFormularioPersistidoService;

  CatalogoServicosRepository(
    this.db,
    this._reconstrutorFormularioPersistidoService,
  );

  Future<DataFrame<ResumoServico>> list() async {
    final servicosRows = await db
        .table(Servico.fqtn)
        .where(Servico.ativoCol, Operator.equal, true)
        .orderBy(Servico.nomeCol, OrderDir.asc)
        .get();

    if (servicosRows.isEmpty) {
      return DataFrame<ResumoServico>.newClear();
    }

    final servicos =
        servicosRows.map((row) => Servico.fromMap(row)).toList(growable: false);

    final categoriasPorId = await _carregarCategoriasPorIds(
      servicos
          .map((item) => item.idCategoria)
          .whereType<int>()
          .toSet()
          .toList(growable: false),
    );

    final idsServico = servicos.map((item) => item.id).toList(growable: false);

    final versoesPublicadasRows = await db
        .table(VersaoServico.fqtn)
        .whereIn(VersaoServico.idServicoCol, idsServico)
        .where(
          VersaoServico.statusCol,
          Operator.equal,
          StatusVersaoServico.publicada.val,
        )
        .get();

    final versoesPublicadas = versoesPublicadasRows
        .map((row) => VersaoServico.fromMap(row))
        .toList(growable: false);

    final versaoPorServico = <int, VersaoServico>{};
    for (final versao in versoesPublicadas) {
      versaoPorServico[versao.idServico] = versao;
    }

    final canaisPorVersao = await _carregarCanaisPorVersao(
      versoesPublicadas.map((item) => item.id).toList(growable: false),
    );

    final itens = servicos.map((servico) {
      final versao = versaoPorServico[servico.id];
      final idVersaoPk = versao?.id;
      final canais = idVersaoPk == null
          ? const <CanalServico>[]
          : (canaisPorVersao[idVersaoPk] ?? const <CanalServico>[]);
      final categoria = categoriasPorId[servico.idCategoria];

      return ResumoServico(
        id: servico.idPublico ?? '',
        codigo: servico.codigo,
        nome: servico.nome,
        descricao: servico.descricao,
        categoria: categoria?.codigo ?? 'geral',
        modoAcesso: ModoAcesso.parse(servico.modoAcesso),
        canais: canais,
        versaoPublicada: versao?.numeroVersao,
      );
    }).toList(growable: false);

    return DataFrame<ResumoServico>(
      items: itens,
      totalRecords: itens.length,
    );
  }

  Future<ServicoDto?> findById(String id) async {
    final servico = await _buscarServico(id);
    if (servico == null) {
      return null;
    }
    final categoria = servico.idCategoria == null
        ? null
        : await _buscarCategoriaPorId(servico.idCategoria!);

    return ServicoDto(
      id: servico.idPublico ?? '',
      codigo: servico.codigo,
      metadados: await _carregarMetadadosServico(servico, categoria),
      versoes: await _carregarVersoes(servico.id, incluirFluxos: true),
      criadoEm: servico.criadoEm ?? DateTime.now(),
      atualizadoEm: servico.atualizadoEm ?? servico.criadoEm ?? DateTime.now(),
    );
  }

  Future<DataFrame<ResumoVersaoServico>> listVersoes(String idServico) async {
    final servico = await _buscarServico(idServico);
    if (servico == null) {
      return DataFrame<ResumoVersaoServico>.newClear();
    }

    final versoes = await _carregarVersoes(servico.id, incluirFluxos: false);
    final itens = versoes
        .map(
          (item) => ResumoVersaoServico(
            id: item.id,
            versao: item.versao,
            status: item.status,
            quantidadeFluxos: item.fluxos.length,
            criadoEm: item.criadoEm,
            notas: item.notas,
          ),
        )
        .toList(growable: false);

    return DataFrame<ResumoVersaoServico>(
      items: itens,
      totalRecords: itens.length,
    );
  }

  Future<DataFrame<FluxoDto>> listFluxos(String idServico,
      {String? idVersao}) async {
    final servico = await _buscarServico(idServico);
    if (servico == null) {
      return DataFrame<FluxoDto>.newClear();
    }

    final versao = await _buscarVersaoServico(servico.id, idVersao);
    if (versao == null) {
      return DataFrame<FluxoDto>.newClear();
    }

    final itens = await _carregarFluxos(versao.id);
    return DataFrame<FluxoDto>(
      items: itens,
      totalRecords: itens.length,
    );
  }

  Future<Servico?> _buscarServico(String id) async {
    Map<String, dynamic>? row;
    final idPublico = IdentificadorBindingUtils.uuidOuNull(id);
    if (idPublico != null) {
      row = await db
          .table(Servico.fqtn)
          .where(Servico.idPublicoCol, Operator.equal, idPublico)
          .first();
    }

    row ??= await db
        .table(Servico.fqtn)
        .where(Servico.codigoCol, Operator.equal, id)
        .first();

    if (row == null) {
      return null;
    }

    return Servico.fromMap(row);
  }

  Future<VersaoServico?> _buscarVersaoServico(
      int idServicoPk, String? idVersao) async {
    QueryBuilder criarQueryBase() {
      return db
          .table(VersaoServico.fqtn)
          .where(VersaoServico.idServicoCol, Operator.equal, idServicoPk);
    }

    if (idVersao != null && idVersao.isNotEmpty) {
      final idPublico = IdentificadorBindingUtils.uuidOuNull(idVersao);
      final numeroVersao = IdentificadorBindingUtils.inteiroOuNull(idVersao);
      Map<String, dynamic>? row;

      if (idPublico != null) {
        final queryPorId = criarQueryBase();
        queryPorId.where(
          VersaoServico.idPublicoCol,
          Operator.equal,
          idPublico,
        );
        queryPorId.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
        row = await queryPorId.first();
      }

      if (row == null && numeroVersao != null) {
        final queryPorNumero = criarQueryBase();
        queryPorNumero.where(
          VersaoServico.numeroVersaoCol,
          Operator.equal,
          numeroVersao,
        );
        queryPorNumero.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
        row = await queryPorNumero.first();
      }

      if (row == null) {
        return null;
      }
      return VersaoServico.fromMap(row);
    } else {
      final query = criarQueryBase();
      query.where(
        VersaoServico.statusCol,
        Operator.equal,
        StatusVersaoServico.publicada.val,
      );
      query.orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc);
      final row = await query.first();
      if (row == null) {
        return null;
      }
      return VersaoServico.fromMap(row);
    }
  }

  Future<MetadadosServicoDto> _carregarMetadadosServico(
    Servico servico,
    CategoriaServico? categoria,
  ) async {
    final idServicoPk = servico.id;
    final versaoPublicada = await _buscarVersaoServico(idServicoPk, null);
    final canais = await _carregarCanaisDaVersao(versaoPublicada?.id);

    final etiquetas = await _carregarEtiquetasPorServico(idServicoPk);

    return MetadadosServicoDto(
      nome: servico.nome,
      descricao: servico.descricao,
      categoria: categoria?.codigo ?? 'geral',
      canais: canais,
      modoAcesso: ModoAcesso.parse(servico.modoAcesso),
      responsavelServico: servico.responsavelServico,
      exibirResponsavelServico: servico.exibirResponsavelServico,
      etiquetas: etiquetas.map((item) => item.codigo).toList(growable: false),
    );
  }

  Future<List<CanalServico>> _carregarCanaisDaVersao(int? idVersaoPk) async {
    if (idVersaoPk == null) {
      return const <CanalServico>[];
    }

    final canaisPorVersao = await _carregarCanaisPorVersao([idVersaoPk]);
    return canaisPorVersao[idVersaoPk] ?? const <CanalServico>[];
  }

  Future<List<VersaoServicoDto>> _carregarVersoes(
    int idServicoPk, {
    required bool incluirFluxos,
  }) async {
    final rows = await db
        .table(VersaoServico.fqtn)
        .where(VersaoServico.idServicoCol, Operator.equal, idServicoPk)
        .orderBy(VersaoServico.numeroVersaoCol, OrderDir.desc)
        .get();
    final versoes =
        rows.map((row) => VersaoServico.fromMap(row)).toList(growable: false);

    final fluxosPorVersao = <int, List<FluxoDto>>{};
    if (incluirFluxos) {
      for (final versao in versoes) {
        fluxosPorVersao[versao.id] = await _carregarFluxos(versao.id);
      }
    }

    return versoes
        .map(
          (versao) => VersaoServicoDto(
            id: versao.idPublico ?? '',
            versao: versao.numeroVersao,
            status: StatusVersaoServico.parse(versao.status),
            criadoEm: versao.criadoEm ?? DateTime.now(),
            fluxos: incluirFluxos
                ? (fluxosPorVersao[versao.id] ?? const <FluxoDto>[])
                : const <FluxoDto>[],
            notas: versao.notas,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, CategoriaServico>> _carregarCategoriasPorIds(
      List<int> ids) async {
    if (ids.isEmpty) {
      return const <int, CategoriaServico>{};
    }

    final rows = await db
        .table(CategoriaServico.fqtn)
        .whereIn(CategoriaServico.idCol, ids)
        .get();

    final mapa = <int, CategoriaServico>{};
    for (final row in rows) {
      final categoria = CategoriaServico.fromMap(row);
      mapa[categoria.id] = categoria;
    }
    return mapa;
  }

  Future<CategoriaServico?> _buscarCategoriaPorId(int idCategoria) async {
    final row = await db
        .table(CategoriaServico.fqtn)
        .where(CategoriaServico.idCol, Operator.equal, idCategoria)
        .first();

    if (row == null) {
      return null;
    }

    return CategoriaServico.fromMap(row);
  }

  Future<List<EtiquetaServico>> _carregarEtiquetasPorServico(
      int idServicoPk) async {
    final vinculos = await db
        .table(ServicoEtiqueta.fqtn)
        .where(ServicoEtiqueta.idServicoCol, Operator.equal, idServicoPk)
        .get();

    if (vinculos.isEmpty) {
      return const <EtiquetaServico>[];
    }

    final idsEtiquetas = vinculos
        .map((row) => ServicoEtiqueta.fromMap(row).idEtiqueta)
        .toList(growable: false);

    final etiquetasRows = await db
        .table(EtiquetaServico.fqtn)
        .whereIn(EtiquetaServico.idCol, idsEtiquetas)
        .orderBy(EtiquetaServico.codigoCol, OrderDir.asc)
        .get();

    return etiquetasRows
        .map((row) => EtiquetaServico.fromMap(row))
        .toList(growable: false);
  }

  Future<Map<int, List<CanalServico>>> _carregarCanaisPorVersao(
      List<int> idsVersao) async {
    if (idsVersao.isEmpty) {
      return const <int, List<CanalServico>>{};
    }

    final rows = await db
        .table(CanalVersaoServico.fqtn)
        .whereIn(CanalVersaoServico.idVersaoServicoCol, idsVersao)
        .where(CanalVersaoServico.visivelCol, Operator.equal, true)
        .orderBy(CanalVersaoServico.canalCol, OrderDir.asc)
        .get();

    final mapa = <int, List<CanalServico>>{};
    for (final row in rows) {
      final canalPersistencia = CanalVersaoServico.fromMap(row);
      final idVersao = canalPersistencia.idVersaoServico;
      mapa.putIfAbsent(idVersao, () => <CanalServico>[]).add(
            CanalServico.parse(canalPersistencia.canal),
          );
    }
    return mapa;
  }

  Future<List<FluxoDto>> _carregarFluxos(int idVersaoPk) async {
    final rows = await db
        .table(DefinicaoFluxo.fqtn)
        .select([
          DefinicaoFluxo.idFqCol,
          DefinicaoFluxo.idPublicoFqCol,
          DefinicaoFluxo.chaveFluxoFqCol,
          DefinicaoFluxo.tipoFluxoFqCol,
        ])
        .where(DefinicaoFluxo.idVersaoServicoFqCol, Operator.equal, idVersaoPk)
        .orderBy('criado_em', OrderDir.asc)
        .get();

    final fluxos = <FluxoDto>[];
    for (final row in rows) {
      final idFluxoPk = row['id'] as int;
      fluxos.add(
        FluxoDto(
          id: row[DefinicaoFluxo.idPublicoCol].toString(),
          chave: row['chave_fluxo'] as String,
          tipo: TipoFluxo.parse(row['tipo_fluxo'] as String),
          nos: await _carregarNos(idFluxoPk),
          arestas: await _carregarArestas(idFluxoPk),
        ),
      );
    }
    return fluxos;
  }

  Future<List<NoFluxoDto>> _carregarNos(int idFluxoPk) async {
    final rows = await db
        .table(NoFluxo.fqtn)
        .select([
          NoFluxo.idCol,
          NoFluxo.chaveNoCol,
          NoFluxo.tipoNoCol,
          NoFluxo.rotuloCol,
          NoFluxo.posicaoXCol,
          NoFluxo.posicaoYCol,
          NoFluxo.larguraCol,
          NoFluxo.alturaCol,
          NoFluxo.dadosJsonCol,
        ])
        .where(NoFluxo.idDefinicaoFluxoCol, Operator.equal, idFluxoPk)
        .orderBy('criado_em', OrderDir.asc)
        .get();

    final idsNosFormulario = <int>[];
    final dadosBasePorNo = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      final tipo = TipoNoFluxo.parseBanco(row['tipo_no'] as String);
      if (tipo != TipoNoFluxo.formulario) {
        continue;
      }

      final idNo = row[NoFluxo.idCol] as int;
      final dadosBase = JsonUtils.lerMapa(row['dados_json']);
      if (dadosBase['rotulo'] == null && row[NoFluxo.rotuloCol] != null) {
        dadosBase['rotulo'] = row[NoFluxo.rotuloCol].toString();
      }
      idsNosFormulario.add(idNo);
      dadosBasePorNo[idNo] = dadosBase;
    }

    final formulariosPorNo =
        await _reconstrutorFormularioPersistidoService.carregarPorIdsNos(
      idsNosFormulario,
      dadosBasePorNo: dadosBasePorNo,
    );

    return rows.map((row) {
      final tipo = TipoNoFluxo.parseBanco(row['tipo_no'] as String);
      final idNo = row[NoFluxo.idCol] as int;

      return NoFluxoDto(
        id: row['chave_no'] as String,
        tipo: tipo,
        posicao: PosicaoXY(
          x: (row['posicao_x'] as num).toDouble(),
          y: (row['posicao_y'] as num).toDouble(),
        ),
        dados: tipo == TipoNoFluxo.formulario
            ? (formulariosPorNo[idNo] ??
                DadosNoFormulario(
                  rotulo: row[NoFluxo.rotuloCol]?.toString() ?? 'Formulario',
                ))
            : dadosNoFluxoFromMap(
                tipo: tipo, mapa: JsonUtils.lerMapa(row['dados_json'])),
        largura:
            row['largura'] != null ? (row['largura'] as num).toDouble() : null,
        altura:
            row['altura'] != null ? (row['altura'] as num).toDouble() : null,
      );
    }).toList(growable: false);
  }

  Future<List<ArestaFluxoDto>> _carregarArestas(int idFluxoPk) async {
    final rows = await db
        .table(ArestaFluxo.fqtn)
        .select([
          ArestaFluxo.chaveArestaFqCol,
          ArestaFluxo.handleOrigemFqCol,
          ArestaFluxo.handleDestinoFqCol,
          ArestaFluxo.rotuloFqCol,
          'origem.${NoFluxo.chaveNoCol} as chave_origem',
          'destino.${NoFluxo.chaveNoCol} as chave_destino',
        ])
        .join(
          '${NoFluxo.fqtn} as origem',
          'origem.${NoFluxo.idCol}',
          '=',
          '${ArestaFluxo.fqtn}.${ArestaFluxo.idNoOrigemCol}',
        )
        .join(
          '${NoFluxo.fqtn} as destino',
          'destino.${NoFluxo.idCol}',
          '=',
          '${ArestaFluxo.fqtn}.${ArestaFluxo.idNoDestinoCol}',
        )
        .where('${ArestaFluxo.fqtn}.${ArestaFluxo.idDefinicaoFluxoCol}',
            Operator.equal, idFluxoPk)
        .orderBy('${ArestaFluxo.fqtn}.criado_em', OrderDir.asc)
        .get();

    return rows
        .map(
          (row) => ArestaFluxoDto(
            id: row['chave_aresta'] as String,
            origem: row['chave_origem'] as String,
            destino: row['chave_destino'] as String,
            handleOrigem: row['handle_origem'] as String?,
            handleDestino: row['handle_destino'] as String?,
            rotulo: row['rotulo'] as String?,
          ),
        )
        .toList(growable: false);
  }
}
