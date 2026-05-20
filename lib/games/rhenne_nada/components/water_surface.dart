import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../rhenne_nada_game.dart';

/// Animated water surface strip at the top of the screen.
/// Two overlapping sine waves + pre-allocated sparkle points.
class WaterSurface extends PositionComponent with HasGameReference<RhenneNadaGame> {
  static const _sparkleCount = 8;

  late final List<_Sparkle> _sparkles;
  late final Paint _paint;
  late final Path _path;
  final _rng = math.Random();
  double _time = 0;

  @override
  void onMount() {
    super.onMount();
    priority = 500;
    size = Vector2(game.size.x, 32);
    position = Vector2.zero();

    _sparkles = List.generate(_sparkleCount, (i) => _Sparkle(
      x: game.size.x * (i + 0.5) / _sparkleCount,
      y: 10 + _rng.nextDouble() * 12,
      radius: 1.5 + _rng.nextDouble() * 2.0,
      phase: _rng.nextDouble() * math.pi * 2,
    ));
    _paint = Paint();
    _path = Path();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, 32);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Drift sparkles horizontally with the scroll
    for (final s in _sparkles) {
      s.x -= 60 * dt;
      if (s.x < 0) s.x += size.x;
    }
  }

  @override
  void render(Canvas canvas) {
    _drawWave(canvas,
        amplitude: 5.0,
        frequency: 0.018,
        phase: _time * 1.2,
        color: const Color(0xFF5DDEF4).withValues(alpha: 0.6),
        fillY: size.y * 0.65);

    _drawWave(canvas,
        amplitude: 3.5,
        frequency: 0.028,
        phase: _time * 0.85 + 1.2,
        color: const Color(0xFF85E8F5).withValues(alpha: 0.45),
        fillY: size.y * 0.42);

    // Sparkle dots — triangle-wave alpha cycle
    for (final s in _sparkles) {
      final t = ((_time * 1.3 + s.phase) % (math.pi * 2));
      final alpha = (math.sin(t).abs() * 0.85).clamp(0.0, 0.85);
      _paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, _paint);
    }
  }

  void _drawWave(Canvas canvas,
      {required double amplitude,
      required double frequency,
      required double phase,
      required Color color,
      required double fillY}) {
    _path.reset();
    _path.moveTo(0, fillY);
    for (double x = 0; x <= size.x; x += 4) {
      final y = fillY + math.sin(x * frequency + phase) * amplitude;
      _path.lineTo(x, y);
    }
    _path.lineTo(size.x, 0);
    _path.lineTo(0, 0);
    _path.close();
    _paint.color = color;
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(_path, _paint);
  }
}

class _Sparkle {
  _Sparkle({required this.x, required this.y, required this.radius, required this.phase});
  double x;
  final double y;
  final double radius;
  final double phase;
}
