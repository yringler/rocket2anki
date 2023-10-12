import 'package:dotenv/dotenv.dart';

class FlashConfig {
  final bool downloadAudio;
  final int productId;
  final String language;

  FlashConfig(
      {required this.downloadAudio,
      required this.productId,
      required this.language});
}

final env = DotEnv()..load();

final config = FlashConfig(
    downloadAudio: bool.parse(env['downloadAudio']!),
    productId: int.parse(env['productId']!),
    language: env['language']!);
