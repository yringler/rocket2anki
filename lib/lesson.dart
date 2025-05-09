import 'dart:io';
import 'package:dart/dashboard.dart';
import 'package:dart/flash-card.dart';
import 'package:http/http.dart' as http;

import 'package:dart/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

@JsonEnum(valueField: 'value')
enum WritingSystemId {
  english(1, primary: true),
  japaneseFigures(3, alwaysShow: true),
  japanesePinyin(4),

  spanish(5),
  arabicFigures(6, alwaysShow: true),
  arabic(7),
  pinyin(8),
  chineseFigures(9, alwaysShow: true),
  french(10),
  german(11),
  hindiFigures(12, alwaysShow: true),
  hindi(13),
  italian(14),
  koreanFigures(15, alwaysShow: true),
  koreanPinyin(16),
  portuguese(17),
  russian(19),
  russianFigures(20, alwaysShow: true);

  const WritingSystemId(this.value,
      {this.primary = false, this.alwaysShow = false});

  final int value;
  final bool primary;

  /// Show on both sides of card.
  final bool alwaysShow;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PhraseNotationReference {
  final int id;
  final int notationId;

  PhraseNotationReference({required this.id, required this.notationId});

  factory PhraseNotationReference.fromJson(Map<String, dynamic> json) =>
      _$PhraseNotationReferenceFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PhraseString {
  final int id;
  final String text;
  final WritingSystemId writingSystemId;
  final List<PhraseNotationReference> notations;

  PhraseString(this.id, this.text, this.writingSystemId, this.notations);

  factory PhraseString.fromJson(Map<String, dynamic> json) =>
      _$PhraseStringFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Phrase {
  final int id;
  final String audioUrl;
  final String? literalString;
  final List<PhraseString> strings;

  String get audioFileName {
    var url = Uri.tryParse(audioUrl);

    if (url == null) {
      return '';
    }

    return slugify(url.pathSegments.lastOrNull ?? '');
  }

  bool get _hasAudio => audioFileName.isNotEmpty;

  Phrase(this.audioUrl, this.strings, this.literalString, this.id);

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);

  PhraseString? ofWritingSystem(WritingSystemId writingSystem) {
    return strings
        .where((element) => element.writingSystemId == writingSystem)
        .firstOrNull;
  }

  FlashCard? toCard(LessonEntity lessonEntity) {
    final front = strings
            .where((element) => element.writingSystemId.primary)
            .firstOrNull
            ?.text ??
        '';

    final backString = strings
        .where((element) =>
            !element.writingSystemId.primary &&
            !element.writingSystemId.alwaysShow)
        .firstOrNull;
    final back = backString?.text ?? '';

    final both = strings
        .where((element) => element.writingSystemId.alwaysShow)
        .firstOrNull;
    final notations = backString?.notations
            .map((e) => lessonEntity.notations[e.notationId]?.tooltipLabel)
            .nonNulls
            .join(' - ') ??
        '';

    if (front.trim().isEmpty || back.trim().isEmpty) {
      return null;
    }

    final literal = literalString ?? '';
    final englishSide = literal.isEmpty ? front : '$front ($literal)';
    final alwaysShow = both == null ? '' : ' - ${both.text}';
    final notationString = notations.isEmpty ? '' : ' ($notations)';

    return FlashCard(
        primary: _sanitize('$englishSide$notationString$alwaysShow'),
        back: _sanitize(back + alwaysShow),
        audio: audioFileName,
        phrase: this);
  }

  bool isMissingMedia({required String rootPath}) {
    return _hasAudio && !File(join([rootPath, audioFileName])).existsSync();
  }

  Future<void> downloadMedia({required String rootPath}) async {
    if (!isMissingMedia(rootPath: rootPath)) {
      return;
    }

    final audioFile = File(join([rootPath, audioFileName]));

    var audio = await retry('Fetching audio: $audioUrl', () async {
      var response = await http.get(Uri.parse(audioUrl));
      return response.bodyBytes;
    });

    if (audio != null) {
      audioFile.writeAsBytesSync(audio);
    }
  }

  // We use pipe as the seperator, so if it shows up in the card, we convert it to the HTML entity.
  static String _sanitize(String text) {
    return text.replaceAll('|', '&vert;');
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PhraseNotationEntity {
  final int id;
  final String tooltipLabel;
  final String tooltipDescription;

  PhraseNotationEntity(this.id, this.tooltipLabel, this.tooltipDescription);

  factory PhraseNotationEntity.fromJson(Map<String, dynamic> json) =>
      _$PhraseNotationEntityFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LessonEntity {
  final Map<int, Phrase> phrases;
  final Map<int, DashboardLesson> lessons;
  final Map<int, PhraseNotationEntity> notations;

  DashboardLesson get lesson => lessons.values.single;

  LessonEntity(this.phrases, this.lessons, this.notations) {
    assert(lessons.length == 1,
        'lesson contains multiple lessons: ${lessons.values.map((e) => e.name).join('\n')}');
  }

  factory LessonEntity.fromJson(Map<String, dynamic> json) =>
      _$LessonEntityFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LessonRoot {
  final LessonEntity entities;

  LessonRoot(this.entities);

  factory LessonRoot.fromJson(Map<String, dynamic> json) =>
      _$LessonRootFromJson(json);
}
