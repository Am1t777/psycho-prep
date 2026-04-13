import 'dart:math';
import 'package:flutter/material.dart';

import '../../../models/vocab_word.dart';

class FlashcardWidget extends StatefulWidget {
  final VocabWord word;

  const FlashcardWidget({super.key, required this.word});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value;
          // Flip perspective: front shows 0→π/2, back shows π/2→π (mirrored)
          final isFront = angle < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isFront ? angle : angle - pi),
            child: isFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _CardSurface(
      color: const Color(0xFFFFF8F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.word.word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'הקש לגלות',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _CardSurface(
      color: const Color(0xFFFFF3E0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.word.word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.word.definition,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 12),
          Text(
            widget.word.example,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  final Color color;
  final Widget child;

  const _CardSurface({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: child,
    );
  }
}
