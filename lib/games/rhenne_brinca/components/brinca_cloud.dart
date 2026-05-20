import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../rhenne_brinca_game.dart';

/// Fluffy cloud drifting across the sky. Three overlapping circles make the puff.
class BrincaCloud extends PositionComponent
    with HasGameReference<RhenneBrincaGame> {
  BrincaCloud({required this.driftSpeed});

  final double driftSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    position.x += driftSpeed * dt;
    final w = size.x;
    if (driftSpeed > 0 && position.x > game.size.x + w) removeFromParent();
    if (driftSpeed < 0 && position.x < -w) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final paint = Paint()..color = const Color(0xFFFFFDF5).withValues(alpha: 0.88);

    // Three overlapping puffs
    canvas.drawCircle(Offset(w * 0.25, h * 0.62), h * 0.50, paint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.42), h * 0.62, paint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.58), h * 0.48, paint);

    // Fill the bottom gap so it looks solid
    canvas.drawRect(
      Rect.fromLTWH(w * 0.10, h * 0.62, w * 0.80, h * 0.42),
      paint,
    );
  }
}
