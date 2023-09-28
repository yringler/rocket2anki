import { URL } from "node:url";
import { retry, rocketFetchHome, rocketFetchLesson } from "./rocketFetch";
import { DashboardLesson, LessonEntity, LessonType, WritingSystemId } from "./types";
import { join } from 'node:path';

import { writeFileSync, mkdirSync } from 'node:fs';

interface LessonCards {
    cards: string[]
    meta: DashboardLesson
}

interface DeckConfig {
    cardsWithDeck: string
    lessons: LessonCards[]
    deckName: string
}

const mediaPath = 'audio';
const deckPath = 'decks';
const language = 'spanish';
const seperator = '|';
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

    const allLessons = getDeck((await Promise.all(promises)).filter(x => x) as LessonCards[], 'all');

    const survivalKit = getDeck(allLessons.lessons.filter(lesson => lesson.meta.lesson_type_id == LessonType.SurvivalKit), 'survival_kit')
    const withoutSurvival = getDeck(allLessons.lessons.filter(lesson => lesson.meta.lesson_type_id != LessonType.SurvivalKit), 'lessons')
    const completed = getDeck(getCompletedModules(finishedModules, withoutSurvival.lessons), 'completed')

    writeSelection({
        deckName: 'all',
        lessons: completed.lessons.concat(survivalKit.lessons).concat(withoutSurvival.lessons),
        cardsWithDeck: [completed.cardsWithDeck, survivalKit.cardsWithDeck, withoutSurvival.cardsWithDeck].join('\n')
    })
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

function getDeck(lessons: LessonCards[], deckName: string): DeckConfig {
    const cardsWithDeck = lessons.flatMap(({cards, meta}) => cards.map(card => {
        const subdeckName = [meta.slug, slugify(meta.name)].join('-');
        return `${card}${seperator}${language}${deckName}(parent)::${subdeckName}`;
    })).join('\n')

    return {
        lessons,
        cardsWithDeck,
        deckName
    }
}

function writeSelection(deck: DeckConfig) {
    const header = '#separator:Pipe\n#html:true\n#tags column: 4\n#deck column: 3\n'
    writeFileSync(join(deckPath, `${deck.deckName}.txt`), header + deck.cardsWithDeck);
}

async function addLesson(lesson: LessonEntity, meta: DashboardLesson): Promise<LessonCards> {
    const phrases = convertToList(lesson.phrases);

    const cardPromises = phrases.flatMap(async (phrase) => {
        const english = phrase.strings.find(english => english.writing_system_id == WritingSystemId.english)!;
        const spanish = phrase.strings.find(english => english.writing_system_id == WritingSystemId.spanish)!;
        let fileName : string | undefined = undefined;

        if (phrase.audio_url) {
            const url = new URL(phrase.audio_url);
            fileName = slugify(decodeURIComponent(url.pathname.split('/').slice(-1)[0]));

            if (!skipDownload) {
                const audio_url = phrase.audio_url;
                const audio = await retry(`Fetching audio: ${audio_url}`, async() => await (await (await fetch(audio_url)).blob()).arrayBuffer());
                if (audio) {
                    writeFileSync(join('./audio', fileName), Buffer.from(audio));
                }
            }
        }

        if (!english?.text || !spanish?.text) {
            console.log(english?.text || spanish?.text + 'SLUG' + meta.slug);
            return undefined;
        }

        function sanatize(text: string) {
            return text.replace('|', '&vert;');
        }

        return {
            english: sanatize(english.text),
            spanish: sanatize(spanish.text),
            audio: fileName
        }
    })

    const cards = (await Promise.all(cardPromises)).filter(x => x);

    return {
        cards: cards.map(card => {
            const sound = card!.audio ? `[sound:${card!.audio}]` : '';
            return `${card!.english}${seperator}${card!.spanish}${sound}${seperator}`;
        }),
        meta
    }
}

function slugify(text: string)
{
  return text.toString().toLowerCase()
    .replace(/\s+/g, '-')           // Replace spaces with -
    .replace(/[^\w\-.]+/g, '')       // Remove all non-word chars (allow periods - needed for extensions, and we use this for filenames)
    .replace(/\-\-+/g, '-')         // Replace multiple - with single -
    .replace(/^-+/, '')             // Trim - from start of text
    .replace(/-+$/, '');            // Trim - from end of text
}