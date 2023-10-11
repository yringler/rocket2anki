import 'package:json_annotation/json_annotation.dart';

part 'dashboard.g.dart';

@JsonEnum(valueField: 'value')
enum LessonGroupType implements Comparable<LessonGroupType> {
  interactive("interactive-audio-course", 1),
  language("language-and-culture", 2),
  survivalKit("survival-kit", 3);

  const LessonGroupType(this.value, this.sort);

  final String value;
  final int sort;

  @override
  int compareTo(LessonGroupType other) {
    return sort.compareTo(other.sort);
  }
}

@JsonEnum(valueField: 'value')
enum LessonType {
  language(1),
  culture(2),
  survivalKit(3);

  const LessonType(this.value);

  final int value;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LessonGroup {
  final LessonGroupType code;
  final List<int> lessons;

  LessonGroup(this.code, this.lessons);

  factory LessonGroup.fromJson(Map<String, dynamic> json) =>
      _$LessonGroupFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CourseModule {
  final int id;
  final int courseId;
  final double number;
  final List<LessonGroup> groupedLessons;

  late List<int> _orderedLessons;

  int numberOfLesson(int lessonId) => _orderedLessons.indexOf(lessonId);

  CourseModule(this.id, this.courseId, this.number, this.groupedLessons) {
    groupedLessons.sort((a, b) => a.code.compareTo(b.code));
    _orderedLessons =
        groupedLessons.expand((element) => element.lessons).toList();
  }

  factory CourseModule.fromJson(Map<String, dynamic> json) =>
      _$CourseModuleFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Dashboard {
  final List<CourseModule> modules;

  Dashboard(this.modules);
  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DashboardLesson {
  final int id;
  final int moduleId;
  final LessonType lessonTypeId;
  final String name;
  final String slug;

  DashboardLesson(
      this.id, this.moduleId, this.lessonTypeId, this.name, this.slug);
  factory DashboardLesson.fromJson(Map<String, dynamic> json) =>
      _$DashboardLessonFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DashboardEntity {
  final Map<int, DashboardLesson> lessons;

  DashboardEntity(this.lessons);
  factory DashboardEntity.fromJson(Map<String, dynamic> json) =>
      _$DashboardEntityFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DashboardRoot {
  final Dashboard dashboard;
  final DashboardEntity entities;

  DashboardRoot(this.dashboard, this.entities);
  factory DashboardRoot.fromJson(Map<String, dynamic> json) =>
      _$DashboardRootFromJson(json);
}
