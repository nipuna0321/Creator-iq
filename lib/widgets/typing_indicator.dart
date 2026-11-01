import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Three bouncing dots shown while the AI is "typing".
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
            .animate(onPlay: (c) => c.repeat())
            // Stagger each dot so they bounce in sequence.
            .moveY(begin: 0, end: -6, delay: (i * 150).ms, duration: 300.ms, curve: Curves.easeOut)
            .then()
            .moveY(begin: 0, end: 6, duration: 300.ms, curve: Curves.easeIn)
            .then(delay: ((2 - i) * 150).ms);
      }),
    );
  }
}
