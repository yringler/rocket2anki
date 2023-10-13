import config from './config.json';
import { Dashboard, DashboardRoot, LessonRoot } from './types';

export function rocketFetchHome(): Promise<DashboardRoot> {
    return rocketFetchUrl('dashboard?timezone=America%2FNew_York&api_version=2');
}

export function rocketFetchLesson(id: number): Promise<LessonRoot> {
    return rocketFetchUrl(`lesson/${id}`)
}

async function rocketFetchUrl<T>(path: string): Promise<T> {
    const response = await fetch(`https://app.rocketlanguages.com/api/v2/product/1/${path}`, {
        "headers": {
          "accept": "application/json, text/plain, */*",
          "accept-language": "en-US,en;q=0.9",
          "authorization": `Bearer ${config.bearer}`,
          "cache-control": "no-cache",
          "pragma": "no-cache",
          "sec-ch-ua": "\"Google Chrome\";v=\"117\", \"Not;A=Brand\";v=\"8\", \"Chromium\";v=\"117\"",
          "sec-ch-ua-mobile": "?0",
          "sec-ch-ua-platform": "\"Windows\"",
          "sec-fetch-dest": "empty",
          "sec-fetch-mode": "cors",
          "sec-fetch-site": "same-origin",
          "x-xsrf-token": config.xsrf,
          "cookie": config.cookie,
          "Referer": "https://app.rocketlanguages.com/members/products/1/lesson/5454",
          "Referrer-Policy": "strict-origin-when-cross-origin"
        },
        "body": null,
        "method": "GET"
      });

      return response.json() as T;
}