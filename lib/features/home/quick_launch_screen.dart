import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/progress_service.dart';
import '../../tab_notifier.dart';

class QuickLaunchScreen extends StatelessWidget {
  const QuickLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.read<ProgressService>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Psycho Prep',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text('בחר תחום להתאמן', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 32),
              _LaunchCard(
                icon: Icons.menu_book,
                title: 'אוצר מילים',
                subtitle: '${progress.masteredCount} מילים נרכשו',
                color: theme.colorScheme.primary,
                onTap: () => context.read<TabNotifier>().setTab(2),
              ),
              const SizedBox(height: 16),
              _LaunchCard(
                icon: Icons.edit,
                title: 'תרגול',
                subtitle: '${progress.totalAttempted} שאלות נענו',
                color: const Color(0xFF42A5F5),
                onTap: () => context.read<TabNotifier>().setTab(1),
              ),
              const SizedBox(height: 16),
              _LaunchCard(
                icon: Icons.bolt,
                title: 'Math Sprint',
                subtitle: 'שיא: ${progress.bestScore} / 20',
                color: const Color(0xFF66BB6A),
                onTap: () => context.read<TabNotifier>().setTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LaunchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
