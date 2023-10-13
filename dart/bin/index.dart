import 'dart:io';
import 'dart:async';

import 'dart:typed_data';
import 'package:dart/config.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/lesson.dart';
import 'package:dart/rocketfetch.dart';
import 'package:dart/utils.dart';

class LessonCards {
  List<String> cards;
  DashboardLesson meta;

  LessonCards(this.cards, this.meta);
}

class FlashCard {
  String english;
  String spanish;
  String audio;

  FlashCard(
      {required this.english, required this.spanish, required this.audio});
}

class DeckConfig {
  String cardsWithDeck;
  List<LessonCards> lessons;
  String deckName;

  DeckConfig(
      {required this.cardsWithDeck,
      required this.lessons,
      required this.deckName});
}

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
  var promises = <Future<LessonCards?>>[];

  for (var module in dashboard.modules.sublist(0, amount)) {
    for (var lessonGroup in module.groupedLessons.sublist(0, amount)) {
      for (var lessonId in lessonGroup.lessons.sublist(0, amount)) {
        var response = await rocketFetchLesson(lessonId);
        if (response == null) continue;
        promises.add(addLesson(response.entities,
            lessons.firstWhere((lesson) => lesson.id == lessonId)));
      }
    }
  }

  var moduleIdToNumberMap = Map<int, double>.fromEntries(
      dashboard.modules.map((module) => MapEntry(module.id, module.number)));
  var allLessons = getDeck(
      (await Future.wait(promises)).whereType<LessonCards>().toList(),
      'all',
      moduleIdToNumberMap);
  var survivalKit = getDeck(
      allLessons.lessons
          .where((lesson) => lesson.meta.lessonTypeId == LessonType.survivalKit)
          .toList(),
      'survival_kit',
      moduleIdToNumberMap);
  var withoutSurvival = getDeck(
      allLessons.lessons
          .where((lesson) => lesson.meta.lessonTypeId != LessonType.survivalKit)
          .toList(),
      'lessons',
      moduleIdToNumberMap);
  var orderedModuleIds = ([...moduleIdToNumberMap.entries]
        ..sort((a, b) => a.value.compareTo(b.value)))
      .map((entry) => entry.key)
      .toList();

  var completed = getDeck(
      getCompletedModules(
          finishedModules, withoutSurvival.lessons, orderedModuleIds),
      'completed',
      moduleIdToNumberMap);

  writeSelection(DeckConfig(
    deckName: 'all-${config.language}',
    lessons: completed.lessons + survivalKit.lessons + withoutSurvival.lessons,
    cardsWithDeck: [
      completed.cardsWithDeck,
      survivalKit.cardsWithDeck,
      withoutSurvival.cardsWithDeck
    ].join('\n'),
  ));
}

List<LessonCards> getCompletedModules(int amountCompleted,
    List<LessonCards> lessons, List<int> orderedModuleIds) {
  var completedModules = orderedModuleIds.sublist(0, amountCompleted);
  return lessons
      .where((lesson) => completedModules.contains(lesson.meta.moduleId))
      .toList();
}

DeckConfig getDeck(List<LessonCards> lessons, String deckName,
    Map<int, double> moduleIdToNumber) {
  var cardsWithDeck = lessons.expand((lesson) {
    return lesson.cards.map((card) {
      var subdeckName = [lesson.meta.slug, slugify(lesson.meta.name)].join('-');
      return '$card$separator${config.language}$deckName::${moduleIdToNumber[lesson.meta.moduleId]}::$subdeckName';
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

Future<LessonCards?> addLesson(
    LessonEntity lesson, DashboardLesson meta) async {
  var phrases = convertToList(lesson.phrases);
  var cardPromises = phrases.map((phrase) async {
    final english = phrase.ofWritingSystem(WritingSystemId.english);
    final spanish = phrase.ofWritingSystem(WritingSystemId.spanish);

    if (phrase.hasAudio) {
      final audioFile = File(join(['./audio', phrase.audioFileName]));

      if (!audioFile.existsSync()) {
        await phrase.downloadMedia(rootPath: './audio');
      }
    }
    if ((english?.text.isEmpty ?? true) || (spanish?.text.isEmpty ?? true)) {
      return null;
    }

    return FlashCard(
        english: sanitize(english!.text),
        spanish: sanitize(spanish!.text),
        audio: phrase.audioFileName);
  });

  var cards = (await Future.wait(cardPromises))
      .where((card) => card != null)
      .map((card) {
    var sound = card?.audio != null ? '[sound:${card!.audio}' : '';
    return '${card!.english}$separator${card.spanish}$sound';
  }).toList();

  return LessonCards(cards, meta);
}

// We use pipe as the seperator, so if it shows up in the card, we convert it to the HTML entity.
String sanitize(String text) {
  return text.replaceAll('|', '&vert;');
}
