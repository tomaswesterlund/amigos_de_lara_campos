import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// Floating "+1" that drifts up and fades — kid-friendly pickup feedback.
class ScorePop extends TextComponent {
  ScorePop({
    required Vector2 startPosition,
    required int points,
    Color shadowColor = const Color(0xFFE33282),
    double fontSize = 28,
  }) : super(
          text: '+$points',
          anchor: Anchor.center,
          position: startPosition,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(offset: const Offset(0, 2), blurRadius: 0, color: shadowColor),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(
      SequenceEffect(
        [
          MoveByEffect(
            Vector2(0, -60),
            EffectController(duration: 0.55, curve: Curves.easeOut),
          ),
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(duration: 0.15, curve: Curves.easeIn),
          ),
        ],
        onComplete: removeFromParent,
      ),
    );
  }
}
