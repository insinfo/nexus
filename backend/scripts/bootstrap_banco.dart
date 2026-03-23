import 'dart:io';

/// Script de bootstrap completo do banco de dados Nexus.
///
/// Executa em sequencia:
/// 1. Cria o role `dart` e o banco `nexus` via psql (create_database.sql)
/// 2. Aplica as migrations (db_migrations.sql)
/// 3. Executa o seed institucional (seed_dados_exemplo.dart)
///
/// Uso:
///   dart run scripts/bootstrap_banco.dart
///
/// Parametros opcionais:
///   --pg-user    Usuario superusuario do PostgreSQL (padrao: postgres)
///   --pg-pass    Senha do superusuario (padrao: postgres)
///   --pg-host    Host do PostgreSQL (padrao: localhost)
///   --pg-port    Porta do PostgreSQL (padrao: 5432)
///   --db-user    Usuario do banco nexus (padrao: dart)
///   --db-pass    Senha do usuario do banco nexus (padrao: dart)
///   --skip-seed  Pula o seed institucional

Future<void> main(List<String> arguments) async {
  final args = _parseArgs(arguments);

  final pgUser = args['pg-user'] ?? 'postgres';
  final pgPass = args['pg-pass'] ?? 's1sadm1n';
  final pgHost = args['pg-host'] ?? 'localhost';
  final pgPort = args['pg-port'] ?? '5432';
  final dbUser = args['db-user'] ?? 'dart';
  final dbPass = args['db-pass'] ?? 'dart';
  final skipSeed = args.containsKey('skip-seed');

  final scriptsDir = _resolverDiretorioScripts();

  print('=== Bootstrap do banco de dados Nexus ===');
  print('PostgreSQL: $pgHost:$pgPort (superusuario: $pgUser)');
  print('Banco: nexus (usuario: $dbUser)');
  print('');

  // 1. Criar banco
  print('[1/3] Criando banco de dados...');
  await _executarPsql(
    host: pgHost,
    port: pgPort,
    user: pgUser,
    password: pgPass,
    database: 'postgres',
    arquivo: '${scriptsDir.path}${Platform.pathSeparator}create_database.sql',
  );
  print('      Banco nexus criado com sucesso.');
  print('');

  // 2. Aplicar migrations
  print('[2/3] Aplicando migrations...');
  await _executarPsql(
    host: pgHost,
    port: pgPort,
    user: dbUser,
    password: dbPass,
    database: 'nexus',
    arquivo: '${scriptsDir.path}${Platform.pathSeparator}db_migrations.sql',
  );
  print('      Migrations aplicadas com sucesso.');
  print('');

  // 3. Seed institucional
  if (skipSeed) {
    print('[3/3] Seed ignorado (--skip-seed).');
  } else {
    print('[3/3] Executando seed institucional...');
    await _executarDartScript(
      '${scriptsDir.path}${Platform.pathSeparator}seed_dados_exemplo.dart',
    );
    print('      Seed aplicado com sucesso.');
  }

  print('');
  print('=== Bootstrap concluido com sucesso ===');
}

Directory _resolverDiretorioScripts() {
  // Tenta encontrar o diretorio scripts relativo ao script atual
  final scriptFile = File(Platform.script.toFilePath());
  if (scriptFile.parent.path.endsWith('scripts')) {
    return scriptFile.parent;
  }

  // Fallback: tenta a partir do diretorio de trabalho
  final cwd = Directory.current;
  final candidato = Directory('${cwd.path}${Platform.pathSeparator}scripts');
  if (candidato.existsSync()) {
    return candidato;
  }

  // Ultimo recurso: usa o diretorio atual
  return cwd;
}

Future<void> _executarPsql({
  required String host,
  required String port,
  required String user,
  required String password,
  required String database,
  required String arquivo,
}) async {
  final arquivoFile = File(arquivo);
  if (!arquivoFile.existsSync()) {
    throw Exception('Arquivo SQL nao encontrado: $arquivo');
  }

  final resultado = await Process.run(
    'psql',
    [
      '-h',
      host,
      '-p',
      port,
      '-U',
      user,
      '-d',
      database,
      '-f',
      arquivo,
      '--no-password',
    ],
    environment: <String, String>{
      'PGPASSWORD': password,
    },
  );

  final stdout = (resultado.stdout as String).trim();
  final stderr = (resultado.stderr as String).trim();

  if (stdout.isNotEmpty) {
    print('      $stdout');
  }

  if (resultado.exitCode != 0) {
    if (stderr.isNotEmpty) {
      print('      ERRO: $stderr');
    }
    throw Exception(
      'psql falhou com codigo ${resultado.exitCode} ao executar: $arquivo',
    );
  }

  // Avisos nao fatais
  if (stderr.isNotEmpty && !stderr.contains('ERROR')) {
    // Ignorar avisos normais como NOTICE
  }
}

Future<void> _executarDartScript(String caminhoScript) async {
  final scriptFile = File(caminhoScript);
  if (!scriptFile.existsSync()) {
    throw Exception('Script Dart nao encontrado: $caminhoScript');
  }

  final resultado = await Process.run(
    'dart',
    ['run', caminhoScript],
    workingDirectory: scriptFile.parent.parent.path,
  );

  final stdout = (resultado.stdout as String).trim();
  final stderr = (resultado.stderr as String).trim();

  if (stdout.isNotEmpty) {
    print('      $stdout');
  }

  if (resultado.exitCode != 0) {
    if (stderr.isNotEmpty) {
      print('      ERRO: $stderr');
    }
    throw Exception(
      'Seed falhou com codigo ${resultado.exitCode}',
    );
  }
}

Map<String, String> _parseArgs(List<String> arguments) {
  final mapa = <String, String>{};
  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (arg.startsWith('--')) {
      final chave = arg.substring(2);
      if (chave == 'skip-seed') {
        mapa[chave] = 'true';
      } else if (i + 1 < arguments.length &&
          !arguments[i + 1].startsWith('--')) {
        mapa[chave] = arguments[i + 1];
        i++;
      }
    }
  }
  return mapa;
}
