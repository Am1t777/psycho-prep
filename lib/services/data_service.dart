import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vocab_word.dart';
import '../models/question.dart';

class DataService {
  List<VocabWord> _hebrewWords = [];
  List<VocabWord> _englishWords = [];
  List<Question> _questions = [];

  List<VocabWord> get hebrewWords => _hebrewWords;
  List<VocabWord> get englishWords => _englishWords;
  List<Question> get questions => _questions;

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data.json');
    final data = json.decode(raw) as Map<String, dynamic>;

    _hebrewWords = (data['hebrew_vocab'] as List)
        .map((e) => VocabWord.fromJson(e as Map<String, dynamic>))
        .toList();

    _englishWords = (data['english_vocab'] as List)
        .map((e) => VocabWord.fromJson(e as Map<String, dynamic>))
        .toList();

    _questions = (data['questions'] as List)
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Question> questionsForSubject(String subject) =>
      _questions.where((q) => q.subject == subject).toList();

  List<Question> mixedQuestions() {
    final subjects = ['hebrew_verbal', 'english', 'quantitative'];
    final mixed = <Question>[];
    for (final s in subjects) {
      mixed.addAll(questionsForSubject(s));
    }
    mixed.shuffle();
    return mixed;
  }
}
