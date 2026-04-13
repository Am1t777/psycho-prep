import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/progress_service.dart';
import 'game_screen.dart';

class SprintHubScreen extends StatelessWidget {
  const SprintHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.read<ProgressService>();
    final scores = progress.sprintScores;
    final best = progress.bestScore;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Math Sprint')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Best score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'שיא אישי',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '$best / 20',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Leaderboard
            Text('10 הניקודים הטובים', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: scores.isEmpty
                  ? Center(
                      child: Text(
                        'אין תוצאות עדיין\nהתחל לשחק!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                    )
                  : ListView.separated(
                      itemCount: scores.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final entry = scores[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: i == 0
                                ? const Color(0xFFFFD700)
                                : i == 1
                                    ? Colors.grey.shade400
                                    : i == 2
                                        ? const Color(0xFFCD7F32)
                                        : theme.colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: i < 3 ? Colors.white : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            '${entry.score} / 20',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          trailing: Text(
                            _formatDate(entry.date),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showModeDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('התחל Sprint', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'בחר מצב משחק',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _ModeButton(
              icon: Icons.timer,
              label: 'מתוזמן — 20 דקות',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen(isTimed: true)),
                );
              },
            ),
            const SizedBox(height: 12),
            _ModeButton(
              icon: Icons.all_inclusive,
              label: 'ללא הגבלת זמן',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen(isTimed: false)),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 16, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}
