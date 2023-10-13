import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

@JsonEnum(valueField: 'value')
enum WritingSystemId {
  spanish(5),
  english(1);

  const WritingSystemId(this.value);

  final int value;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PhraseString {
  final int id;
  final String text;
  final WritingSystemId writingSystemId;

  PhraseString(this.id, this.text, this.writingSystemId);

  factory PhraseString.fromJson(Map<String, dynamic> json) =>
      _$PhraseStringFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Phrase {
  final String audioUrl;
  final List<PhraseString> strings;

  Phrase(this.audioUrl, this.strings);

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LessonEntity {
  final Map<int, Phrase> phrases;

  LessonEntity(this.phrases);

  factory LessonEntity.fromJson(Map<String, dynamic> json) =>
      _$LessonEntityFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LessonRoot {
  final LessonEntity entities;

  LessonRoot(this.entities);

  factory LessonRoot.fromJson(Map<String, dynamic> json) =>
      _$LessonRootFromJson(json);
}
