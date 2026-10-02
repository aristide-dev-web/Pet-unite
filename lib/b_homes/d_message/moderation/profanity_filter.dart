class ProfanityFilter {
  static final List<String> _bannedWords = [
    // Italiano
    'stronzo',
    'vaffanculo',
    'testa di',
    'merda',
    'bastardo',
    'stupido',
    'scemo',
    'imbecille',
    'cazzo',
    'figa',
    'troia',
    'puttana',
    'menomata',

    // Inglese
    'jerk',
    'screw you',
    'dumbass',
    'shit',
    'bastard',
    'stupid',
    'idiot',
    'moron',
    'd*ck',
    'b*tch',
    'sl*t',
    'disabled',

    // Spagnolo
    'imbécil',
    'vete al diablo',
    'cabrón',
    'estúpido',
    'idiota',
    'tonto',
    'mierda',
    'puta',

    // Francese
    'connard',
    'va te faire voir',
    'con',
    'stupide',
    'idiot',
    'imbécile',
    'merde',
    'salope',

    // Tedesco
    'idiot',
    'leck mich',
    'arschloch',
    'dummkopf',
    'blödmann',
    'scheiße',
    'schlampe',

    // Portoghese
    'idiota', 'vá se danar', 'estúpido', 'burro', 'merda', 'vagabunda',

    // Russo (traslitterato)
    'durak', 'blyad', 'suka', 'idiot', 'tupoy', 'govno',

    // Cinese (semplificato, pinyin)
    'shǎguā', 'gǒu shǐ', 'bèn dàn', 'nǐ zǒu kāi', 'shǎzi',

    // Giapponese (romaji)
    'baka', 'kusottare', 'aho', 'shine', 'kuso', 'busu',
  ];

  static bool containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    return _bannedWords.any((word) => lowerText.contains(word));
  }
}
