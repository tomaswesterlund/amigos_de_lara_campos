import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../core/lara_theme.dart';

/// Animated water covering the bottom ~28 % of the screen.
/// Two overlapping sine-wave bands + scrolling shimmer lines.
class WaterLayerComponent extends PositionComponent {
  WaterLayerComponent({required Vector2 size}) : super(size: size);
  static const _topFrac = 0.72; // water starts here
  static const _shimmerCount = 5;

  double _time = 0;
  double _shimmerOff = 0;
  late final List<_Shimmer> _shimmers;

  @override
  void onMount() {
    super.onMount();
    priority = -50;
    _refit(size);
    final rng = math.Random(3);
    _shimmers = List.generate(
      _shimmerCount,
      (i) => _Shimmer(xFrac: 0.05 + i * 0.18 + rng.nextDouble() * 0.08, phase: rng.nextDouble() * math.pi * 2),
    );
  }

  void _refit(Vector2 sz) {
    size = Vector2(sz.x, sz.y * (1 - _topFrac));
    position = Vector2(0, sz.y * _topFrac);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _refit(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _shimmerOff += 38 * dt;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Water body fill
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = LaraColors.mint.withValues(alpha: 0.62));

    // Wave 1 — primary surface ripple
    _drawWave(
      canvas,
      amplitude: 5.5,
      frequency: 0.022,
      phase: _time * 1.3,
      color: Colors.white.withValues(alpha: 0.45),
      fillY: 8,
    );

    // Wave 2 — secondary overlapping ripple
    _drawWave(
      canvas,
      amplitude: 3.5,
      frequency: 0.032,
      phase: _time * 0.85 + 1.4,
      color: const Color(0xFF72E0C4).withValues(alpha: 0.55),
      fillY: 14,
    );

    // Scrolling horizontal shimmer bands
    final wrapY = _shimmerOff % 26;
    for (var y = -wrapY; y < h; y += 26) {
      canvas.drawRect(Rect.fromLTWH(0, y, w, 5), Paint()..color = Colors.white.withValues(alpha: 0.08));
    }

    // Sparkle dots on water surface
    for (final s in _shimmers) {
      final alpha = (math.sin(_time * 1.6 + s.phase).abs() * 0.75).clamp(0.0, 0.75);
      canvas.drawCircle(
        Offset(s.xFrac * w, 5 + math.sin(_time * 0.9 + s.phase) * 4),
        2.2,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawWave(
    Canvas canvas, {
    required double amplitude,
    required double frequency,
    required double phase,
    required Color color,
    required double fillY,
  }) {
    final path = Path()..moveTo(0, fillY);
    for (var x = 0.0; x <= size.x; x += 4) {
      path.lineTo(x, fillY + math.sin(x * frequency + phase) * amplitude);
    }
    path.lineTo(size.x, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
}

class _Shimmer {
  const _Shimmer({required this.xFrac, required this.phase});
  final double xFrac;
  final double phase;
}
