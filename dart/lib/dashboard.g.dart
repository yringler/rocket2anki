// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonGroup _$LessonGroupFromJson(Map<String, dynamic> json) => LessonGroup(
      $enumDecode(_$LessonGroupTypeEnumMap, json['code']),
      (json['lessons'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$LessonGroupToJson(LessonGroup instance) =>
    <String, dynamic>{
      'code': _$LessonGroupTypeEnumMap[instance.code]!,
      'lessons': instance.lessons,
    };

const _$LessonGroupTypeEnumMap = {
  LessonGroupType.interactive: 'interactive-audio-course',
  LessonGroupType.language: 'language-and-culture',
};

CourseModule _$CourseModuleFromJson(Map<String, dynamic> json) => CourseModule(
      json['id'] as int,
      json['course_id'] as int,
      json['number'] as int,
      (json['grouped_lessons'] as List<dynamic>)
          .map((e) => LessonGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseModuleToJson(CourseModule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'number': instance.number,
      'grouped_lessons': instance.groupedLessons,
    };

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => Dashboard(
      (json['modules'] as List<dynamic>)
          .map((e) => CourseModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
      'modules': instance.modules,
    };

DashboardLesson _$DashboardLessonFromJson(Map<String, dynamic> json) =>
    DashboardLesson(
      json['id'] as int,
      json['module_id'] as int,
      $enumDecode(_$LessonTypeEnumMap, json['lesson_type_id']),
      json['name'] as String,
      json['slug'] as String,
    );

Map<String, dynamic> _$DashboardLessonToJson(DashboardLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'module_id': instance.moduleId,
      'lesson_type_id': _$LessonTypeEnumMap[instance.lessonTypeId]!,
      'name': instance.name,
      'slug': instance.slug,
    };

const _$LessonTypeEnumMap = {
  LessonType.language: 1,
  LessonType.culture: 2,
  LessonType.survivalKit: 3,
};

DashboardEntity _$DashboardEntityFromJson(Map<String, dynamic> json) =>
    DashboardEntity(
      (json['lessons'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), DashboardLesson.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$DashboardEntityToJson(DashboardEntity instance) =>
    <String, dynamic>{
      'lessons': instance.lessons.map((k, e) => MapEntry(k.toString(), e)),
    };

DashboardRoot _$DashboardRootFromJson(Map<String, dynamic> json) =>
    DashboardRoot(
      Dashboard.fromJson(json['dashboard'] as Map<String, dynamic>),
      DashboardEntity.fromJson(json['entities'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardRootToJson(DashboardRoot instance) =>
    <String, dynamic>{
      'dashboard': instance.dashboard,
      'entities': instance.entities,
    };
