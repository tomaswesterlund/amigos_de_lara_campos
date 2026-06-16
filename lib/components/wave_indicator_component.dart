import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:lara_demo/core/constants.dart';

class WaveIndicatorComponent extends PositionComponent {
  final VoidCallback? onComplete;
  final int waveNumber;

  WaveIndicatorComponent({required this.waveNumber, required Vector2 position, this.onComplete})
    : super(position: position, anchor: Anchor.topLeft, size: Vector2(200, 50));

  @override
  Future<void> onLoad() async {
    debugMode = Constants.DEBUG;

    add(
      SequenceEffect(
        [
          ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.3, curve: Curves.easeOut)),
          MoveByEffect(Vector2(0, -30), EffectController(duration: 1.0)),
          ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.2, curve: Curves.easeIn)),
        ],
        onComplete: () {
          onComplete?.call();
          removeFromParent();
        },
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    TextPaint(
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFFD640),
        shadows: [Shadow(offset: Offset(0, 3), color: Color(0xFF8B5E3C))],
      ),
    ).render(canvas, '¡Prepárate!', size / 2, anchor: Anchor.center);
  }
}
