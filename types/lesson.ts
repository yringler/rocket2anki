export enum WritingSystemId { spanish = 5, english = 1 }

export interface PhraseString {
    id: number
    text: string
    writing_system_id: WritingSystemId
}

export interface Phrase {
    audio_url: string
    strings: PhraseString[]
}

export interface LessonEntity {
    phrases: Phrase[]
}

export interface LessonRoot {
    entities: LessonEntity
}