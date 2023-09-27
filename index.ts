import { URL } from "node:url";
import { rocketFetchHome, rocketFetchLesson } from "./rocketFetch";
import { DashboardLesson, LessonEntity, WritingSystemId } from "./types";
import fetch from "node-fetch";
import {join} from 'node:path';

import { writeFileSync } from 'node:fs';

(async function() {
    const { dashboard, entities } = await rocketFetchHome();

    const amount = 1;

    const promises = dashboard.modules.slice(0, amount).flatMap(module => 
        module.grouped_lessons.slice(0, amount).flatMap(lessonGroup => 
            lessonGroup.lessons.slice(0, amount).flatMap(async (lessonId) => {
                const { entities: lesson} = await rocketFetchLesson(lessonId);
                await addLesson(lesson, entities.lessons.find(lesson => lesson.id == lessonId)!);
            })
        )
    )

    await Promise.all(promises);
})();

async function addLesson(lesson: LessonEntity, meta: DashboardLesson) {
    const cardPromises = lesson.phrases.flatMap(async (phrase) => {
        const english = phrase.strings.find(english => english.writing_system_id == WritingSystemId.english)!;
        const spanish = phrase.strings.find(english => english.writing_system_id == WritingSystemId.spanish)!;

        const audio = await (await (await fetch(phrase.audio_url)).blob()).arrayBuffer();
        const url = new URL(phrase.audio_url);
        const fileName = url.pathname.split('/').slice(-1)[0];
        writeFileSync(join('./audio', fileName), Buffer.from(audio));

        return {
            english: english.text,
            spanish: spanish.text,
            audio: fileName
        }
    })

    const cards = await Promise.all(cardPromises);

    return cards.map(card => `${card.spanish}\t${card.english}[sound:${card.audio}]`)
}