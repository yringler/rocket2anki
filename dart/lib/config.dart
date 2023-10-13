import 'package:dotenv/dotenv.dart';

class FlashConfig {
  final int finishedModules;
  final bool downloadAudio;
  final int productId;
  final String language;
  final String bearer;
  final String xsrf;
  final String cookie;

  FlashConfig(
      {required this.finishedModules,
      required this.downloadAudio,
      required this.productId,
      required this.language,
      required this.bearer,
      required this.xsrf,
      required this.cookie});
}

final env = DotEnv()..load();

final config = FlashConfig(
    finishedModules: int.parse(env['finishedModules']!),
    downloadAudio: bool.parse(env['downloadAudio']!),
    productId: int.parse(env['productId']!),
    language: env['language']!,
    bearer: env['bearer']!,
    xsrf: env['xsrf']!,
    cookie: env['cookie']!);
