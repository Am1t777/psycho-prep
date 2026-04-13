import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/progress_service.dart';
import 'math_generator.dart';

class ResultsScreen extends StatefulWidget {
  final List<MathProblem> problems;
  final List<int?> userAnswers;
  final int score;

  const ResultsScreen({
    super.key,
    required this.problems,
    required this.userAnswers,
    required this.score,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isNewBest = false;

  @override
  void initState() {
    super.initState();
    final progress = context.read<ProgressService>();
    _isNewBest = widget.score > progress.bestScore;
    progress.saveSprintScore(widget.score);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.problems.length;
    final pct = (widget.score / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('תוצאות'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Score summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Column(
              children: [
                if (_isNewBest) ...[
                  const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 36),
                  const SizedBox(height: 4),
                  const Text(
                    'שיא חדש!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${widget.score} / $total',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '$pct% נכון',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Per-question review
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: widget.problems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = widget.problems[i];
                final userIdx = widget.userAnswers[i];
                final correct = userIdx == p.correctIndex;
                final skipped = userIdx == null;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: skipped
                        ? Colors.grey.shade300
                        : correct
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFEF5350),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(p.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'נכון: ${p.options[p.correctIndex]}',
                        style: const TextStyle(color: Color(0xFF2E7D32)),
                      ),
                      if (!correct && !skipped)
                        Text(
                          'ענית: ${p.options[userIdx!]}',
                          style: const TextStyle(color: Color(0xFFC62828)),
                        ),
                      if (skipped)
                        const Text('לא נענה', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  trailing: Icon(
                    skipped
                        ? Icons.remove_circle_outline
                        : correct
                            ? Icons.check_circle
                            : Icons.cancel,
                    color: skipped
                        ? Colors.grey
                        : correct
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFEF5350),
                  ),
                );
              },
            ),
          ),
          // Actions — pop back to SprintHub (pushReplacement was used so pop goes to Hub)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('חזור לתפריט', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
