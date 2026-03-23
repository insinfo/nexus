import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../shared/rest_config.dart';
import '../../shared/services/acesso_service.dart';
import '../../shared/services/oidc_service.dart';
import '../../shared/services/portal_publico_service.dart';
import '../../shared/services/runtime_service.dart';
import '../../shared/services/servico_http_base.dart';

@Component(
  selector: 'app-root',
  templateUrl: 'app_component.html',
  styleUrls: <String>['app_component.css'],
  directives: <Object>[coreDirectives, formDirectives],
  providers: <Object>[
    ClassProvider(RestConfig),
    ClassProvider(ServicoHttpBase),
    ClassProvider(OidcService),
    ClassProvider(AcessoService),
    ClassProvider(PortalPublicoService),
    ClassProvider(RuntimeService),
  ],
)
class AppComponent {
  AppComponent(
    this._oidcService,
    this._acessoService,
    this._portalPublicoService,
    this._runtimeService,
  );

  final OidcService _oidcService;
  final AcessoService _acessoService;
  final PortalPublicoService _portalPublicoService;
  final RuntimeService _runtimeService;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  bool carregando = false;
  bool runtimeCarregando = false;
  bool consultaProtocoloCarregando = false;
  bool acessoCarregando = false;
  String? erro;
  String? erroRuntime;
  String? erroConsultaProtocolo;
  String? erroAcesso;
  String? mensagemAcesso;
  DadosPaginaInicialPortal portal = _portalVazio();
  EstadoPassoRuntime? estadoRuntime;
  ConsultaPublicaProtocolo? protocoloConsultado;
  ResultadoAutenticacaoUsuario? sessaoUsuario;
  ResultadoTokenOidc? sessaoOidc;
  ResultadoUsuarioInfoOidc? usuarioInfoOidc;
  ResultadoSolicitacaoRedefinicaoSenha? redefinicaoSolicitada;
  String? idServicoEmExecucao;
  String codigoConsultaProtocolo = '';
  String abaAcesso = 'login';
  RequisicaoLoginUsuario loginUsuario = RequisicaoLoginUsuario();
  RequisicaoCadastroUsuario cadastroUsuario = RequisicaoCadastroUsuario();
  RequisicaoSolicitarRedefinicaoSenha solicitarRedefinicaoSenha =
      RequisicaoSolicitarRedefinicaoSenha();
  RequisicaoRedefinirSenha redefinirSenha = RequisicaoRedefinirSenha();
  final Map<String, dynamic> respostasFormulario = <String, dynamic>{};

  Future<void> ngOnInit() async {
    await carregarPortal();
  }

  Future<void> carregarPortal() async {
    carregando = true;
    erro = null;

    try {
      portal = await _portalPublicoService.carregarPaginaInicial();
    } catch (_) {
      erro = 'Nao foi possivel carregar o catalogo inicial do Nexus.';
      portal = _portalVazio();
    } finally {
      carregando = false;
    }
  }

  String formatDate(DateTime value) => _dateFormat.format(value);

  bool get abaLoginAtiva => abaAcesso == 'login';

  bool get abaCadastroAtiva => abaAcesso == 'cadastro';

  bool get abaRecuperacaoAtiva => abaAcesso == 'recuperacao';

  bool get usuarioAutenticado => sessaoUsuario != null;

  bool get possuiSessaoAtiva => estadoRuntime != null;

  bool get runtimeConcluido =>
      estadoRuntime?.status == StatusExecucao.concluida;

  NoFluxoDto? get noAtual => estadoRuntime?.noAtual;

  DadosNoFormulario? get noFormularioAtual {
    final no = noAtual;
    if (no == null || no.tipo != TipoNoFluxo.formulario) {
      return null;
    }
    return no.dados as DadosNoFormulario;
  }

  DadosNoApresentacao? get noApresentacaoAtual {
    final no = noAtual;
    if (no == null || no.tipo != TipoNoFluxo.apresentacao) {
      return null;
    }
    return no.dados as DadosNoApresentacao;
  }

  DadosNoConteudoDinamico? get noConteudoAtual {
    final no = noAtual;
    if (no == null || no.tipo != TipoNoFluxo.conteudoDinamico) {
      return null;
    }
    return no.dados as DadosNoConteudoDinamico;
  }

  RegistroSubmissao? get registroSubmissaoAtual =>
      estadoRuntime?.registroSubmissao;

  Iterable<BlocoConteudoRico> get blocosApresentacao {
    final dados = noApresentacaoAtual;
    return dados?.conteudoApresentacao.blocos ?? const <BlocoConteudoRico>[];
  }

  dynamic valorCampoAtual(String chaveCampo) {
    return respostasFormulario[chaveCampo];
  }

  bool campoMarcado(String chaveCampo) {
    return respostasFormulario[chaveCampo] == true;
  }

  bool perguntaEhSelecao(DefinicaoPergunta pergunta) {
    return pergunta.tipo == TipoCampoFormulario.selecao ||
        pergunta.tipo == TipoCampoFormulario.multiplaSelecao;
  }

  bool perguntaEhTextoLongo(DefinicaoPergunta pergunta) {
    return pergunta.tipo == TipoCampoFormulario.textoLongo;
  }

  bool perguntaEhBooleano(DefinicaoPergunta pergunta) {
    return pergunta.tipo == TipoCampoFormulario.caixaMarcacao;
  }

  String tipoInputPergunta(DefinicaoPergunta pergunta) {
    switch (pergunta.tipo) {
      case TipoCampoFormulario.inteiro:
      case TipoCampoFormulario.decimal:
      case TipoCampoFormulario.moeda:
        return 'number';
      case TipoCampoFormulario.data:
        return 'date';
      case TipoCampoFormulario.dataHora:
        return 'datetime-local';
      case TipoCampoFormulario.email:
        return 'email';
      case TipoCampoFormulario.telefone:
      case TipoCampoFormulario.cpf:
      case TipoCampoFormulario.cnpj:
      case TipoCampoFormulario.textoCurto:
      case TipoCampoFormulario.textoLongo:
      case TipoCampoFormulario.anexo:
      case TipoCampoFormulario.selecao:
      case TipoCampoFormulario.multiplaSelecao:
      case TipoCampoFormulario.caixaMarcacao:
        return 'text';
    }
  }

  String conteudoBloco(BlocoConteudoRico bloco) {
    return bloco.dados['texto']?.toString() ?? '';
  }

  dynamic resultadoIntegracaoAtual() {
    final no = noAtual;
    final estado = estadoRuntime;
    if (no == null || estado == null) {
      return null;
    }
    return estado.contexto.resultadosIntegracao[no.id];
  }

  String resultadoIntegracaoFormatado() {
    final resultado = resultadoIntegracaoAtual();
    if (resultado == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert(resultado);
  }

  String registroSubmissaoFormatado() {
    final registro = registroSubmissaoAtual;
    if (registro == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert(registro.toMap());
  }

  String protocoloConsultadoFormatado() {
    final protocolo = protocoloConsultado;
    if (protocolo == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert(protocolo.toMap());
  }

  String rotuloStatusProtocolo(String valor) {
    return _rotuloLivre(valor);
  }

  String rotuloSituacaoAndamento(String valor) {
    return _rotuloLivre(valor);
  }

  void abrirAbaAcesso(String aba) {
    abaAcesso = aba;
    erroAcesso = null;
    mensagemAcesso = null;
  }

  void alterarDataNascimento(String? valor) {
    if (valor == null || valor.isEmpty) {
      cadastroUsuario.dataNascimento = null;
    } else {
      cadastroUsuario.dataNascimento = DateTime.tryParse(valor);
    }
  }

  Future<void> cadastrarContaCidadao() async {
    acessoCarregando = true;
    erroAcesso = null;
    mensagemAcesso = null;

    try {
      sessaoUsuario = await _acessoService.cadastrarContaCidadao(
        cadastroUsuario,
      );
      mensagemAcesso = 'Cadastro realizado e sessao iniciada com sucesso.';
      abaAcesso = 'login';
    } catch (_) {
      erroAcesso = 'Nao foi possivel cadastrar a conta do cidadao.';
    } finally {
      acessoCarregando = false;
    }
  }

  Future<void> entrarContaCidadao() async {
    acessoCarregando = true;
    erroAcesso = null;
    mensagemAcesso = null;

    try {
      final resultado = await _oidcService.autenticar(
        identificador: loginUsuario.identificador,
        senha: loginUsuario.senha,
      );
      _aplicarSessaoOidc(resultado.token, resultado.usuarioInfo);
      mensagemAcesso = 'Login OIDC realizado com sucesso.';
    } catch (_) {
      erroAcesso = 'Nao foi possivel autenticar com os dados informados.';
    } finally {
      acessoCarregando = false;
    }
  }

  Future<void> solicitarRecuperacaoSenha() async {
    acessoCarregando = true;
    erroAcesso = null;
    mensagemAcesso = null;

    try {
      redefinicaoSolicitada = await _acessoService.solicitarRecuperacaoSenha(
        solicitarRedefinicaoSenha,
      );
      redefinirSenha.token = redefinicaoSolicitada?.token ?? '';
      mensagemAcesso = redefinicaoSolicitada?.mensagem ??
          'Solicitacao registrada com sucesso.';
    } catch (_) {
      erroAcesso = 'Nao foi possivel solicitar a redefinicao de senha.';
    } finally {
      acessoCarregando = false;
    }
  }

  Future<void> confirmarRecuperacaoSenha() async {
    acessoCarregando = true;
    erroAcesso = null;
    mensagemAcesso = null;

    try {
      sessaoUsuario = await _acessoService.confirmarRecuperacaoSenha(
        redefinirSenha,
      );
      mensagemAcesso = 'Senha redefinida e sessao iniciada com sucesso.';
    } catch (_) {
      erroAcesso = 'Nao foi possivel redefinir a senha informada.';
    } finally {
      acessoCarregando = false;
    }
  }

  Future<void> encerrarSessaoAcesso() async {
    try {
      await _oidcService.encerrarSessao(
        sessionState: sessaoOidc?.sessionState,
        accessToken: sessaoOidc?.accessToken,
      );
    } catch (_) {
      // Mantem logout local mesmo se o backend nao estiver acessivel.
    }

    sessaoUsuario = null;
    sessaoOidc = null;
    usuarioInfoOidc = null;
    mensagemAcesso = 'Sessao OIDC encerrada no portal.';
  }

  Future<void> iniciarFederacaoMicrosoft() async {
    acessoCarregando = true;
    erroAcesso = null;
    mensagemAcesso = null;

    try {
      final resultado = await _oidcService.iniciarFederacaoMicrosoft();
      if (!resultado.habilitado || resultado.urlAutorizacao.isEmpty) {
        erroAcesso = resultado.mensagem ??
            'Federacao Microsoft indisponivel neste ambiente.';
        return;
      }
      mensagemAcesso = 'Redirecionando para Microsoft Active Directory...';
      _oidcService.redirecionarParaAutorizacao(resultado.urlAutorizacao);
    } catch (_) {
      erroAcesso = 'Nao foi possivel iniciar a federacao Microsoft.';
    } finally {
      acessoCarregando = false;
    }
  }

  Future<void> acompanharRegistroAtual() async {
    final registro = registroSubmissaoAtual;
    if (registro == null) {
      return;
    }
    codigoConsultaProtocolo = registro.numeroProtocolo;
    await consultarProtocoloPublico();
  }

  void atualizarCodigoConsultaProtocolo(String valor) {
    codigoConsultaProtocolo = valor;
  }

  Future<void> consultarProtocoloPublico() async {
    final codigo = codigoConsultaProtocolo.trim();
    if (codigo.isEmpty) {
      erroConsultaProtocolo =
          'Informe um numero de protocolo ou codigo publico.';
      protocoloConsultado = null;
      return;
    }

    consultaProtocoloCarregando = true;
    erroConsultaProtocolo = null;
    protocoloConsultado = null;

    try {
      protocoloConsultado = await _portalPublicoService.consultarProtocolo(
        codigo,
      );
    } catch (_) {
      erroConsultaProtocolo =
          'Nao foi possivel localizar o protocolo informado.';
    } finally {
      consultaProtocoloCarregando = false;
    }
  }

  Future<void> iniciarServico(String idServico) async {
    runtimeCarregando = true;
    erroRuntime = null;
    respostasFormulario.clear();

    try {
      estadoRuntime = await _runtimeService.iniciarSessao(idServico);
      idServicoEmExecucao = idServico;
      _hidratarRespostasDoContexto();
      if (registroSubmissaoAtual != null) {
        await acompanharRegistroAtual();
      }
    } catch (_) {
      erroRuntime = 'Nao foi possivel iniciar a sessao publicada do servico.';
    } finally {
      runtimeCarregando = false;
    }
  }

  Future<void> avancarSessao() async {
    final estado = estadoRuntime;
    if (estado == null) {
      return;
    }

    runtimeCarregando = true;
    erroRuntime = null;

    try {
      estadoRuntime = await _runtimeService.avancarSessao(
        estado.idSessao,
        respostasFormulario,
      );
      _hidratarRespostasDoContexto();
      if (registroSubmissaoAtual != null) {
        await acompanharRegistroAtual();
      }
    } catch (_) {
      erroRuntime = 'Nao foi possivel avancar a sessao atual.';
    } finally {
      runtimeCarregando = false;
    }
  }

  void atualizarRespostaTexto(String chaveCampo, String valor) {
    respostasFormulario[chaveCampo] = valor;
  }

  void atualizarRespostaMarcacao(String chaveCampo, bool valor) {
    respostasFormulario[chaveCampo] = valor;
  }

  void encerrarSessaoVisual() {
    estadoRuntime = null;
    idServicoEmExecucao = null;
    erroRuntime = null;
    respostasFormulario.clear();
  }

  void _hidratarRespostasDoContexto() {
    final estado = estadoRuntime;
    if (estado == null) {
      return;
    }
    respostasFormulario
      ..clear()
      ..addAll(estado.contexto.respostas);
  }

  void _aplicarSessaoOidc(
    ResultadoTokenOidc token,
    ResultadoUsuarioInfoOidc usuarioInfo,
  ) {
    sessaoOidc = token;
    usuarioInfoOidc = usuarioInfo;
    sessaoUsuario = _oidcService.criarSessaoUsuario(token, usuarioInfo);
  }

  static DadosPaginaInicialPortal _portalVazio() {
    return DadosPaginaInicialPortal(
      tituloPortal: 'Portal Nexus Rio das Ostras',
      subtituloPortal: 'Catalogo inicial indisponivel no momento.',
      servicoDestaque: ItemCatalogoServico(
        id: 'portal-indisponivel',
        codigo: 'INDISPONIVEL',
        titulo: 'Catalogo indisponivel',
        resumo: 'Conecte o backend para exibir os servicos publicados.',
        categoria: 'plataforma',
        publico: ModoAcesso.interno.label,
      ),
    );
  }

  static String _rotuloLivre(String valor) {
    if (valor.isEmpty) {
      return valor;
    }

    final comEspacos = valor.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match match) => '${match.group(1)} ${match.group(2)}',
    );

    return comEspacos
        .split('_')
        .expand((String parte) => parte.split(' '))
        .where((String parte) => parte.isNotEmpty)
        .map((String parte) => '${parte[0].toUpperCase()}${parte.substring(1)}')
        .join(' ');
  }
}
