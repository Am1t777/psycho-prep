import 'package:flutter/material.dart';

import '../../../models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedIndex;
  final bool answered;
  final void Function(int index) onOptionTap;

  const QuestionCard({
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
        // Question text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Text(
            question.question,
            style: const TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 16),
        // Options
        ...List.generate(question.options.length, (i) => _OptionTile(
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

class _OptionTile extends StatelessWidget {
  final String text;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback? onTap;

  const _OptionTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
                textAlign: TextAlign.right,
              ),
            ),
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
