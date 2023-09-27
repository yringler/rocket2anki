export enum LessonGroupType { interactive = "interactive-audio-course", language = "language-and-culture" }

export enum LessonType { Class = 1, Culture = 2,  SurvivalKit = 3 }

export interface LessonGroup {
    code: LessonGroupType
    lessons: number[]
}

export interface CourseModule {
    id: number
    course_id: number
    number: number
    grouped_lessons: LessonGroup[]
}

export interface Dashboard {
    modules: CourseModule[]
}

export interface DashboardLesson {
    id: number
    module_id: number
    lesson_type_id: LessonType
    name: string
    slug: string
}

export interface DashboardEntity {
    lessons: Record<number, DashboardLesson>
}

export interface DashboardRoot {
    dashboard: Dashboard
    entities: DashboardEntity
}