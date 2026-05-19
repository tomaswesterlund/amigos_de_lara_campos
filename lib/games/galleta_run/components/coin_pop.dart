import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../../shared/coin_draw.dart';

/// Floating coin icon + "+1 Moneda" that drifts up and fades on pickup.
class CoinPop extends PositionComponent {
  CoinPop({required Vector2 startPosition})
      : super(position: startPosition, anchor: Anchor.center, size: Vector2(148, 44));

  @override
  Future<void> onLoad() async {
    add(SequenceEffect([
      MoveByEffect(Vector2(0, -65), EffectController(duration: 0.55, curve: Curves.easeOut)),
      ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.15, curve: Curves.easeIn)),
    ], onComplete: removeFromParent));
  }

  @override
  void render(Canvas canvas) {
    drawCoin(canvas, 44, 44);
    TextPaint(
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFFD640),
        shadows: [Shadow(offset: Offset(0, 2), color: Color(0xFF8B5E3C))],
      ),
    ).render(canvas, '+1 Moneda', Vector2(52, 11));
  }
}
