import 'package:eloquent/eloquent.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';
import '../../../shared/utils/json_utils.dart';

class ConsultaProtocolosRepository {
  ConsultaProtocolosRepository(this.db);

  final Connection db;

  Future<ConsultaPublicaProtocolo?> findByCodigo(String codigo) async {
    QueryBuilder criarQueryBase() {
      return db
          .table(Protocolo.fqtn)
          .select([
            '${Submissao.fqtn}.${Submissao.idPublicoCol} as id_submissao_publico',
            '${Servico.fqtn}.${Servico.idPublicoCol} as id_servico_publico',
            Servico.codigoFqCol,
            Servico.nomeFqCol,
            '${VersaoServico.fqtn}.${VersaoServico.idPublicoCol} as id_versao_servico_publico',
            VersaoServico.numeroVersaoFqCol,
            Protocolo.numeroProtocoloFqCol,
            Protocolo.codigoPublicoFqCol,
            Submissao.statusFqCol,
            '${Protocolo.fqtn}.criado_em',
            Submissao.snapshotJsonFqCol,
          ])
          .join(
            Submissao.fqtn,
            Submissao.idFqCol,
            '=',
            Protocolo.idSubmissaoFqCol,
          )
          .join(
            Servico.fqtn,
            Servico.idFqCol,
            '=',
            Submissao.idServicoFqCol,
          )
          .join(
            VersaoServico.fqtn,
            VersaoServico.idFqCol,
            '=',
            Submissao.idVersaoServicoFqCol,
          );
    }

    var query = criarQueryBase();
    query.where(Protocolo.numeroProtocoloCol, Operator.equal, codigo);
    Map<String, dynamic>? row = await query.first();

    if (row == null) {
      query = criarQueryBase();
      query.where(Protocolo.codigoPublicoCol, Operator.equal, codigo);
      row = await query.first();
    }

    if (row == null) {
      return null;
    }

    final criadoEm = row['criado_em'] is DateTime
        ? row['criado_em'] as DateTime
        : DateTime.tryParse(row['criado_em'].toString()) ?? DateTime.now();
    final snapshot = JsonUtils.lerMapa(row[Submissao.snapshotJsonCol]);
    final status = row[Submissao.statusCol] as String;

    return ConsultaPublicaProtocolo(
      idSubmissao: row['id_submissao_publico'].toString(),
      idServico: row['id_servico_publico'].toString(),
      codigoServico: row[Servico.codigoCol] as String,
      nomeServico: row[Servico.nomeCol] as String,
      idVersaoServico: row['id_versao_servico_publico'].toString(),
      numeroVersaoServico: row[VersaoServico.numeroVersaoCol] as int,
      numeroProtocolo: row[Protocolo.numeroProtocoloCol] as String,
      codigoPublico: row[Protocolo.codigoPublicoCol] as String,
      status: status,
      descricaoStatus: _descricaoStatus(status),
      criadoEm: criadoEm,
      totalRespostas: _contarRespostas(snapshot),
      snapshot: snapshot,
      respostasResumo: _montarResumoRespostas(snapshot),
      andamentos: _montarAndamentos(status: status, criadoEm: criadoEm),
    );
  }

  List<AndamentoConsultaPublicaProtocolo> _montarAndamentos({
    required String status,
    required DateTime criadoEm,
  }) {
    final statusNormalizado = status.toLowerCase();
    final emAnalise = _statusEmAnalise(statusNormalizado);
    final concluido = _statusConcluido(statusNormalizado);

    return <AndamentoConsultaPublicaProtocolo>[
      AndamentoConsultaPublicaProtocolo(
        titulo: 'Solicitacao recebida',
        descricao:
            'O protocolo foi gerado e a solicitacao entrou na fila institucional.',
        situacao: 'concluida',
        data: criadoEm,
      ),
      AndamentoConsultaPublicaProtocolo(
        titulo: 'Analise administrativa',
        descricao:
            'A equipe responsavel esta conferindo documentos, criterios e consistencia do envio.',
        situacao: concluido
            ? 'concluida'
            : emAnalise
                ? 'atual'
                : 'pendente',
      ),
      AndamentoConsultaPublicaProtocolo(
        titulo: 'Resultado e retorno',
        descricao:
            'A fase final consolida o parecer, a classificacao e o retorno consultavel no portal.',
        situacao: concluido ? 'concluida' : 'pendente',
      ),
    ];
  }

  List<ResumoRespostaProtocolo> _montarResumoRespostas(
      Map<String, dynamic> snapshot) {
    final respostas = JsonUtils.lerMapa(snapshot['respostas']);
    final itens = <ResumoRespostaProtocolo>[];
    _coletarResumoRespostas(prefixo: '', valor: respostas, itens: itens);
    return itens.take(8).toList(growable: false);
  }

  void _coletarResumoRespostas({
    required String prefixo,
    required dynamic valor,
    required List<ResumoRespostaProtocolo> itens,
  }) {
    if (valor is Map) {
      final mapa = valor.cast<Object?, Object?>();
      for (final entry in mapa.entries) {
        final chaveAtual = entry.key.toString();
        final proximoPrefixo =
            prefixo.isEmpty ? chaveAtual : '$prefixo.$chaveAtual';
        _coletarResumoRespostas(
          prefixo: proximoPrefixo,
          valor: entry.value,
          itens: itens,
        );
      }
      return;
    }

    if (valor is List) {
      itens.add(
        ResumoRespostaProtocolo(
          chave: prefixo,
          rotulo: _humanizarChave(prefixo),
          valor: valor.join(', '),
        ),
      );
      return;
    }

    if (prefixo.isEmpty || valor == null) {
      return;
    }

    itens.add(
      ResumoRespostaProtocolo(
        chave: prefixo,
        rotulo: _humanizarChave(prefixo),
        valor: valor.toString(),
      ),
    );
  }

  int _contarRespostas(Map<String, dynamic> snapshot) {
    final respostas = JsonUtils.lerMapa(snapshot['respostas']);
    final itens = <ResumoRespostaProtocolo>[];
    _coletarResumoRespostas(prefixo: '', valor: respostas, itens: itens);
    return itens.length;
  }

  String _descricaoStatus(String status) {
    if (_statusConcluido(status.toLowerCase())) {
      return 'A solicitacao ja passou pelo fluxo principal e possui retorno consolidado.';
    }
    if (_statusEmAnalise(status.toLowerCase())) {
      return 'O protocolo esta em analise pela equipe responsavel.';
    }
    return 'O protocolo foi recebido e aguarda o proximo tratamento interno.';
  }

  bool _statusEmAnalise(String status) {
    return status.contains('analise') ||
        status.contains('triagem') ||
        status.contains('avali');
  }

  bool _statusConcluido(String status) {
    return status.contains('conclu') ||
        status.contains('defer') ||
        status.contains('indefer') ||
        status.contains('homolog') ||
        status.contains('finaliz');
  }

  String _humanizarChave(String chave) {
    final semPrefixo = chave.split('.').last;
    final comEspacos = semPrefixo.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return comEspacos
        .split('_')
        .expand((parte) => parte.split(' '))
        .where((parte) => parte.isNotEmpty)
        .map((parte) => '${parte[0].toUpperCase()}${parte.substring(1)}')
        .join(' ');
  }
}
