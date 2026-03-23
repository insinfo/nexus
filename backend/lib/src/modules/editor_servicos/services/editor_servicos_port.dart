import 'package:nexus_core/nexus_core.dart';

abstract class EditorServicosPort {
  Future<ServicoDto> salvarRascunho(
    RequisicaoSalvarRascunhoServico requisicao,
  );

  Future<ServicoDto> publicarVersao(
    RequisicaoPublicarVersaoServico requisicao,
  );
}
