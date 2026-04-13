class Question {
  final String id;
  final String type; // analogy | sentence_completion | reading_comprehension | restatement | word_problem
  final String subject; // hebrew_verbal | english | quantitative
  final String level; // easy | medium | hard
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation; // always Hebrew
  final String? passage; // reading_comprehension only

  const Question({
    required this.id,
    required this.type,
    required this.subject,
    required this.level,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.passage,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        type: json['type'] as String,
        subject: json['subject'] as String,
        level: json['level'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correct_index'] as int,
        explanation: json['explanation'] as String,
        passage: json['passage'] as String?,
      );
}
