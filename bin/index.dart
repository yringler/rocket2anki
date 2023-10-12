import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:dart/config.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/flash-card.dart';
import 'package:dart/lesson.dart';
import 'package:dart/login.dart';
import 'package:dart/rocketfetch.dart';
import 'package:dart/utils.dart';

const String mediaPath = 'audio';
const String deckPath = 'decks';
const String separator = '|';

List<T> convertToList<T>(Map<int, T> data) {
  final x = data.keys.toList()..sort();
  return x.map((id) => data[id]!).toList();
}

Future<void> main(List<String> args) async {
  Directory(mediaPath).createSync(recursive: true);
  Directory(deckPath).createSync(recursive: true);

  final argsParser = ArgParser()
    ..addOption('email', abbr: 'e', mandatory: true)
    ..addOption('password', abbr: 'p', mandatory: true);

  final loginInfo = getLoginInfo(argsParser.parse(args));

  if (loginInfo == null) {
    print(argsParser.usage);
    return;
  }

  final auth = await getAuthCode(loginInfo);

  final rocketFetcher = RocketFetcher(auth: auth);

  var rocketData = await rocketFetcher.rocketFetchHome();

  if (rocketData == null) {
    return;
  }

  var dashboard = rocketData.dashboard;

  final fullLessonsData = (await Future.wait(dashboard.modules
          .expand((module) => module.groupedLessons)
          .expand((lessonGroup) => lessonGroup.lessons)
          .map(rocketFetcher.rocketFetchLesson)
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
    return '${card.primary}$separator${card.back}$sound';
  }).toList();

  return FlashCardDeck(cards, lesson.lesson, module);
}

LoginInfo? getLoginInfo(ArgResults parsedArgs) {
  try {
    final String email = parsedArgs['email'];
    final String password = parsedArgs['password'];

    return LoginInfo(email: email, password: password);
  } on ArgumentError catch (e) {
    print(e.message);
  }

  return null;
}
