import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:dart/rocketfetch.dart';
import 'package:dart/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

@JsonEnum(valueField: 'value')
enum WritingSystemId {
  spanish(5),
  english(1);

  const WritingSystemId(this.value);

  final int value;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PhraseString {
  final int id;
  final String text;
  final WritingSystemId writingSystemId;

  PhraseString(this.id, this.text, this.writingSystemId);

  factory PhraseString.fromJson(Map<String, dynamic> json) =>
      _$PhraseStringFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Phrase {
  final String audioUrl;
  final String? literalString;
  final List<PhraseString> strings;

  String get audioFileName {
    var url = Uri.tryParse(audioUrl);

    if (url == null) {
      return '';
    }

    return slugify(url.pathSegments.last);
  }

  bool get hasAudio => audioFileName.isNotEmpty;

  PhraseString? ofWritingSystem(WritingSystemId writingSystem) {
    return strings
        .where((element) => element.writingSystemId == writingSystem)
        .firstOrNull;
  }

  Phrase(this.audioUrl, this.strings, this.literalString);

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);

  Future<void> downloadMedia({required String rootPath}) async {
    var audio = await retry('Fetching audio: $audioUrl', () async {
      var response = await http.get(Uri.parse(audioUrl));
      return response.bodyBytes;
    });

    if (audio != null) {
      final audioFile = File(join([rootPath, audioFileName]));
      if (!audioFile.existsSync()) {
        audioFile.writeAsBytesSync(audio);
      }
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LessonEntity {
  final Map<int, Phrase> phrases;

  LessonEntity(this.phrases);

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
