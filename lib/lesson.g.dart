// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseNotationReference _$PhraseNotationReferenceFromJson(
        Map<String, dynamic> json) =>
    PhraseNotationReference(
      id: (json['id'] as num).toInt(),
      notationId: (json['notation_id'] as num).toInt(),
    );

PhraseString _$PhraseStringFromJson(Map<String, dynamic> json) => PhraseString(
      (json['id'] as num).toInt(),
      json['text'] as String,
      $enumDecode(_$WritingSystemIdEnumMap, json['writing_system_id']),
      (json['notations'] as List<dynamic>)
          .map((e) =>
              PhraseNotationReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

const _$WritingSystemIdEnumMap = {
  WritingSystemId.spanish: 5,
  WritingSystemId.english: 1,
  WritingSystemId.chineseFigures: 9,
  WritingSystemId.pinyin: 8,
  WritingSystemId.japaneseFigures: 3,
  WritingSystemId.japanesePinyin: 4,
  WritingSystemId.koreanFigures: 15,
  WritingSystemId.koreanPinyin: 16,
};

Phrase _$PhraseFromJson(Map<String, dynamic> json) => Phrase(
      json['audio_url'] as String,
      (json['strings'] as List<dynamic>)
          .map((e) => PhraseString.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['literal_string'] as String?,
      (json['id'] as num).toInt(),
    );

PhraseNotationEntity _$PhraseNotationEntityFromJson(
        Map<String, dynamic> json) =>
    PhraseNotationEntity(
      (json['id'] as num).toInt(),
      json['tooltip_label'] as String,
      json['tooltip_description'] as String,
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
      (json['notations'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k),
            PhraseNotationEntity.fromJson(e as Map<String, dynamic>)),
      ),
    );

LessonRoot _$LessonRootFromJson(Map<String, dynamic> json) => LessonRoot(
      LessonEntity.fromJson(json['entities'] as Map<String, dynamic>),
    );
