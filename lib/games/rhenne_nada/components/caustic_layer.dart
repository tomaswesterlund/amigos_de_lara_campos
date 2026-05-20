import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../rhenne_nada_game.dart';

/// Animated underwater light-ray beams drawn entirely on Canvas.
/// 7 parallelogram-shaped beams sway gently — subtle, not distracting.
class CausticLayer extends PositionComponent with HasGameReference<RhenneNadaGame> {
  static const _rayCount = 7;

  final _rng = math.Random(42);
  late final List<_Ray> _rays;
  late final List<Path> _paths;
  late final Paint _paint;
  double _time = 0;

  @override
  void onMount() {
    super.onMount();
    priority = -900;
    size = game.size;
    position = Vector2.zero();

    _rays = List.generate(_rayCount, (i) {
      return _Ray(
        baseX: game.size.x * (0.05 + i * 0.135),
        width: 18.0 + _rng.nextDouble() * 22.0,
        phaseOffset: _rng.nextDouble() * math.pi * 2,
        opacity: 0.08 + _rng.nextDouble() * 0.07,
      );
    });
    _paths = List.generate(_rayCount, (_) => Path());
    _paint = Paint()..style = PaintingStyle.fill;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final h = game.size.y;
    const slant = 45.0;
    for (var i = 0; i < _rays.length; i++) {
      final ray = _rays[i];
      final swayX = math.sin(_time * 0.7 + ray.phaseOffset) * 9;
      final half = ray.width * 0.5;

      _paths[i]
        ..reset()
        ..moveTo(ray.baseX - half + swayX, 0)
        ..lineTo(ray.baseX + half + swayX, 0)
        ..lineTo(ray.baseX + half + swayX + slant, h)
        ..lineTo(ray.baseX - half + swayX + slant, h)
        ..close();

      _paint.color = const Color(0xFFB8E5FF).withValues(alpha: ray.opacity);
      canvas.drawPath(_paths[i], _paint);
    }
  }
}

class _Ray {
  const _Ray({
    required this.baseX,
    required this.width,
    required this.phaseOffset,
    required this.opacity,
  });
  final double baseX;
  final double width;
  final double phaseOffset;
  final double opacity;
}
