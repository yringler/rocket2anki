import 'package:json_annotation/json_annotation.dart';

part 'courses.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ProductLevel {
  final int id;
  final int courseId;
  final String label;
  final bool isTrial;
  final int productId;

  ProductLevel(
      this.id, this.courseId, this.label, this.isTrial, this.productId);

  factory ProductLevel.fromJson(Map<String, dynamic> json) =>
      _$ProductLevelFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Course {
  final int id;
  final String name;
  final String? dialect;
  final List<ProductLevel> productLevels;

  Course(this.id, this.name, this.dialect, this.productLevels);
  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class AllCourses {
  final List<Course> userCourses;

  AllCourses(this.userCourses);
  factory AllCourses.fromJson(Map<String, dynamic> json) =>
      _$AllCoursesFromJson(json);
}
