import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../core/lara_theme.dart';

class SkyLayerComponent extends PositionComponent {
  SkyLayerComponent({required Vector2 size}) : super(size: size);
  static const _rayCount = 7;

  double _time = 0;
  final _rng = math.Random(13);
  late final List<_Ray> _rays;

  @override
  void onMount() {
    super.onMount();
    priority = -900;
    size = size;
    _rays = List.generate(
      _rayCount,
      (i) => _Ray(
        angleFrac: 0.10 + i * 0.12,
        width: 22.0 + _rng.nextDouble() * 28.0,
        phase: _rng.nextDouble() * math.pi * 2,
        opacity: 0.06 + _rng.nextDouble() * 0.07,
      ),
    );
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
    final w = size.x;
    final h = size.y;

    // Sun disc (partial circle peeking from top-right)
    final sunCx = w * 0.82;
    const sunR = 52.0;
    canvas.drawCircle(Offset(sunCx, 0), sunR, Paint()..color = LaraColors.yellow.withValues(alpha: 0.55));
    // Halo ring
    canvas.drawCircle(
      Offset(sunCx, 0),
      sunR * 1.35,
      Paint()
        ..color = LaraColors.yellow.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sunR * 0.30,
    );

    // Swaying light rays from sun centre
    for (final ray in _rays) {
      final sway = math.sin(_time * 0.55 + ray.phase) * 7.0;
      final x0 = sunCx;
      const y0 = 0.0;
      final x1 = sunCx + math.cos(ray.angleFrac * math.pi) * (h * 1.1) + sway;
      final y1 = y0 + math.sin(ray.angleFrac * math.pi) * (h * 1.1);
      final half = ray.width * 0.5;

      final path = Path()
        ..moveTo(x0 - half + sway * 0.1, y0)
        ..lineTo(x0 + half + sway * 0.1, y0)
        ..lineTo(x1 + half, y1)
        ..lineTo(x1 - half, y1)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = LaraColors.yellow.withValues(alpha: ray.opacity)
          ..style = PaintingStyle.fill,
      );
    }

    // Soft sky-haze gradient at very top
    final hazeRect = Rect.fromLTWH(0, 0, w, h * 0.18);
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
        ).createShader(hazeRect),
    );
  }
}

class _Ray {
  const _Ray({required this.angleFrac, required this.width, required this.phase, required this.opacity});
  final double angleFrac;
  final double width;
  final double phase;
  final double opacity;
}
