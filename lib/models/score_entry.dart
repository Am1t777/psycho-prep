import 'package:hive/hive.dart';

part 'score_entry.g.dart';

@HiveType(typeId: 0)
class ScoreEntry extends HiveObject {
  @HiveField(0)
  final int score; // out of 20

  @HiveField(1)
  final DateTime date;

  ScoreEntry({required this.score, required this.date});
}
