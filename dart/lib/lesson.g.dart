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

Map<String, dynamic> _$PhraseStringToJson(PhraseString instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'writing_system_id': _$WritingSystemIdEnumMap[instance.writingSystemId]!,
    };

const _$WritingSystemIdEnumMap = {
  WritingSystemId.spanish: 5,
  WritingSystemId.english: 1,
};

Phrase _$PhraseFromJson(Map<String, dynamic> json) => Phrase(
      json['audio_url'] as String,
      (json['strings'] as List<dynamic>)
          .map((e) => PhraseString.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PhraseToJson(Phrase instance) => <String, dynamic>{
      'audio_url': instance.audioUrl,
      'strings': instance.strings,
    };

LessonEntity _$LessonEntityFromJson(Map<String, dynamic> json) => LessonEntity(
      (json['phrases'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(int.parse(k), Phrase.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$LessonEntityToJson(LessonEntity instance) =>
    <String, dynamic>{
      'phrases': instance.phrases.map((k, e) => MapEntry(k.toString(), e)),
    };

LessonRoot _$LessonRootFromJson(Map<String, dynamic> json) => LessonRoot(
      LessonEntity.fromJson(json['entities'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonRootToJson(LessonRoot instance) =>
    <String, dynamic>{
      'entities': instance.entities,
    };
