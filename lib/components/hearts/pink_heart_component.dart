import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class PinkHeartComponent extends PositionComponent with CollisionCallbacks, HasGameRef {
  PinkHeartComponent({required this.lane})
    : super(
        size: Vector2.all(52), // Match the sizeFor definition
        anchor: Anchor.center,
      );

  final int lane;
  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load asset independently via generic gameRef
    _sprite = await gameRef.loadSprite('corazon_pink.png');

    // Add relative circular collision boundary
    add(CircleHitbox.relative(0.65, parentSize: size));

    // Add the pink heart specific pulsing scale effect
    add(
      ScaleEffect.by(
        Vector2.all(1.14),
        EffectController(duration: 0.45, alternate: true, infinite: true, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    // Draw collectible glow aura
    final glowPaint = Paint()..color = const Color(0xFFFF69B4).withValues(alpha: 0.12);
    canvas.drawCircle(Offset(w / 2, h / 2), (w / 2) * 1.20, glowPaint);
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      (w / 2) * 0.95,
      glowPaint..color = const Color(0xFFFF69B4).withValues(alpha: 0.28),
    );

    // Render loaded sprite
    _sprite?.render(canvas, size: size);
  }
}
