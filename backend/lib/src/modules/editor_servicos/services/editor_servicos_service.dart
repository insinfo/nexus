import 'package:nexus_core/nexus_core.dart';

import '../../catalogo_servicos/repositories/catalogo_servicos_repository.dart';
import '../../editor_fluxos/services/validador_fluxo_service.dart';
import '../repositories/editor_servicos_repository.dart';
import 'editor_servicos_port.dart';
import 'servico_rascunho_invalido_exception.dart';

class EditorServicosService implements EditorServicosPort {
  EditorServicosService(
    this._editorServicosRepository,
    this._catalogoServicosRepository,
    this._validadorFluxoService,
  );

  final EditorServicosRepository _editorServicosRepository;
  final CatalogoServicosRepository _catalogoServicosRepository;
  final ValidadorFluxoService _validadorFluxoService;

  @override
  Future<ServicoDto> salvarRascunho(
    RequisicaoSalvarRascunhoServico requisicao,
  ) async {
    final versaoOrigem = _resolverVersaoOrigem(requisicao);
    final errosFluxos = <Map<String, dynamic>>[];

    for (final fluxo in versaoOrigem.fluxos) {
      final resultado = _validadorFluxoService.validar(fluxo);
      if (!resultado.valido) {
        errosFluxos.add(<String, dynamic>{
          'id_fluxo': fluxo.id,
          'chave_fluxo': fluxo.chave,
          'erros': resultado.toMap()['erros'],
        });
      }
    }

    if (errosFluxos.isNotEmpty) {
      throw ServicoRascunhoInvalidoException(errosFluxos);
    }

    final idServico = await _editorServicosRepository.saveRascunho(
      servico: requisicao.servico,
      versaoOrigem: versaoOrigem,
    );

    final atualizado = await _catalogoServicosRepository.findById(idServico);
    if (atualizado == null) {
      throw StateError(
          'Servico salvo mas nao encontrado para recarga: $idServico');
    }
    return atualizado;
  }

  @override
  Future<ServicoDto> publicarVersao(
    RequisicaoPublicarVersaoServico requisicao,
  ) async {
    final idServico = await _editorServicosRepository.publishVersao(
      idServico: requisicao.idServico,
      idVersao: requisicao.idVersao,
    );
    final atualizado = await _catalogoServicosRepository.findById(idServico);
    if (atualizado == null) {
      throw StateError(
          'Servico publicado mas nao encontrado para recarga: $idServico');
    }
    return atualizado;
  }

  VersaoServicoDto _resolverVersaoOrigem(
    RequisicaoSalvarRascunhoServico requisicao,
  ) {
    if (requisicao.servico.versoes.isEmpty) {
      throw StateError(
          'O servico enviado nao possui versoes para salvar em rascunho.');
    }

    if (requisicao.idVersao != null && requisicao.idVersao!.isNotEmpty) {
      for (final versao in requisicao.servico.versoes) {
        if (versao.id == requisicao.idVersao) {
          return versao;
        }
      }
    }

    for (final versao in requisicao.servico.versoes) {
      if (versao.status == StatusVersaoServico.rascunho) {
        return versao;
      }
    }

    return requisicao.servico.versoes.first;
  }
}
