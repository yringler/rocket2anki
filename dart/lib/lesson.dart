enum WritingSystemId {
  spanish(5),
  english(1);

  const WritingSystemId(this.value);

  final int value;
}

class PhraseString {
  final int id;
  final String text;
  final WritingSystemId writingSystemId;

  PhraseString(this.id, this.text, this.writingSystemId);
}

class Phrase {
  final String audioUrl;
  final List<PhraseString> strings;

  Phrase(this.audioUrl, this.strings);
}

class LessonEntity {
  final Map<int, Phrase> phrases;

  LessonEntity(this.phrases);
}

class LessonRoot {
  final LessonEntity entities;

  LessonRoot(this.entities);
}
