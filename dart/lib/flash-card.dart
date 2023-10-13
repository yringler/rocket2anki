import 'package:dart/dashboard.dart';
import 'package:dart/utils.dart';

class FlashCard {
  String english;
  String spanish;
  String audio;

  FlashCard(
      {required this.english, required this.spanish, required this.audio});
}

class FlashCardDeck {
  List<String> cards;
  DashboardLesson meta;
  CourseModule module;

  String get deckName {
    final subdeckName = slugify(meta.name);
    return '${module.number.toString().padLeft(2, "0")}::${module.numberOfLesson(meta.id).toString().padLeft(2, '0')} $subdeckName';
  }

  FlashCardDeck(this.cards, this.meta, this.module);
}

class DeckConfig {
  String cardsWithDeck;
  List<FlashCardDeck> lessons;
  String deckName;

  DeckConfig(
      {required this.cardsWithDeck,
      required this.lessons,
      required this.deckName});
}
