import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Service HTTP para o builder de fluxos do Nexus.
class BuilderService extends RestServiceBase {
  BuilderService(RestConfig conf) : super(conf);

  String pathServicos = '/servicos';
  String pathEditor = '/editor';

  Future<ServicoDto> findServico(String servicoId) async {
    return await getEntity<ServicoDto>(
      '$pathServicos/$servicoId',
      builder: ServicoDto.fromMap,
    );
  }

  Future<DataFrame<ResumoVersaoServico>> listVersoes(
    String servicoId,
    Filters filtros,
  ) async {
    return await getDataFrame<ResumoVersaoServico>(
      '$pathServicos/$servicoId/versoes',
      builder: ResumoVersaoServico.fromMap,
      filtros: filtros,
    );
  }

  Future<ResultadoValidacaoFluxo> validarFluxo(FluxoDto fluxo) async {
    final jsonMap = await postEntity(
      fluxo.toMap(),
      '$pathEditor/validar-fluxo',
    );
    return ResultadoValidacaoFluxo.fromMap(
      Map<String, dynamic>.from(jsonMap as Map),
    );
  }

  Future<ResultadoPreVisualizacaoFluxo> preVisualizarFluxo({
    required FluxoDto fluxo,
    required Map<String, dynamic> contexto,
    required Map<String, dynamic> respostas,
  }) async {
    final jsonMap = await postEntity(
      <String, dynamic>{
        'fluxo': fluxo.toMap(),
        'contexto': contexto,
        'respostas': respostas,
      },
      '$pathEditor/pre-visualizar-fluxo',
    );
    return ResultadoPreVisualizacaoFluxo.fromMap(
      Map<String, dynamic>.from(jsonMap as Map),
    );
  }

  Future<void> salvarRascunho(ServicoDto servico) async {
    await postEntity(
      servico.toMap(),
      '$pathEditor/servicos/salvar-rascunho',
    );
  }

  Future<void> publicarVersao({
    required String servicoId,
    required String versaoId,
  }) async {
    await postEntity(
      <String, dynamic>{},
      '$pathEditor/servicos/$servicoId/versoes/$versaoId/publicar',
    );
  }
}
