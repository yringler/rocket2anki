# Rocket -> anki import file

## tl;dr

Rocket vocab from purchased classes in anki! Do you use Windows? **Download [tool here][tool windows build]**. Other systems? Keep reading.

## Purpose
Rocket languages is great, but it doesn't have a review system. It's not as critical for the core class content (which
I find I remember anyway), but for additional vocab in language & culture, and especially survival kit - how are you
supposed to remember all that? You could keep on going back to the lessons and looking them over, or going through the
flash cards again - but that means going to a lot of different places, and looking at a lot of things you already know
cold.

Anki is a very powerful spaced repetition flash card software. You can use it as a *single* entry point for all your vocab
review. If you're struggling with something, you'll see it more often, if you know it well, *less often*.

This script creates organized decks (and subdecks) along with audio, so as you review you'll hear the native speaker.

Note that the generated content uses copyrighted rocket languages content and media, and distribution is illegal and
immoral. This is only meant to be used by people who have purchased the excellent rocket language courses.

See https://www.rocketlanguages.com/terms, under the "Use" clause.
 
Anki also requires permission from the owner of the intellectual property to share decks.
See https://ankiweb.net/account/terms, under the "Intellectual Property" clause.
So don't share any decks you create!

## Overview
This is a quick little ~~node~~ dart script I threw together to create anki decks for rocket. It also uses the rocket audio for all vocabulary.

You get a text file for each product you purchased, which each contain a single deck. The deck is subdivided into modules (+ survival kit).
So it's very easy to review a lesson, and when you know a module, to review the whole module.

## Usage

### Running it
If you're on windows, you can download an exe from [github][tool windows build].
Run it with `rocket2anki.exe -e EMAIL -p PASSWORD`

If you don't pass in a correct email and password, the script will prompt you for your username and password.

Or, you can run `dart pub get` from the script folder, and then `dart ./bin/index.dart -e EMAIL -p PASSWORD`.
(You'll have to install the [dart sdk][dart sdk download page] to run dart commands.)

### Using the decks
See [the anki import docs][anki import]

1. You need to have [anki][anki home] installed on your computer. 
2. Copy over the audio from the audio folder (after you run the script) into anki's audio folder.
  - On Windows, this will be something like `USERNAME\AppData\Roaming\Anki2\User 1\collection.media`,
  - on apple `USERNAME/ANKI/User1/collection.media`
  - on linux: `cp audio/* "~/.var/app/net.ankiweb.Anki/data/Anki2/User 1/collection.media/"`
4. Open anki, and import the generated decks' text files from `decks/PRODUCTNAME.txt`

## Limitations
1. This script is not able to download content you didn't pay for. (Yes, I checked. Purely for research purposes.) I mean, you can probably figure something out, but that's probably a federal crime.
4. No gui UI. It does have a command line UI, though.

[anki home]: https://apps.ankiweb.net/
[dart sdk download page]: https://dart.dev/get-dart
[anki import]: https://docs.ankiweb.net/importing/text-files.html#importing-media
[tool windows build]: https://github.com/yringler/rocket2anki/releases/latest
