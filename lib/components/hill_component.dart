import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class HillComponent extends PositionComponent {
  HillComponent({
    required Vector2 startPosition,
    required this.hillWidth,
    required this.hillHeight,
    required this.scrollSpeed,
    required this.color,
    required Random rng,
  })  : _rng = rng,
        super(
          position: startPosition,
          size: Vector2(hillWidth, hillHeight),
          priority: -50,
        );

  final double hillWidth;
  final double hillHeight;
  final double scrollSpeed;
  final Color color;
  final Random _rng;

  @override
  void update(double dt) {
    position.x -= scrollSpeed * dt;
    if (position.x + hillWidth < 0) {
      final p = parent;
      if (p is PositionComponent) {
        position.x = p.size.x + 20 + _rng.nextDouble() * 120;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(0, hillHeight)
      ..quadraticBezierTo(hillWidth / 2, -hillHeight * 0.55, hillWidth, hillHeight)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }
}
