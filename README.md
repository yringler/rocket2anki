# Rocket -> anki import file

## Overview
This is a quick little node script I threw together to create anki decks for rocket. It also uses the rocket audio for all vocabulary. Note that it isn't easy to use unless you happen to be a web developer. It also isn't particularly well written;
I kinda just slapped it together.

You get a deck file, which has a bunch of decks inside it
1. All lessons except survival kit
2. What you're up to - I added this before I added subdecks, probably not going to use it anymore
3. All survival kit lessons

Each deck has a sub decks for each module, and each sub deck has another subdeck for each lesson in the module.
So it's very easy to review a lesson, and when you know a module, to review the whole module.
It would be nice to be able to have a single review across only modules that you finished. It looks like flags or tags would be great for that; I haven't checked yet.

## Usage

### Running it
1. Create a config.json based on the sample config, and put in your credentials. If you log in to your account, you'll be able
to get them from the network inspector for the API requests.
2. Note you'll have to get the product ID; I didn't bother automating that, because going through a single product takes enough time that modifying a config each time is fine. If you open up the dashboard, it's in the URL - eg, [spanish lesson one][spanish dashboard]
3. Run `yarn build` from the script folder

### Using the decks
1. You need to have [anki][anki home] installed on your computer. 
2. Copy over the audio from the audio folder (after you run the script) into ankis audio folder. On Windows, this will be something like `USERNAME\AppData\Roaming\Anki2\User 1\collection.media`, on apple `USERNAME/ANKI/User1`
3. Open anki, and import the generated decks from `decks/allLANGUAGE.txt`

## Limitations
1. This script is not able to download content you didn't pay for. (Yes, I checked. Purely for research purposes.) I mean, you can probably figure something out, but that's probably a federal crime.
2. It can only download one language level at a time. For example, to download the whole rocket spanish, you'd have to run it 3 times, once for each level.

[anki home]: https://apps.ankiweb.net/
[spanish dashboard]: https://app.rocketlanguages.com/members/products/1/dashboard