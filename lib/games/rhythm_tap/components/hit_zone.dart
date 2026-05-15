import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class HitZone extends PositionComponent with TapCallbacks {
  HitZone({
    required this.lane,
    required this.color,
    required this.onTap,
  });

  final int lane;
  final Color color;
  final VoidCallback onTap;
  double _pulse = 0;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35 + _pulse * 0.45)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, border);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse = (_pulse - dt * 2).clamp(0, 1);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _pulse = 1;
    onTap();
    add(
      ScaleEffect.to(
        Vector2(1.1, 1.1),
        EffectController(duration: 0.08, alternate: true, reverseDuration: 0.08),
      ),
    );
  }
}
