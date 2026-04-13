import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/data_service.dart';
import 'question_screen.dart';

class SubjectPickerScreen extends StatefulWidget {
  const SubjectPickerScreen({super.key});

  @override
  State<SubjectPickerScreen> createState() => _SubjectPickerScreenState();
}

class _SubjectPickerScreenState extends State<SubjectPickerScreen> {
  String _subject = 'hebrew_verbal';
  bool _isTimed = false;
  int _durationMinutes = 20;

  static const _subjects = [
    ('hebrew_verbal', 'מילולי עברי', Icons.language),
    ('english', 'אנגלית', Icons.translate),
    ('quantitative', 'כמותי', Icons.calculate),
    ('mixed', 'מעורב', Icons.shuffle),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('תרגול')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('תחום', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._subjects.map((s) => _SubjectTile(
              label: s.$2,
              icon: s.$3,
              selected: _subject == s.$1,
              onTap: () => setState(() => _subject = s.$1),
            )),
            const SizedBox(height: 24),
            Text('מצב', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Timed toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SwitchListTile(
                value: _isTimed,
                onChanged: (v) => setState(() => _isTimed = v),
                title: const Text('מתוזמן'),
                subtitle: Text(_isTimed ? '$_durationMinutes דקות' : 'ללא הגבלת זמן'),
                activeColor: theme.colorScheme.primary,
              ),
            ),
            if (_isTimed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('זמן: '),
                  Expanded(
                    child: Slider(
                      value: _durationMinutes.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '$_durationMinutes דק\'',
                      onChanged: (v) => setState(() => _durationMinutes = v.round()),
                    ),
                  ),
                  Text('$_durationMinutes דק\''),
                ],
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('התחל תרגול', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession() {
    final data = context.read<DataService>();
    final questions = _subject == 'mixed'
        ? data.mixedQuestions()
        : data.questionsForSubject(_subject);

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('אין שאלות זמינות לתחום זה')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionScreen(
          questions: questions,
          subject: _subject,
          isTimed: _isTimed,
          durationMinutes: _durationMinutes,
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? theme.colorScheme.primary : const Color(0xFF333333),
              ),
            ),
            const Spacer(),
            if (selected) Icon(Icons.check, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
