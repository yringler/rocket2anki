// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonGroup _$LessonGroupFromJson(Map<String, dynamic> json) => LessonGroup(
      $enumDecode(_$LessonGroupTypeEnumMap, json['code']),
      (json['lessons'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

const _$LessonGroupTypeEnumMap = {
  LessonGroupType.interactive: 'interactive-audio-course',
  LessonGroupType.language: 'language-and-culture',
  LessonGroupType.survivalKit: 'survival-kit',
  LessonGroupType.writing: 'writing',
  LessonGroupType.travelogue: 'travelogue',
  LessonGroupType.ebook: 'ebook-chapter',
};

CourseModule _$CourseModuleFromJson(Map<String, dynamic> json) => CourseModule(
      (json['id'] as num).toInt(),
      (json['course_id'] as num).toInt(),
      (json['number'] as num).toDouble(),
      (json['grouped_lessons'] as List<dynamic>)
          .map((e) => LessonGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => Dashboard(
      (json['modules'] as List<dynamic>)
          .map((e) => CourseModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

DashboardLesson _$DashboardLessonFromJson(Map<String, dynamic> json) =>
    DashboardLesson(
      (json['id'] as num).toInt(),
      (json['module_id'] as num).toInt(),
      $enumDecode(_$LessonTypeEnumMap, json['lesson_type_id']),
      json['name'] as String,
      json['slug'] as String?,
      json['number'] as String,
    );

const _$LessonTypeEnumMap = {
  LessonType.language: 1,
  LessonType.culture: 2,
  LessonType.survivalKit: 3,
  LessonType.writing: 6,
  LessonType.chapters: 47,
  LessonType.travelogue: 43,
};

DashboardEntity _$DashboardEntityFromJson(Map<String, dynamic> json) =>
    DashboardEntity(
      (json['lessons'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), DashboardLesson.fromJson(e as Map<String, dynamic>)),
      ),
    );

DashboardRoot _$DashboardRootFromJson(Map<String, dynamic> json) =>
    DashboardRoot(
      Dashboard.fromJson(json['dashboard'] as Map<String, dynamic>),
      DashboardEntity.fromJson(json['entities'] as Map<String, dynamic>),
    );
