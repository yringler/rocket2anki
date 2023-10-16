import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:dart/courses.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/flash-card.dart';
import 'package:dart/lesson.dart';
import 'package:dart/login.dart';
import 'package:dart/rocketfetch.dart';
import 'package:dart/utils.dart';
import 'package:interact/interact.dart';

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
    ..addOption('email', abbr: 'e')
    ..addOption('password', abbr: 'p')
    ..addFlag('help', abbr: 'h');

  final parsedArgs = argsParser.parse(args);

  if (parsedArgs.wasParsed("help")) {
    print(argsParser.usage);
  }

  String? auth;

  while (auth == null) {
    final loginInfo = getLoginInfo(parsedArgs);
    auth = await getAuthCode(loginInfo);

    if (auth == null) {
      print(
          'Please make sure to enter your correct rocket email address and password');
    }
  }

  final spinner = Spinner(
      icon: '🏆',
      rightPrompt: (done) => done
          ? 'Deck import file created and audio downloaded!'
          : 'Please wait, downloading content').interact();

  final products = await RocketFetcher.rocketFetchUrl(
      'https://app.rocketlanguages.com/api/v2/courses',
      auth,
      AllCourses.fromJson);

  assert(products != null);

  final decks = (await Future.wait(products!.userCourses
          .map((course) => course.productLevels
              .where((element) => !element.isTrial)
              .map((level) =>
                  getDecksForProduct(auth!, course: course, level: level)))
          .expand((x) => x)
          .toList()))
      .whereNotNull()
      .toList();

  for (var deck in decks) {
    writeSelection(deck);
  }

  final realDecks = decks
      .where((deck) => deck.cardsWithDeck.split('\n').length > 100)
      .toList();

  writeSelection(DeckConfig(
      cardsWithDeck: realDecks.map((e) => e.cardsWithDeck).join('\n'),
      lessons: realDecks.expand((e) => e.lessons).toList(),
      deckName: 'All Courses'));

  spinner.done();
}

Future<DeckConfig?> getDecksForProduct(String auth,
    {required Course course, required ProductLevel level}) async {
  final rocketFetcher = RocketFetcher(auth: auth, productId: level.productId);

  var rocketData = await rocketFetcher.rocketFetchHome();

  assert(rocketData != null);

  var dashboard = rocketData?.dashboard;

  if (dashboard == null) {
    print('No product: ${course.fullName}');
    return null;
  }

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
      .map((e) => getLessonDeck(
          e.entities, dashboard.moduleForLesson(e.entities.lesson.id)))
      .toList();

  return getDeck(allDecks, '${course.fullName} - ${level.label}');
}

DeckConfig getDeck(List<FlashCardDeck> lessons, String deckName) {
  var cardsWithDeck = lessons.expand((lesson) {
    return lesson.cards.map((card) {
      return [card, '$deckName::${lesson.deckName}'].join(separator);
    });
  }).join('\n');

  return DeckConfig(
      cardsWithDeck: cardsWithDeck, lessons: lessons, deckName: deckName);
}

void writeSelection(DeckConfig deck) {
  if (deck.cardsWithDeck.isEmpty) {
    return;
  }

  var header =
      '#separator:Pipe\n#html:true\n#guid column: 3\n#deck column: 4\n';
  File(join([deckPath, '${deck.deckName}.txt']))
      .writeAsStringSync(header + deck.cardsWithDeck);
}

FlashCardDeck getLessonDeck(LessonEntity lesson, CourseModule module) {
  var phrases = convertToList(lesson.phrases);
  var cards = phrases
      .map((phrase) => phrase.toCard(lesson))
      .toList()
      .whereType<FlashCard>()
      .map((card) {
    var sound = card.audio.isNotEmpty ? '[sound:${card.audio}]' : '';
    return [card.primary, card.back + sound, card.phrase.id].join(separator);
  }).toList();

  return FlashCardDeck(cards, lesson.lesson, module);
}

LoginInfo getLoginInfo(ArgResults parsedArgs) {
  String? email = parsedArgs['email'];
  String? password = parsedArgs['password'];

  if (email == null || email.isEmpty) {
    email = Input(
      prompt: 'Please enter the email address used for your rocket account',
      validator: (String x) {
        if (x.contains('@') && x.length >= 5) {
          return true;
        } else {
          throw ValidationError('Not a valid email');
        }
      },
    ).interact();
  }

  if (password == null || password.isEmpty) {
    password = Password(prompt: 'Please enter your rocket password').interact();
  }

  return LoginInfo(email: email, password: password);
}
