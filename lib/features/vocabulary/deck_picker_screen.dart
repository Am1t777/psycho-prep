import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/data_service.dart';
import '../../services/progress_service.dart';
import '../../models/vocab_word.dart';
import 'flashcard_screen.dart';

class DeckPickerScreen extends StatefulWidget {
  const DeckPickerScreen({super.key});

  @override
  State<DeckPickerScreen> createState() => _DeckPickerScreenState();
}

class _DeckPickerScreenState extends State<DeckPickerScreen> {
  String _language = 'hebrew'; // 'hebrew' | 'english'
  String _level = 'all'; // 'all' | 'easy' | 'medium' | 'hard'

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataService>();
    final progress = context.read<ProgressService>();
    final theme = Theme.of(context);

    final allWords = _language == 'hebrew' ? data.hebrewWords : data.englishWords;
    final filtered = _level == 'all'
        ? allWords
        : allWords.where((w) => w.level == _level).toList();

    // Sort: learning first, then unseen, then mastered
    final deck = _sortDeck(filtered, progress);
    final masteredInDeck = filtered.where((w) => progress.getWordStatus(w.id) == 'mastered').length;

    return Scaffold(
      appBar: AppBar(title: const Text('אוצר מילים')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector
            Text('שפה', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _ChoiceChip(
                  label: 'עברית',
                  selected: _language == 'hebrew',
                  onTap: () => setState(() => _language = 'hebrew'),
                ),
                const SizedBox(width: 10),
                _ChoiceChip(
                  label: 'English',
                  selected: _language == 'english',
                  onTap: () => setState(() => _language = 'english'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Level selector
            Text('רמה', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _ChoiceChip(label: 'הכל', selected: _level == 'all', onTap: () => setState(() => _level = 'all')),
                const SizedBox(width: 8),
                _ChoiceChip(label: 'קל', selected: _level == 'easy', onTap: () => setState(() => _level = 'easy')),
                const SizedBox(width: 8),
                _ChoiceChip(label: 'בינוני', selected: _level == 'medium', onTap: () => setState(() => _level = 'medium')),
                const SizedBox(width: 8),
                _ChoiceChip(label: 'קשה', selected: _level == 'hard', onTap: () => setState(() => _level = 'hard')),
              ],
            ),
            const SizedBox(height: 32),
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'כרטיסים', value: '${filtered.length}'),
                  _Stat(label: 'נרכשו', value: '$masteredInDeck', color: const Color(0xFF66BB6A)),
                  _Stat(label: 'ללמוד', value: '${filtered.length - masteredInDeck}', color: theme.colorScheme.primary),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: deck.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FlashcardScreen(
                              words: deck,
                              title: _language == 'hebrew' ? 'עברית' : 'English',
                            ),
                          ),
                        ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  deck.isEmpty ? 'אין כרטיסים' : 'התחל (${deck.length} כרטיסים)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<VocabWord> _sortDeck(List<VocabWord> words, ProgressService progress) {
    final learning = <VocabWord>[];
    final unseen = <VocabWord>[];
    final mastered = <VocabWord>[];
    for (final w in words) {
      final status = progress.getWordStatus(w.id);
      if (status == 'learning') {
        learning.add(w);
      } else if (status == 'mastered') {
        mastered.add(w);
      } else {
        unseen.add(w);
      }
    }
    return [...learning, ...unseen, ...mastered];
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFFE65100),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
