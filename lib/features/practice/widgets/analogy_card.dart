import 'package:flutter/material.dart';

import '../../../models/question.dart';

/// Renders analogy questions in the format:  A : B :: ? : ?
/// where options are word pairs (e.g. "גדול : קטן")
class AnalogyCard extends StatelessWidget {
  final Question question;
  final int? selectedIndex;
  final bool answered;
  final void Function(int index) onOptionTap;

  const AnalogyCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.answered,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Analogy header: "A : B :: ? : ?"
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(
            children: [
              Text(
                '${question.question} :: ? : ?',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'בחר את הזוג המתאים',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Pair options
        ...List.generate(question.options.length, (i) => _PairOption(
          text: question.options[i],
          index: i,
          selectedIndex: selectedIndex,
          correctIndex: question.correctIndex,
          answered: answered,
          onTap: answered ? null : () => onOptionTap(i),
        )),
      ],
    );
  }
}

class _PairOption extends StatelessWidget {
  final String text;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback? onTap;

  const _PairOption({
    required this.text,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = const Color(0xFF333333);

    if (answered) {
      if (index == correctIndex) {
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF66BB6A);
        textColor = const Color(0xFF2E7D32);
      } else if (index == selectedIndex) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFEF5350);
        textColor = const Color(0xFFC62828);
      }
    } else if (index == selectedIndex) {
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFF57C00);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 8),
            if (answered && index == correctIndex)
              const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 20),
            if (answered && index == selectedIndex && index != correctIndex)
              const Icon(Icons.cancel, color: Color(0xFFEF5350), size: 20),
          ],
        ),
      ),
    );
  }
}
