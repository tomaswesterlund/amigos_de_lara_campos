import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_nada_game.dart';

/// Canvas-drawn coral fans swaying at the bottom of the underwater scene.
/// Drawn as radial branches with quadratic-bezier curves and tip circles.
class CoralFan extends PositionComponent with HasGameReference<RhenneNadaGame> {
  double _time = 0;
  late final List<_Fan> _fans;

  @override
  void onMount() {
    super.onMount();
    priority = -700;
    _refit(game.size);
    _fans = [
      _Fan(xFrac: 0.06,  color: LaraColors.pink,       segments: 7, heightFrac: 0.82, phase: 0.0,  freq: 0.75),
      _Fan(xFrac: 0.30,  color: LaraColors.corazonRed,  segments: 5, heightFrac: 0.60, phase: 1.3,  freq: 0.90),
      _Fan(xFrac: 0.62,  color: LaraColors.pink,        segments: 8, heightFrac: 0.88, phase: 2.4,  freq: 0.65),
      _Fan(xFrac: 0.88,  color: LaraColors.magenta,     segments: 6, heightFrac: 0.72, phase: 0.8,  freq: 1.00),
    ];
  }

  void _refit(Vector2 sz) {
    size     = Vector2(sz.x, sz.y * 0.24);
    position = Vector2(0,    sz.y * 0.76);
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
  }

  @override
  void render(Canvas canvas) {
    for (final fan in _fans) {
      _drawFan(canvas, fan);
    }
  }

  void _drawFan(Canvas canvas, _Fan fan) {
    final baseX    = fan.xFrac * size.x;
    final fanH     = fan.heightFrac * size.y;
    final sway     = math.sin(_time * fan.freq + fan.phase) * 9.0;

    // Thick stem
    final stemPaint = Paint()
      ..color     = fan.color.withValues(alpha: 0.80)
      ..strokeWidth = 5
      ..style     = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemTopX = baseX + sway * 0.35;
    final stemTopY = size.y - fanH * 0.22;
    canvas.drawLine(Offset(baseX, size.y), Offset(stemTopX, stemTopY), stemPaint);

    // Fan branches
    final spreadAngle = math.pi * 0.65;
    final startAngle  = -math.pi / 2 - spreadAngle / 2;

    final branchPaint = Paint()
      ..style     = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < fan.segments; i++) {
      final t     = fan.segments <= 1 ? 0.5 : i / (fan.segments - 1).toDouble();
      final angle = startAngle + t * spreadAngle;
      final branchLen = fanH * (0.50 + 0.38 * math.sin(t * math.pi));
      final tipSway   = math.sin(_time * fan.freq * 1.4 + fan.phase + i * 0.8) * 6.0;

      final tipX  = stemTopX + math.cos(angle) * branchLen + tipSway;
      final tipY  = stemTopY + math.sin(angle) * branchLen;
      final cpX   = stemTopX + math.cos(angle) * branchLen * 0.5 + tipSway * 0.4;
      final cpY   = stemTopY + math.sin(angle) * branchLen * 0.5;

      final thickness = 1.5 + 1.8 * math.sin(t * math.pi);
      branchPaint
        ..color       = fan.color.withValues(alpha: 0.65)
        ..strokeWidth = thickness;

      canvas.drawPath(
        Path()
          ..moveTo(stemTopX, stemTopY)
          ..quadraticBezierTo(cpX, cpY, tipX, tipY),
        branchPaint,
      );

      // Tiny tip bud
      canvas.drawCircle(
        Offset(tipX, tipY),
        2.2,
        Paint()..color = fan.color.withValues(alpha: 0.88),
      );
    }
  }
}

class _Fan {
  const _Fan({
    required this.xFrac,
    required this.color,
    required this.segments,
    required this.heightFrac,
    required this.phase,
    required this.freq,
  });

  final double xFrac;
  final Color  color;
  final int    segments;
  final double heightFrac;
  final double phase;
  final double freq;
}
