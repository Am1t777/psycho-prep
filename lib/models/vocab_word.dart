class VocabWord {
  final String id;
  final String word;
  final String definition;
  final String example;
  final String level; // easy | medium | hard
  final String category;

  const VocabWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.example,
    required this.level,
    required this.category,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) => VocabWord(
        id: json['id'] as String,
        word: json['word'] as String,
        definition: json['definition'] as String,
        example: json['example'] as String,
        level: json['level'] as String,
        category: json['category'] as String,
      );
}
