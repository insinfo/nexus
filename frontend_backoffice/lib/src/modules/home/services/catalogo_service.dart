import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

/// Service HTTP para o catálogo de serviços do Nexus.
class CatalogoService extends RestServiceBase {
  CatalogoService(RestConfig conf) : super(conf);

  String path = '/servicos';

  Future<DataFrame<ResumoServico>> listServicos(Filters filtros) async {
    return await getDataFrame<ResumoServico>(
      path,
      builder: ResumoServico.fromMap,
      filtros: filtros,
    );
  }

  Future<ServicoDto> findById(String id) async {
    return await getEntity<ServicoDto>(
      '$path/$id',
      builder: ServicoDto.fromMap,
    );
  }

  Future<DataFrame<ResumoVersaoServico>> listVersoes(
    String servicoId,
    Filters filtros,
  ) async {
    return await getDataFrame<ResumoVersaoServico>(
      '$path/$servicoId/versoes',
      builder: ResumoVersaoServico.fromMap,
      filtros: filtros,
    );
  }
}
