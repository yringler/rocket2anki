import 'package:dotenv/dotenv.dart';

class FlashConfig {
  final int productId;
  final String language;

  FlashConfig({required this.productId, required this.language});
}

final env = DotEnv()..load();

final config = FlashConfig(
    productId: int.parse(env['productId']!), language: env['language']!);
