import 'package:hive_flutter/hive_flutter.dart';
import '../models/score_entry.dart';

class ProgressService {
  static const _vocabBox = 'vocab_progress';
  static const _mathBox = 'math_scores';
  static const _practiceBox = 'practice_stats';

  // --- Vocabulary ---

  String? getWordStatus(String wordId) =>
      Hive.box<String>(_vocabBox).get(wordId);

  Future<void> setWordStatus(String wordId, String status) =>
      Hive.box<String>(_vocabBox).put(wordId, status);

  int get masteredCount => Hive.box<String>(_vocabBox)
      .values
      .where((v) => v == 'mastered')
      .length;

  // --- Practice ---

  Map<String, dynamic> _statsFor(String subject) {
    final raw = Hive.box(_practiceBox).get(subject);
    if (raw == null) return {'attempted': 0, 'correct': 0};
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> recordAnswer(String subject, {required bool correct}) async {
    final stats = _statsFor(subject);
    stats['attempted'] = (stats['attempted'] as int) + 1;
    if (correct) stats['correct'] = (stats['correct'] as int) + 1;
    await Hive.box(_practiceBox).put(subject, stats);
  }

  int get totalAttempted {
    int total = 0;
    for (final subject in ['hebrew_verbal', 'english', 'quantitative']) {
      total += _statsFor(subject)['attempted'] as int;
    }
    return total;
  }

  // --- Math Sprint ---

  List<ScoreEntry> get sprintScores {
    final box = Hive.box<ScoreEntry>(_mathBox);
    final scores = box.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scores.take(10).toList();
  }

  int get bestScore => sprintScores.isEmpty ? 0 : sprintScores.first.score;

  Future<void> saveSprintScore(int score) async {
    final entry = ScoreEntry(score: score, date: DateTime.now());
    await Hive.box<ScoreEntry>(_mathBox).add(entry);
  }
}
