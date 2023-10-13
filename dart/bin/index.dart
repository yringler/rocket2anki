import 'dart:io';
import 'dart:async';

import 'package:dart/config.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/flash-card.dart';
import 'package:dart/lesson.dart';
import 'package:dart/rocketfetch.dart';
import 'package:dart/utils.dart';

const String mediaPath = 'audio';
const String deckPath = 'decks';
const String separator = '|';

bool skipDownload = !config.downloadAudio;
var finishedModules = config.finishedModules;

List<T> convertToList<T>(Map<int, T> data) {
  final x = data.keys.toList()..sort();
  return x.map((id) => data[id]!).toList();
}

Future<void> main() async {
  Directory(mediaPath).createSync(recursive: true);
  Directory(deckPath).createSync(recursive: true);

  var rocketData = await rocketFetchHome();

  if (rocketData == null) {
    return;
  }

  var dashboard = rocketData.dashboard;
  var entities = rocketData.entities;

  int? amount;
  var lessons = convertToList(entities.lessons);
  var promises = <Future<FlashCardDeck?>>[];

  for (var module in dashboard.modules.sublist(0, amount)) {
    for (var lessonGroup in module.groupedLessons.sublist(0, amount)) {
      for (var lessonId in lessonGroup.lessons.sublist(0, amount)) {
        var response = await rocketFetchLesson(lessonId);

        if (response == null) continue;

        promises.add(addLesson(response.entities,
            lessons.firstWhere((lesson) => lesson.id == lessonId), module));
      }
    }
  }

  var allLessons = getDeck(
      (await Future.wait(promises)).whereType<FlashCardDeck>().toList(), 'all');
  var survivalKit = getDeck(
      allLessons.lessons
          .where((lesson) => lesson.meta.lessonTypeId == LessonType.survivalKit)
          .toList(),
      'survival_kit');
  var withoutSurvival = getDeck(
      allLessons.lessons
          .where((lesson) => lesson.meta.lessonTypeId != LessonType.survivalKit)
          .toList(),
      'lessons');

  writeSelection(DeckConfig(
    deckName: 'all-${config.language}',
    lessons: survivalKit.lessons + withoutSurvival.lessons,
    cardsWithDeck:
        [survivalKit.cardsWithDeck, withoutSurvival.cardsWithDeck].join('\n'),
  ));
}

DeckConfig getDeck(List<FlashCardDeck> lessons, String deckName) {
  var cardsWithDeck = lessons.expand((lesson) {
    return lesson.cards.map((card) {
      return '$card$separator${config.language}$deckName::${lesson.deckName}';
    });
  }).join('\n');

  return DeckConfig(
      cardsWithDeck: cardsWithDeck, lessons: lessons, deckName: deckName);
}

void writeSelection(DeckConfig deck) {
  var header = '#separator:Pipe\n#html:true\n#deck column: 3\n';
  File(join([deckPath, '${deck.deckName}.txt']))
      .writeAsStringSync(header + deck.cardsWithDeck);
}

Future<FlashCardDeck?> addLesson(
    LessonEntity lesson, DashboardLesson meta, CourseModule module) async {
  var phrases = convertToList(lesson.phrases);
  var cardPromises = phrases.map((phrase) async {
    await phrase.downloadMedia(rootPath: './audio');
    return phrase.toCard();
  }).toList();

  var cards = (await Future.wait(cardPromises))
      .where((card) => card != null)
      .map((card) {
    var sound = card?.audio != null ? '[sound:${card!.audio}' : '';
    return '${card!.english}$separator${card.spanish}$sound';
  }).toList();

  return FlashCardDeck(cards, meta, module);
}
