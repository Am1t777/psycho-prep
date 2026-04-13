import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';

import '../../models/vocab_word.dart';
import '../../services/progress_service.dart';
import 'widgets/flashcard_widget.dart';

class FlashcardScreen extends StatefulWidget {
  final List<VocabWord> words;
  final String title;

  const FlashcardScreen({super.key, required this.words, required this.title});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final _controller = CardSwiperController();
  int _currentIndex = 0;
  String? _swipeLabel; // 'mastered' | 'learning' | null

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('אין כרטיסים בחפיסה זו')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.words.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Swipe hint bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.arrow_back, color: Color(0xFFF57C00), size: 20),
                  const SizedBox(width: 4),
                  Text('עדיין לומד', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ]),
                Row(children: [
                  Text('נרכש', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, color: Color(0xFF66BB6A), size: 20),
                ]),
              ],
            ),
          ),
          // Card swiper
          Expanded(
            child: Stack(
              children: [
                CardSwiper(
                  controller: _controller,
                  cardsCount: widget.words.length,
                  allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  onSwipe: _onSwipe,
                  onEnd: _onEnd,
                  cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                    return FlashcardWidget(word: widget.words[index]);
                  },
                ),
                // Swipe direction overlay
                if (_swipeLabel != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _swipeLabel != null ? 1 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: _swipeLabel == 'mastered'
                                  ? const Color(0xFF66BB6A)
                                  : const Color(0xFFF57C00),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _swipeLabel == 'mastered' ? 'נרכש!' : 'עדיין לומד',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: widget.words.isEmpty ? 0 : (_currentIndex / widget.words.length),
                  backgroundColor: Colors.grey[200],
                  color: theme.colorScheme.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final progress = context.read<ProgressService>();
    final word = widget.words[previousIndex];

    final status = direction == CardSwiperDirection.right ? 'mastered' : 'learning';
    progress.setWordStatus(word.id, status);

    setState(() {
      _swipeLabel = status;
      _currentIndex = currentIndex ?? previousIndex;
    });

    // Clear label after short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _swipeLabel = null);
    });

    return true;
  }

  void _onEnd() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('סיימת!'),
        content: const Text('עברת על כל הכרטיסים בחפיסה זו.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('חזור לבחירת חפיסה'),
          ),
        ],
      ),
    );
  }
}
