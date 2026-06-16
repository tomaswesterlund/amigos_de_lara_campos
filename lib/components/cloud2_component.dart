import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class Cloud2Component extends PositionComponent {
  Cloud2Component({
    required Vector2 startPosition,
    required this.cloudWidth,
    required this.scrollSpeed,
    required Random rng,
    int renderPriority = -30,
  })  : _rng = rng,
        super(position: startPosition, priority: renderPriority);

  final double cloudWidth;
  final double scrollSpeed;
  final Random _rng;

  double get _cloudHeight => cloudWidth * 0.42;

  @override
  void update(double dt) {
    position.x -= scrollSpeed * dt;
    if (position.x + cloudWidth < 0) {
      final p = parent;
      if (p is PositionComponent) {
        position.x = p.size.x + 20 + _rng.nextDouble() * 200;
        position.y = 30 + _rng.nextDouble() * 130;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final h = _cloudHeight;
    final paint = Paint()..color = const Color(0xBBFFFFFF);
    // Three overlapping ovals — left base, centre peak, right base
    canvas.drawOval(Rect.fromLTWH(0, h * 0.35, cloudWidth * 0.52, h * 0.65), paint);
    canvas.drawOval(Rect.fromLTWH(cloudWidth * 0.22, 0, cloudWidth * 0.46, h), paint);
    canvas.drawOval(Rect.fromLTWH(cloudWidth * 0.50, h * 0.28, cloudWidth * 0.50, h * 0.72), paint);
  }
}
