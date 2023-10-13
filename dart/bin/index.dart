import 'dart:io';
import 'dart:async';

import 'package:collection/collection.dart';
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

  final fullLessonsData = (await Future.wait(dashboard.modules
          .expand((module) => module.groupedLessons)
          .expand((lessonGroup) => lessonGroup.lessons)
          .map(rocketFetchLesson)
          .toList()))
      .whereType<LessonRoot>()
      .toList();

  final audioDownloadBatches = fullLessonsData
      .expand((e) => e.entities.phrases.values)
      .where((element) => element.audioUrl.isNotEmpty)
      .toList()
      .slices(10);

  for (var batch in audioDownloadBatches) {
    await Future.wait(batch.map((e) => e.downloadMedia(rootPath: './audio')));
  }

  final allDecks = fullLessonsData
      .map((e) => addLesson(e.entities,
          rocketData.dashboard.moduleForLesson(e.entities.lesson.id)))
      .toList();

  final masterDeck = getDeck(allDecks, config.language);

  writeSelection(masterDeck);
}

DeckConfig getDeck(List<FlashCardDeck> lessons, String deckName) {
  var cardsWithDeck = lessons.expand((lesson) {
    return lesson.cards.map((card) {
      return '$card$separator$deckName::${lesson.deckName}';
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

FlashCardDeck addLesson(LessonEntity lesson, CourseModule module) {
  var phrases = convertToList(lesson.phrases);
  var cards = phrases
      .map((phrase) => phrase.toCard())
      .toList()
      .whereType<FlashCard>()
      .map((card) {
    var sound = card.audio.isNotEmpty ? '[sound:${card.audio}' : '';
    return '${card.english}$separator${card.spanish}$sound';
  }).toList();

  return FlashCardDeck(cards, lesson.lesson, module);
}
