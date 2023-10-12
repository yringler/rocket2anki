// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseString _$PhraseStringFromJson(Map<String, dynamic> json) => PhraseString(
      json['id'] as int,
      json['text'] as String,
      $enumDecode(_$WritingSystemIdEnumMap, json['writing_system_id']),
    );

const _$WritingSystemIdEnumMap = {
  WritingSystemId.spanish: 5,
  WritingSystemId.english: 1,
  WritingSystemId.chineseFigures: 9,
  WritingSystemId.pinyin: 8,
};

Phrase _$PhraseFromJson(Map<String, dynamic> json) => Phrase(
      json['audio_url'] as String,
      (json['strings'] as List<dynamic>)
          .map((e) => PhraseString.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['literal_string'] as String?,
    );

LessonEntity _$LessonEntityFromJson(Map<String, dynamic> json) => LessonEntity(
      (json['phrases'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(int.parse(k), Phrase.fromJson(e as Map<String, dynamic>)),
      ),
      (json['lessons'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), DashboardLesson.fromJson(e as Map<String, dynamic>)),
      ),
    );

LessonRoot _$LessonRootFromJson(Map<String, dynamic> json) => LessonRoot(
      LessonEntity.fromJson(json['entities'] as Map<String, dynamic>),
    );
