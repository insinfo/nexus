import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:nexus_backend/src/modules/consulta_protocolos/consulta_protocolos_routes.dart';
import 'package:nexus_backend/src/modules/consulta_protocolos/services/consulta_protocolos_port.dart';
import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Rotas de consulta publica de protocolos', () {
    test('consulta protocolo por numero ou codigo publico', () async {
      final ioc = GetIt.asNewInstance();
      ioc.registerSingleton<ConsultaProtocolosPort>(
          _ConsultaProtocolosPortFake());

      final resposta = await consultaProtocolosRoutes().call(
        Request(
          'GET',
          Uri.parse('http://localhost/protocolos/202603220001'),
          context: <String, Object>{'ioc': ioc},
        ),
      );

      expect(resposta.statusCode, equals(200));
      final corpo =
          jsonDecode(await resposta.readAsString()) as Map<String, dynamic>;
      expect(corpo['numero_protocolo'], equals('202603220001'));
      expect(corpo['codigo_publico'], equals('NEXUS-ABC-123'));
      expect(corpo['nome_servico'], equals('Auxilio emergencial'));
      expect(corpo['descricao_status'], isNotEmpty);
      expect((corpo['respostas_resumo'] as List).length, equals(2));
      expect((corpo['andamentos'] as List).length, equals(3));
    });
  });
}

class _ConsultaProtocolosPortFake implements ConsultaProtocolosPort {
  @override
  Future<ConsultaPublicaProtocolo?> buscarPorCodigo(String codigo) async {
    return ConsultaPublicaProtocolo(
      idSubmissao: 'submissao-1',
      idServico: 'servico-1',
      codigoServico: 'SALUS-AUXILIO',
      nomeServico: 'Auxilio emergencial',
      idVersaoServico: 'versao-1',
      numeroVersaoServico: 2,
      numeroProtocolo: '202603220001',
      codigoPublico: 'NEXUS-ABC-123',
      status: 'submetida',
      descricaoStatus:
          'O protocolo foi recebido e aguarda o proximo tratamento interno.',
      criadoEm: DateTime.utc(2026, 3, 22, 14),
      totalRespostas: 2,
      snapshot: const <String, dynamic>{
        'respostas': <String, dynamic>{'cpf': '00000000000'}
      },
      respostasResumo: <ResumoRespostaProtocolo>[
        ResumoRespostaProtocolo(
            chave: 'cpf', rotulo: 'Cpf', valor: '00000000000'),
        ResumoRespostaProtocolo(chave: 'nome', rotulo: 'Nome', valor: 'Maria'),
      ],
      andamentos: <AndamentoConsultaPublicaProtocolo>[
        AndamentoConsultaPublicaProtocolo(
          titulo: 'Solicitacao recebida',
          descricao: 'Protocolo gerado com sucesso.',
          situacao: 'concluida',
          data: DateTime.utc(2026, 3, 22, 14),
        ),
        AndamentoConsultaPublicaProtocolo(
          titulo: 'Analise administrativa',
          descricao: 'Em fila para triagem.',
          situacao: 'atual',
        ),
        AndamentoConsultaPublicaProtocolo(
          titulo: 'Resultado e retorno',
          descricao: 'Aguardando conclusao do fluxo.',
          situacao: 'pendente',
        ),
      ],
    );
  }
}
