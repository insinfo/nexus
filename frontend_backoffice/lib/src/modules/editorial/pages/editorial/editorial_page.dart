import 'dart:convert';
import 'dart:html';

import 'package:nexus_core/nexus_core.dart';
import 'package:nexus_frontend_backoffice/nexus_frontend_backoffice.dart';

@Component(
  selector: 'editorial-page',
  templateUrl: 'editorial_page.html',
  styleUrls: <String>['editorial_page.css'],
  directives: <Object>[coreDirectives],
)
class EditorialPage implements OnInit {

  Iterable<TipoPublicacao> get tiposPublicacaoDisponiveis => TipoPublicacao.values;
  Iterable<StatusPublicacao> get statusPublicacaoDisponiveis => StatusPublicacao.values;

  DateTime parseDateTime(String? val) {
    if (val == null || val.isEmpty) return DateTime.now();
    return DateTime.tryParse(val) ?? DateTime.now();
  }

  TipoPublicacao parseTipoPublicacao(String? val) {
    if (val == null || val.isEmpty) return TipoPublicacao.editalPublico;
    return TipoPublicacao.tryParse(val) ?? TipoPublicacao.editalPublico;
  }

  StatusPublicacao parseStatusPublicacao(String? val) {
    if (val == null || val.isEmpty) return StatusPublicacao.rascunho;
    return StatusPublicacao.tryParse(val) ?? StatusPublicacao.rascunho;
  }

  EditorialPage();

  static const String _apiBaseUrl = 'http://127.0.0.1:8086/api/v1/editorial';

  String abaAtual = 'noticias';
  bool carregando = false;
  bool salvando = false;
  String? erro;
  String? mensagem;
  List<Noticia> noticias = <Noticia>[];
  List<PublicacaoOficial> publicacoes = <PublicacaoOficial>[];
  List<PaginaInstitucional> paginas = <PaginaInstitucional>[];
  Noticia noticiaEmEdicao = _novaNoticia();
  PublicacaoOficial publicacaoEmEdicao = _novaPublicacao();
  PaginaInstitucional paginaEmEdicao = _novaPagina();

  bool get abaNoticiasAtiva => abaAtual == 'noticias';

  bool get abaPublicacoesAtiva => abaAtual == 'publicacoes';

  bool get abaPaginasAtiva => abaAtual == 'paginas';

  bool get editandoNoticia => _temIdPersistido(noticiaEmEdicao.id);

  bool get editandoPublicacao => _temIdPersistido(publicacaoEmEdicao.id);

  bool get editandoPagina => _temIdPersistido(paginaEmEdicao.id);

  @override
  Future<void> ngOnInit() async {
    await carregarDados();
  }

  Future<void> carregarDados() async {
    carregando = true;
    erro = null;

    try {
      final respostas = await Future.wait<String>(<Future<String>>[
        HttpRequest.getString('$_apiBaseUrl/noticias'),
        HttpRequest.getString('$_apiBaseUrl/publicacoes-oficiais'),
        HttpRequest.getString('$_apiBaseUrl/paginas-institucionais'),
      ]);

      noticias = _lerDataFrame<Noticia>(respostas[0], Noticia.fromMap);
      publicacoes = _lerDataFrame<PublicacaoOficial>(
        respostas[1],
        PublicacaoOficial.fromMap,
      );
      paginas = _lerDataFrame<PaginaInstitucional>(
        respostas[2],
        PaginaInstitucional.fromMap,
      );
    } catch (_) {
      erro = 'Nao foi possivel carregar o modulo editorial.';
    } finally {
      carregando = false;
    }
  }

  void abrirAba(String aba) {
    abaAtual = aba;
    mensagem = null;
  }

  void novaNoticia() {
    noticiaEmEdicao = _novaNoticia();
    mensagem = null;
  }

  void novaPublicacao() {
    publicacaoEmEdicao = _novaPublicacao();
    mensagem = null;
  }

  void novaPagina() {
    paginaEmEdicao = _novaPagina();
    mensagem = null;
  }

  void editarNoticia(Noticia item) {
    noticiaEmEdicao = item.clone();
    mensagem = null;
  }

  void editarPublicacao(PublicacaoOficial item) {
    publicacaoEmEdicao = item.clone();
    mensagem = null;
  }

  void editarPagina(PaginaInstitucional item) {
    paginaEmEdicao = item.clone();
    mensagem = null;
  }

  Future<void> salvarNoticia() async {
    salvando = true;
    erro = null;
    mensagem = null;

    try {
      final noticiaSalva = await _enviarJson<Noticia>(
        caminho: 'noticias',
        id: editandoNoticia ? noticiaEmEdicao.id : null,
        method: editandoNoticia ? 'PUT' : 'POST',
        payload: noticiaEmEdicao.toMap(),
        fromMap: Noticia.fromMap,
      );
      noticiaEmEdicao = noticiaSalva;
      await carregarDados();
      mensagem = editandoNoticia
          ? 'Noticia atualizada com sucesso.'
          : 'Noticia criada com sucesso.';
    } catch (_) {
      erro = 'Falha ao salvar noticia editorial.';
    } finally {
      salvando = false;
    }
  }

  Future<void> salvarPublicacao() async {
    salvando = true;
    erro = null;
    mensagem = null;

    try {
      final publicacaoSalva = await _enviarJson<PublicacaoOficial>(
        caminho: 'publicacoes-oficiais',
        id: editandoPublicacao ? publicacaoEmEdicao.id : null,
        method: editandoPublicacao ? 'PUT' : 'POST',
        payload: publicacaoEmEdicao.toMap(),
        fromMap: PublicacaoOficial.fromMap,
      );
      publicacaoEmEdicao = publicacaoSalva;
      await carregarDados();
      mensagem = editandoPublicacao
          ? 'Publicacao oficial atualizada com sucesso.'
          : 'Publicacao oficial criada com sucesso.';
    } catch (_) {
      erro = 'Falha ao salvar publicacao oficial.';
    } finally {
      salvando = false;
    }
  }

  Future<void> salvarPagina() async {
    salvando = true;
    erro = null;
    mensagem = null;

    try {
      final paginaSalva = await _enviarJson<PaginaInstitucional>(
        caminho: 'paginas-institucionais',
        id: editandoPagina ? paginaEmEdicao.id : null,
        method: editandoPagina ? 'PUT' : 'POST',
        payload: paginaEmEdicao.toMap(),
        fromMap: PaginaInstitucional.fromMap,
      );
      paginaEmEdicao = paginaSalva;
      await carregarDados();
      mensagem = editandoPagina
          ? 'Pagina institucional atualizada com sucesso.'
          : 'Pagina institucional criada com sucesso.';
    } catch (_) {
      erro = 'Falha ao salvar pagina institucional.';
    } finally {
      salvando = false;
    }
  }

  Future<void> excluirNoticia(String id) async {
    await _excluir(caminho: 'noticias', id: id);
    noticiaEmEdicao = _novaNoticia();
  }

  Future<void> excluirPublicacao(String id) async {
    await _excluir(caminho: 'publicacoes-oficiais', id: id);
    publicacaoEmEdicao = _novaPublicacao();
  }

  Future<void> excluirPagina(String id) async {
    await _excluir(caminho: 'paginas-institucionais', id: id);
    paginaEmEdicao = _novaPagina();
  }

  String formatarDataHoraLocal(DateTime value) {
    final ano = value.year.toString().padLeft(4, '0');
    final mes = value.month.toString().padLeft(2, '0');
    final dia = value.day.toString().padLeft(2, '0');
    final hora = value.hour.toString().padLeft(2, '0');
    final minuto = value.minute.toString().padLeft(2, '0');
    return '$ano-$mes-$dia\T$hora:$minuto';
  }

  String statusLabel(StatusPublicacao status) => status.label;

  String tipoPublicacaoLabel(TipoPublicacao tipo) => tipo.label;

  String badgeStatusPublicacao(StatusPublicacao status) {
    switch (status) {
      case StatusPublicacao.rascunho:
        return 'bg-light text-body';
      case StatusPublicacao.agendada:
        return 'bg-info text-dark';
      case StatusPublicacao.publicada:
        return 'bg-success';
      case StatusPublicacao.arquivada:
        return 'bg-secondary';
    }
  }

  Future<void> _excluir({
    required String caminho,
    required String id,
  }) async {
    salvando = true;
    erro = null;
    mensagem = null;

    try {
      await HttpRequest.request(
        '$_apiBaseUrl/$caminho/$id',
        method: 'DELETE',
      );
      await carregarDados();
      mensagem = 'Registro excluido com sucesso.';
    } catch (_) {
      erro = 'Falha ao excluir registro editorial.';
    } finally {
      salvando = false;
    }
  }

  Future<T> _enviarJson<T>({
    required String caminho,
    required String method,
    required Map<String, dynamic> payload,
    required T Function(Map<String, dynamic>) fromMap,
    String? id,
  }) async {
    final sufixo = id == null ? '' : '/$id';
    final response = await HttpRequest.request(
      '$_apiBaseUrl/$caminho$sufixo',
      method: method,
      sendData: jsonEncode(payload),
      requestHeaders: const <String, String>{
        'Content-Type': 'application/json',
      },
    );
    return fromMap(
      Map<String, dynamic>.from(
        jsonDecode(response.responseText ?? '{}') as Map,
      ),
    );
  }

  List<T> _lerDataFrame<T>(
    String response,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final payload = DataFrame<T>.fromMapWithFactory(
      Map<String, dynamic>.from(jsonDecode(response) as Map),
      fromMap,
    );
    return payload.items;
  }

  static bool _temIdPersistido(String? id) {
    if (id == null) {
      return false;
    }
    final valor = id.trim();
    return valor.isNotEmpty && valor != '0';
  }

  static Noticia _novaNoticia() {
    return Noticia(
      id: '0',
      slug: '',
      titulo: '',
      resumo: '',
      categoria: '',
      publicadoEm: DateTime.now(),
      urlImagem: null,
      destaque: false,
    );
  }

  static PublicacaoOficial _novaPublicacao() {
    return PublicacaoOficial(
      id: '0',
      titulo: '',
      tipo: TipoPublicacao.noticia,
      status: StatusPublicacao.rascunho,
      codigoReferencia: '',
      publicadoEm: DateTime.now(),
      areaEditorial: '',
      resumo: null,
    );
  }

  static PaginaInstitucional _novaPagina() {
    return PaginaInstitucional(
      id: '0',
      titulo: '',
      slug: '',
      secao: '',
      status: StatusPublicacao.rascunho,
      resumo: null,
    );
  }
}
