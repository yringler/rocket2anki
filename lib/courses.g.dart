// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductLevel _$ProductLevelFromJson(Map<String, dynamic> json) => ProductLevel(
      (json['id'] as num).toInt(),
      (json['course_id'] as num).toInt(),
      json['label'] as String,
      json['is_trial'] as bool,
      (json['product_id'] as num?)?.toInt(),
    );

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['dialect'] as String?,
      (json['product_levels'] as List<dynamic>)
          .map((e) => ProductLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

AllCourses _$AllCoursesFromJson(Map<String, dynamic> json) => AllCourses(
      (json['user_courses'] as List<dynamic>)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
