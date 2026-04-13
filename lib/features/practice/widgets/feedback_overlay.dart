import 'package:flutter/material.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final VoidCallback onNext;
  final bool isLastQuestion;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onNext,
    this.isLastQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF66BB6A) : const Color(0xFFEF5350);
    final bgColor = isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: color, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'נכון!' : 'לא נכון',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: const TextStyle(fontSize: 15, height: 1.5),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isLastQuestion ? 'סיום' : 'השאלה הבאה',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
