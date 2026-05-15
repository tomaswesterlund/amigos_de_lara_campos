import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Soft white puff drifting slowly across the sky for background flair.
class Cloud extends PositionComponent {
  Cloud({required this.driftSpeed});

  final double driftSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    position.x += driftSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final w = size.x;
    final h = size.y;
    // Three overlapping circles make a fluffy cloud silhouette.
    canvas.drawCircle(Offset(w * 0.30, h * 0.55), h * 0.45, paint);
    canvas.drawCircle(Offset(w * 0.55, h * 0.40), h * 0.55, paint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.58), h * 0.42, paint);
    // Soft underline
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * 0.55, w * 0.7, h * 0.35),
      paint,
    );
  }
}
