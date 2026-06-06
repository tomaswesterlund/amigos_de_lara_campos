import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class GoldenHeartComponent extends PositionComponent with CollisionCallbacks, HasGameRef {
  GoldenHeartComponent({required this.lane})
      : super(
          size: Vector2.all(50), // Match the sizeFor definition
          anchor: Anchor.center,
        );

  final int lane;
  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load asset independently via generic gameRef
    _sprite = await gameRef.loadSprite('corazon_yellow.png');

    // Add relative circular collision boundary
    add(CircleHitbox.relative(0.65, parentSize: size));

    // Add the star/golden specific linear rotation effect
    add(
      RotateEffect.by(
        math.pi * 2,
        EffectController(
          duration: 1.8,
          infinite: true,
          curve: Curves.linear,
        ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    // Draw yellow collectible glow aura
    final glowPaint = Paint()..color = const Color(0xFFFFD640).withValues(alpha: 0.12);
    canvas.drawCircle(Offset(w / 2, h / 2), (w / 2) * 1.20, glowPaint);
    canvas.drawCircle(Offset(w / 2, h / 2), (w / 2) * 0.95, glowPaint..color = const Color(0xFFFFD640).withValues(alpha: 0.28));

    // Render loaded sprite
    _sprite?.render(canvas, size: size);
  }
}