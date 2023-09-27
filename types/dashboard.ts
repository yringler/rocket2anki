export enum LessonGroupType { interactive = "interactive-audio-course", language = "language-and-culture" }

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
    name: string
    slug: string
}

export interface DashboardEntity {
    lessons: DashboardLesson[]
}

export interface DashboardRoot {
    dashboard: Dashboard
    entities: DashboardEntity
}