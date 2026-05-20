import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_nada_game.dart';

/// Swaying seaweed stalks anchored to the bottom of the screen, drawn on Canvas.
class SeaweedStrip extends PositionComponent with HasGameReference<RhenneNadaGame> {
  late final List<_Stalk> _stalks;
  late final Paint _paint;
  late final Path _path;
  double _time = 0;

  @override
  void onMount() {
    super.onMount();
    priority = -800;
    size = Vector2(game.size.x, game.size.y * 0.28);
    position = Vector2(0, game.size.y * 0.72);

    _stalks = [
      _Stalk(x: game.size.x * 0.12, freq: 0.9, phase: 0.0),
      _Stalk(x: game.size.x * 0.45, freq: 0.7, phase: 1.2),
      _Stalk(x: game.size.x * 0.78, freq: 1.1, phase: 2.5),
    ];
    _paint = Paint()
      ..color = LaraColors.rhenneGreen.withValues(alpha: 0.65)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _path = Path();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, size.y * 0.28);
    position = Vector2(0, size.y * 0.72);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    for (final stalk in _stalks) {
      _path.reset();
      _path.moveTo(stalk.x, size.y);
      double py = size.y;
      for (var seg = 0; seg < 4; seg++) {
        final ny = py - size.y * 0.25;
        final sway = math.sin(_time * stalk.freq + stalk.phase + seg * 0.9) * 14.0;
        _path.quadraticBezierTo(stalk.x + sway, (py + ny) * 0.5, stalk.x, ny);
        py = ny;
      }
      canvas.drawPath(_path, _paint);
    }
  }
}

class _Stalk {
  const _Stalk({required this.x, required this.freq, required this.phase});
  final double x;
  final double freq;
  final double phase;
}
