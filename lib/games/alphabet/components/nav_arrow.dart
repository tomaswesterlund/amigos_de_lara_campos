import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';

/// Sticker-style chevron button used to step forward / backward through
/// the alphabet. Lives inside the Flame world so it scales with the game.
class NavArrow extends PositionComponent with TapCallbacks {
  NavArrow({required this.forward, required this.onTap})
      : super(anchor: Anchor.center);

  final bool forward;
  final VoidCallback onTap;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(64);
  }

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = LaraColors.magenta;
    final rim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final circle = RRect.fromRectAndRadius(rect, Radius.circular(size.x / 2));
    canvas.drawRRect(circle, body);
    canvas.drawRRect(circle.deflate(6), rim);

    // Chevron.
    final c = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final w = size.x * 0.18;
    final h = size.y * 0.22;
    final path = Path();
    if (forward) {
      path
        ..moveTo(cx - w, cy - h)
        ..lineTo(cx + w, cy)
        ..lineTo(cx - w, cy + h);
    } else {
      path
        ..moveTo(cx + w, cy - h)
        ..lineTo(cx - w, cy)
        ..lineTo(cx + w, cy + h);
    }
    canvas.drawPath(path, c);
  }

  @override
  void onTapDown(TapDownEvent event) {
    add(
      ScaleEffect.by(
        Vector2.all(0.88),
        EffectController(
          duration: 0.07,
          alternate: true,
          reverseDuration: 0.07,
        ),
      ),
    );
    onTap();
  }
}
