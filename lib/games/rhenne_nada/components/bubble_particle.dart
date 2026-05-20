import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A single rising bubble. Spawned from RhenneNadaGame.update() on a timer.
/// Radius grows from 3→8 as it rises; removed when it reaches the top.
class BubbleParticle extends PositionComponent {
  BubbleParticle({required Vector2 startPosition, required this.riseSpeed, required this.driftX})
      : _startY = startPosition.y,
        super(position: startPosition, anchor: Anchor.center);

  final double riseSpeed;
  final double driftX;
  final double _startY;

  late final Paint _bodyPaint;
  late final Paint _rimPaint;

  @override
  Future<void> onLoad() async {
    _bodyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    _rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= riseSpeed * dt;
    position.x += driftX * dt;
    if (position.y < -10) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // Fraction risen: 0 at spawn, 1 at screen top
    final frac = (1.0 - (position.y / _startY)).clamp(0.0, 1.0);
    final r = 3.0 + frac * 5.0;
    canvas.drawCircle(Offset.zero, r, _bodyPaint);
    // Rim highlight (offset slightly upper-left)
    canvas.drawCircle(Offset(-r * 0.3, -r * 0.3), r * 0.28, _rimPaint);
  }
}
