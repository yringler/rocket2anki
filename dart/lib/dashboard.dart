enum LessonGroupType { interactive, language }

enum LessonType { Class, Culture, SurvivalKit }

class LessonGroup {
  final LessonGroupType code;
  final List<int> lessons;

  LessonGroup(this.code, this.lessons);
}

class CourseModule {
  final int id;
  final int courseId;
  final int number;
  final List<LessonGroup> groupedLessons;

  CourseModule(this.id, this.courseId, this.number, this.groupedLessons);
}

class Dashboard {
  final List<CourseModule> modules;

  Dashboard(this.modules);
}

class DashboardLesson {
  final int id;
  final int moduleId;
  final LessonType lessonTypeId;
  final String name;
  final String slug;

  DashboardLesson(
      this.id, this.moduleId, this.lessonTypeId, this.name, this.slug);
}

class DashboardEntity {
  final Map<int, DashboardLesson> lessons;

  DashboardEntity(this.lessons);
}

class DashboardRoot {
  final Dashboard dashboard;
  final DashboardEntity entities;

  DashboardRoot(this.dashboard, this.entities);
}
