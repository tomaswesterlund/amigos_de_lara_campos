import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_base_game.dart';

class CloudComponent extends PositionComponent with HasGameReference<LaraBaseGame> {
  CloudComponent({required Vector2 position, required Vector2 size, required this.driftSpeed})
    : super(position: position, size: size);

  final double driftSpeed;

  @override
  void update(double dt) {
    super.update(dt);

    position.x += driftSpeed * dt;

    if (position.x > game.size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final paint = Paint()..color = const Color(0xFFFFFDF5).withValues(alpha: 0.88);

    // Draws relative to the size box dynamically
    canvas.drawCircle(Offset(w * 0.25, h * 0.62), h * 0.50, paint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.42), h * 0.62, paint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.58), h * 0.48, paint);

    canvas.drawRect(Rect.fromLTWH(w * 0.10, h * 0.62, w * 0.80, h * 0.42), paint);
  }
}
