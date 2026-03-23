import 'package:args/args.dart';
import 'package:nexus_backend/src/shared/app_config.dart';
import 'package:nexus_backend/src/shared/bootstrap.dart';

Future<void> main(List<String> args) async {
  final cfg = AppConfig.inst();

  final ArgParser parser = ArgParser()
    ..addOption('address', abbr: 'a', defaultsTo: cfg.serverHost)
    ..addOption('port', abbr: 'p', defaultsTo: cfg.serverPort)
    ..addOption('isolates', abbr: 'j', defaultsTo: '1');

  final ArgResults parsed = parser.parse(args);

  await configureServer(
    parsed['address']! as String,
    int.parse(parsed['port']! as String),
    int.parse(parsed['isolates']! as String),
  );
}
