import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_brinca_game.dart';

/// A lily pad in one of the 3 lanes. Bobs gently on the water surface;
/// produces expanding ripple rings when Rhenné lands on it.
class LilyPad extends PositionComponent with HasGameReference<RhenneBrincaGame> {
  LilyPad({required this.laneIndex});

  final int laneIndex;
  double _bobTime = 0;
  late double _bobPhase;

  static const _bobAmplitude = 4.0;
  static const _bobPeriod    = 1.45;

  @override
  void onMount() {
    super.onMount();
    priority   = 2;
    _bobPhase  = laneIndex * (math.pi * 2 / 3); // stagger bob per lane
    _refit(game.size);
  }

  void _refit(Vector2 sz) {
    final w  = game.laneWidth * 0.78;
    final h  = w * 0.34;
    size     = Vector2(w, h);
    anchor   = Anchor.center;
    position = Vector2(game.laneCenterX(laneIndex), game.padY);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _refit(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTime += dt;
    final bob = math.sin(_bobTime * (math.pi * 2 / _bobPeriod) + _bobPhase) * _bobAmplitude;
    position = Vector2(game.laneCenterX(laneIndex), game.padY + bob);
  }

  /// Spawn 3 expanding ripple rings — called by BrincaRhenne on landing.
  void ripple() {
    for (var i = 0; i < 3; i++) {
      add(_Ripple(delay: i * 0.08));
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Main pad body
    final padPaint = Paint()..color = LaraColors.rhenneGreen.withValues(alpha: 0.92);
    canvas.drawOval(Rect.fromLTWH(0, 0, w, h), padPaint);

    // Darker border
    canvas.drawOval(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color     = LaraColors.rhenneGreenDark.withValues(alpha: 0.70)
        ..style     = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Veins radiating from centre
    final cx    = w / 2;
    final cy    = h / 2;
    final veinPaint = Paint()
      ..color       = LaraColors.rhenneGreenDark.withValues(alpha: 0.40)
      ..strokeWidth = 1.2
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    // Centre spine
    canvas.drawLine(Offset(cx * 0.30, cy), Offset(cx * 1.70, cy), veinPaint);
    // 4 lateral veins
    for (var i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final startX = cx + i * w * 0.14;
      final endX   = cx + i.sign * w * 0.48;
      final endY   = i.isNegative ? h * 0.15 : h * 0.85;
      canvas.drawLine(Offset(startX, cy), Offset(endX, endY), veinPaint);
    }

    // Notch (typical lily-pad cut)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.08, cy), width: w * 0.12, height: h * 0.45),
      Paint()
        ..color     = LaraColors.rhenneGreenDark.withValues(alpha: 0.30)
        ..style     = PaintingStyle.fill,
    );
  }
}

// ── Water ripple ring (child of LilyPad) ─────────────────────────────────────

class _Ripple extends PositionComponent {
  _Ripple({required double delay}) : _delay = delay;

  static const _duration = 0.55;
  final double _delay;
  double _elapsed = 0;

  @override
  void onMount() {
    super.onMount();
    anchor   = Anchor.center;
    position = (parent as LilyPad).size / 2; // centre of pad
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _delay + _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = ((_elapsed - _delay) / _duration).clamp(0.0, 1.0);
    if (t <= 0) return;
    final w = (parent as LilyPad).size.x;
    final rx = (w * 0.55) * (0.2 + t * 0.8);
    final ry = rx * 0.28;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()
        ..color       = Colors.white.withValues(alpha: (1 - t) * 0.55)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2.5 - t * 1.8,
    );
  }
}
