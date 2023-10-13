import { URL } from "node:url";
import { retry, rocketFetchHome, rocketFetchLesson } from "./rocketFetch";
import { DashboardLesson, LessonEntity, LessonType, WritingSystemId } from "./types";
import { join } from 'node:path';

import { writeFileSync, mkdirSync } from 'node:fs';

interface LessonCards {
    cards: string
    meta: DashboardLesson
}

const mediaPath = 'audio';
const deckPath = 'decks';
const skipDownload = true;
const finishedModules = 2;

mkdirSync(mediaPath, { recursive: true });
mkdirSync(deckPath, { recursive: true });

function convertToList<T>(data: Record<number, T>) {
    return Object.getOwnPropertyNames(data).sort().map(id => data[parseInt(id)])
}

(async function() {
    const { dashboard, entities } = (await rocketFetchHome())!;

    const amount = undefined;

    const lessons = convertToList(entities.lessons);

    const promises = dashboard.modules.slice(0, amount).flatMap(module => 
        module.grouped_lessons.slice(0, amount).flatMap(lessonGroup => 
            lessonGroup.lessons.slice(0, amount).flatMap(async (lessonId) => {
                const response = await rocketFetchLesson(lessonId);
                if (!response) {
                    return undefined;
                }

                return addLesson(response.entities, lessons.find(lesson => lesson.id == lessonId)!);
            })
        )
    )

    const allLessons =  (await Promise.all(promises)).filter(x => x) as LessonCards[];
    writeSelection(allLessons, 'all');

    const survivalKit = allLessons.filter(lesson => lesson.meta.lesson_type_id == LessonType.SurvivalKit);
    const withoutSurvival = allLessons.filter(lesson => lesson.meta.lesson_type_id != LessonType.SurvivalKit);

    writeSelection(survivalKit, 'survival_kit');
    writeSelection(withoutSurvival, 'lessons');

    writeSelection(getCompletedModules(finishedModules, withoutSurvival), 'completed');
})();

function getCompletedModules(amountCompleted: number, lessons: LessonCards[]): LessonCards[] {
    const orderedModuleIds = lessons.map(lesson => lesson.meta.module_id);

    let unique = new Array<number>();
    orderedModuleIds.forEach(id => {
        if (!unique.includes(id)) {
            unique.push(id)
        }
    })

    const completedModules = unique.slice(0, amountCompleted);

    return lessons.filter(lesson => completedModules.includes(lesson.meta.module_id))
}

function writeSelection(cards: LessonCards[], filename: string) {
    const header = '#separator:Pipe\n#html:true\n#tags column: 3\n';

    writeFileSync(join(deckPath, `${filename}.txt`), header + cards.map(card => card.cards).join('\n'));
}

async function addLesson(lesson: LessonEntity, meta: DashboardLesson): Promise<LessonCards> {
    const phrases = convertToList(lesson.phrases);
    const tags = [meta.slug, slugify(meta.name)].join('-');

    const cardPromises = phrases.flatMap(async (phrase) => {
        const english = phrase.strings.find(english => english.writing_system_id == WritingSystemId.english)!;
        const spanish = phrase.strings.find(english => english.writing_system_id == WritingSystemId.spanish)!;
        let fileName : string | undefined = undefined;

        if (phrase.audio_url) {
            const url = new URL(phrase.audio_url);
            fileName = url.pathname.split('/').slice(-1)[0];

            if (!skipDownload) {
                const audio = await retry(`Fetching audio: ${phrase.audio_url}`, async() => await (await (await fetch(phrase.audio_url)).blob()).arrayBuffer());
                if (audio) {
                    writeFileSync(join('./audio', fileName), Buffer.from(audio));
                }
            }
        }

        if (!english?.text || !spanish?.text) {
            console.log(english?.text || spanish?.text + 'SLUG' + meta.slug);
            return undefined;
        }

        return {
            english: english.text,
            spanish: spanish.text,
            audio: fileName
        }
    })

    const cards = (await Promise.all(cardPromises)).filter(x => x);

    return {
        cards: cards.map(card => {
            const sound = card!.audio ? `[sound:${card!.audio}]` : '';
            return `${card!.english}|${card!.spanish}${sound}|${tags}`;
        }).join('\n'),
        meta
    }
}

function slugify(text)
{
  return text.toString().toLowerCase()
    .replace(/\s+/g, '-')           // Replace spaces with -
    .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
    .replace(/\-\-+/g, '-')         // Replace multiple - with single -
    .replace(/^-+/, '')             // Trim - from start of text
    .replace(/-+$/, '');            // Trim - from end of text
}