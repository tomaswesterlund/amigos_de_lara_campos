import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../rhenne_nada_game.dart';

/// A school of 6 tiny decorative fish that glide through the background.
/// Translucent and non-interactive — purely atmospheric.
class AmbientFishSchool extends PositionComponent
    with HasGameReference<RhenneNadaGame> {
  static const _count = 6;

  final _rng    = math.Random(7);
  double _time  = 0;
  double _schoolX = 0;
  double _baseY   = 0;
  double _speed   = 0;
  double _waveAmp = 0;
  double _waveFreq = 0;

  late final List<_FishOffset> _offsets;

  @override
  void onMount() {
    super.onMount();
    priority = -600;
    _offsets = List.generate(_count, (i) => _FishOffset(
      dx: _rng.nextDouble() * 32 - 16,
      dy: _rng.nextDouble() * 22 - 11,
      phase: _rng.nextDouble() * math.pi * 2,
    ));
    _resetSchool(fromRight: false);
  }

  void _resetSchool({bool fromRight = true}) {
    _speed    = 40.0 + _rng.nextDouble() * 28.0;
    _waveAmp  = 14.0 + _rng.nextDouble() * 18.0;
    _waveFreq = 0.55 + _rng.nextDouble() * 0.7;
    _baseY    = game.size.y * (0.22 + _rng.nextDouble() * 0.48);
    _schoolX  = fromRight ? game.size.x + 90 : -90;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time    += dt;
    _schoolX -= _speed * dt;
    final currentY = _baseY + math.sin(_time * _waveFreq) * _waveAmp;
    position  = Vector2(_schoolX, currentY);
    if (_schoolX < -110) _resetSchool();
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < _count; i++) {
      final off    = _offsets[i];
      final wobble = math.sin(_time * 2.8 + off.phase) * 3.5;
      _drawFish(canvas, off.dx, off.dy + wobble);
    }
  }

  void _drawFish(Canvas canvas, double dx, double dy) {
    const w = 18.0;
    const h = 10.0;

    final paint = Paint()
      ..color = const Color(0xFF72E0C4).withValues(alpha: 0.52);

    // Tail fork
    canvas.drawPath(
      Path()
        ..moveTo(dx + w * 0.48, dy)
        ..lineTo(dx + w * 0.88, dy - h * 0.60)
        ..lineTo(dx + w * 0.88, dy + h * 0.60)
        ..close(),
      paint,
    );

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dx, dy), width: w, height: h),
      paint,
    );

    // Eye
    canvas.drawCircle(
      Offset(dx - w * 0.32, dy - h * 0.08),
      1.4,
      Paint()..color = const Color(0xFF0B4D7A).withValues(alpha: 0.65),
    );
  }
}

class _FishOffset {
  const _FishOffset({required this.dx, required this.dy, required this.phase});
  final double dx;
  final double dy;
  final double phase;
}
