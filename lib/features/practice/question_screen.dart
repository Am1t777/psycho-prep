import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question.dart';
import '../../services/progress_service.dart';
import 'widgets/question_card.dart';
import 'widgets/analogy_card.dart';
import 'widgets/reading_passage_card.dart';
import 'widgets/feedback_overlay.dart';

class QuestionScreen extends StatefulWidget {
  final List<Question> questions;
  final String subject;
  final bool isTimed;
  final int durationMinutes;

  const QuestionScreen({
    super.key,
    required this.questions,
    required this.subject,
    required this.isTimed,
    required this.durationMinutes,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _correctCount = 0;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isTimed) {
      _secondsLeft = widget.durationMinutes * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 0) {
          _timer?.cancel();
          _showSummary();
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Question get _current => widget.questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex >= widget.questions.length - 1;

  void _onOptionTap(int index) {
    if (_answered) return;
    final correct = index == _current.correctIndex;
    context.read<ProgressService>().recordAnswer(
      _current.subject == 'mixed' ? widget.subject : _current.subject,
      correct: correct,
    );
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (correct) _correctCount++;
    });
  }

  void _onNext() {
    if (_isLastQuestion) {
      _showSummary();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _answered = false;
    });
  }

  void _showSummary() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('סיום תרגול'),
        content: Text(
          'ענית נכון על $_correctCount מתוך ${widget.questions.length} שאלות.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to subject picker
            },
            child: const Text('חזור'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _current;

    return Scaffold(
      appBar: AppBar(
        title: Text('שאלה ${_currentIndex + 1} / ${widget.questions.length}'),
        actions: [
          if (widget.isTimed)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _formatTime(_secondsLeft),
                  style: TextStyle(
                    fontSize: 16,
                    color: _secondsLeft < 60 ? Colors.red.shade200 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey[200],
            color: theme.colorScheme.primary,
            minHeight: 4,
          ),
          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildQuestionWidget(q),
            ),
          ),
          // Feedback overlay shown after answering
          if (_answered)
            FeedbackOverlay(
              isCorrect: _selectedIndex == q.correctIndex,
              explanation: q.explanation,
              onNext: _onNext,
              isLastQuestion: _isLastQuestion,
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Question q) {
    if (q.type == 'analogy') {
      return AnalogyCard(
        question: q,
        selectedIndex: _selectedIndex,
        answered: _answered,
        onOptionTap: _onOptionTap,
      );
    }
    if (q.type == 'reading_comprehension' && q.passage != null) {
      return ReadingPassageCard(
        question: q,
        selectedIndex: _selectedIndex,
        answered: _answered,
        onOptionTap: _onOptionTap,
      );
    }
    return QuestionCard(
      question: q,
      selectedIndex: _selectedIndex,
      answered: _answered,
      onOptionTap: _onOptionTap,
    );
  }
}
