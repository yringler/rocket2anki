import 'package:dart/dashboard.dart';
import 'package:dart/lesson.dart';
import 'package:dart/utils.dart';

class FlashCard {
  String primary;
  String back;
  String audio;
  Phrase phrase;

  FlashCard(
      {required this.primary,
      required this.back,
      required this.audio,
      required this.phrase});
}

class FlashCardDeck {
  List<String> cards;
  DashboardLesson meta;
  CourseModule module;

  String get deckName {
    final lessonName = slugify(meta.name);
    final moduleNumber = module.number.toString().padLeft(2, "0");
    final lessonNumber =
        module.numberOfLesson(meta.id).toString().padLeft(2, '0');

    return '${_getTopName(moduleNumber)}::$moduleNumber.$lessonNumber-$lessonName';
  }

  String _getTopName(String moduleNumber) {
    // Add survivol kit to the surivival kit module (but not to the sample survival kit in the first module).
    if (meta.lessonTypeId == LessonType.survivalKit &&
        module.onlyContains(LessonGroupType.survivalKit)) {
      return '$moduleNumber-${meta.lessonTypeId.name}';
    }

    return moduleNumber;
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
