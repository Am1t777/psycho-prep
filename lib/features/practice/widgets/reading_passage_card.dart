import 'package:flutter/material.dart';

import '../../../models/question.dart';
import 'question_card.dart';

/// Shows a scrollable passage above the question for reading_comprehension type.
class ReadingPassageCard extends StatelessWidget {
  final Question question;
  final int? selectedIndex;
  final bool answered;
  final void Function(int index) onOptionTap;

  const ReadingPassageCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.answered,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Passage card
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            border: Border.all(color: const Color(0xFFF57C00).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Text(
              question.passage ?? '',
              style: const TextStyle(fontSize: 15, height: 1.6),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Standard question card below the passage
        QuestionCard(
          question: question,
          selectedIndex: selectedIndex,
          answered: answered,
          onOptionTap: onOptionTap,
        ),
      ],
    );
  }
}
