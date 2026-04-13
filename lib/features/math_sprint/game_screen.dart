import 'dart:async';
import 'package:flutter/material.dart';

import 'math_generator.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  final bool isTimed;

  const GameScreen({super.key, required this.isTimed});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final List<MathProblem> _problems;
  final List<int?> _userAnswers = List.filled(20, null);
  int _currentIndex = 0;
  int? _tappedIndex; // brief visual feedback on tap

  Timer? _timer;
  int _secondsLeft = 20 * 60;

  @override
  void initState() {
    super.initState();
    _problems = MathGenerator.generate20();
    if (widget.isTimed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 0) {
          _timer?.cancel();
          _finishGame();
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

  MathProblem get _current => _problems[_currentIndex];
  String get _levelLabel {
    if (_currentIndex < 7) return 'קל';
    if (_currentIndex < 14) return 'בינוני';
    return 'קשה';
  }

  void _onOptionTap(int optionIndex) async {
    setState(() => _tappedIndex = optionIndex);
    _userAnswers[_currentIndex] = optionIndex;

    // Brief flash, then advance
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    if (_currentIndex >= 19) {
      _finishGame();
    } else {
      setState(() {
        _currentIndex++;
        _tappedIndex = null;
      });
    }
  }

  void _finishGame() {
    _timer?.cancel();
    final score = _userAnswers.asMap().entries.where((e) {
      final idx = e.key;
      final ans = e.value;
      return ans != null && ans == _problems[idx].correctIndex;
    }).length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          problems: _problems,
          userAnswers: _userAnswers,
          score: score,
        ),
      ),
    );
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _current;

    return Scaffold(
      appBar: AppBar(
        title: Text('שאלה ${_currentIndex + 1} / 20'),
        actions: [
          if (widget.isTimed)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _formatTime(_secondsLeft),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _secondsLeft < 60 ? Colors.red.shade200 : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress + level
          LinearProgressIndicator(
            value: (_currentIndex + 1) / 20,
            backgroundColor: Colors.grey[200],
            color: theme.colorScheme.primary,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _levelLabel,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // Question
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Options grid (2×2)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: List.generate(4, (i) => _OptionButton(
                      text: q.options[i],
                      tapped: _tappedIndex == i,
                      onTap: () => _onOptionTap(i),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final bool tapped;
  final VoidCallback onTap;

  const _OptionButton({required this.text, required this.tapped, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: tapped ? theme.colorScheme.primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: tapped ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: tapped ? Colors.white : const Color(0xFFE65100),
            ),
          ),
        ),
      ),
    );
  }
}
