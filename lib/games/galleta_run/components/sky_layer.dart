import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../shared/lara_theme.dart';

/// Static (non-scrolling) sky backdrop rendered behind everything else.
///
/// Contains three layers of detail:
///   1. Sun — upper-right area with slowly rotating rays and a glow halo.
///   2. Sparkle stars — 12 cream 4-point stars that drift left very slowly
///      and re-randomise their y position when they wrap.
///   3. Background birds — two loose flocks of tiny V-silhouettes that fly
///      left at ≈15 px/s, giving the sky a sense of life without competing
///      with the interactive BirdObstacle.
class SkyLayer extends PositionComponent {
  SkyLayer({
    required double screenWidth,
    required double screenHeight,
    required math.Random rng,
  })  : _sw = screenWidth,
        _sh = screenHeight,
        _rng = rng,
        super(priority: -70);

  final double _sw;
  final double _sh;
  final math.Random _rng;

  double _rayAngle = 0;
  late final List<_Star> _stars;
  late final List<_BgBird> _birds;

  @override
  Future<void> onLoad() async {
    _stars = List.generate(12, (i) {
      return _Star(
        x: _rng.nextDouble() * _sw,
        y: _sh * (0.05 + _rng.nextDouble() * 0.52),
        speed: 3.5 + _rng.nextDouble() * 7.0,
        radius: 1.8 + _rng.nextDouble() * 3.8,
        phase: _rng.nextDouble() * math.pi * 2,
      );
    });

    // Two loose flocks of 3 birds each at different altitudes.
    _birds = [];
    for (int g = 0; g < 2; g++) {
      final baseX = _sw * (0.25 + g * 0.45) + _rng.nextDouble() * 60;
      final baseY = _sh * (0.10 + _rng.nextDouble() * 0.18);
      final spd = 13.0 + _rng.nextDouble() * 7.0;
      for (int b = 0; b < 3; b++) {
        _birds.add(_BgBird(
          x: baseX + b * 26.0,
          y: baseY + (b.isEven ? 0 : 9.0),
          speed: spd + b * 1.2,
        ));
      }
    }
  }

  @override
  void update(double dt) {
    _rayAngle += dt * 0.22;

    for (final s in _stars) {
      s.x -= s.speed * dt;
      if (s.x < -8) {
        s.x = _sw + 8;
        s.y = _sh * (0.05 + _rng.nextDouble() * 0.52);
      }
    }

    for (final b in _birds) {
      b.x -= b.speed * dt;
      if (b.x < -24) {
        b.x = _sw + 24 + _rng.nextDouble() * 80;
        b.y = _sh * (0.08 + _rng.nextDouble() * 0.20);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    _drawSun(canvas);
    _drawStars(canvas);
    _drawBgBirds(canvas);
  }

  void _drawSun(Canvas canvas) {
    final sx = _sw * 0.80;
    final sy = _sh * 0.13;

    // Soft outer glow rings
    canvas.drawCircle(Offset(sx, sy), 54,
        Paint()..color = LaraColors.yellow.withValues(alpha: 0.14));
    canvas.drawCircle(Offset(sx, sy), 40,
        Paint()..color = LaraColors.yellow.withValues(alpha: 0.20));

    // Animated rays — brightness pulses slightly per ray
    final rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;
    for (int i = 0; i < 8; i++) {
      final angle = _rayAngle + i * math.pi / 4;
      final alpha = 0.42 + 0.14 * math.sin(_rayAngle * 2.5 + i);
      rayPaint.color = LaraColors.yellow.withValues(alpha: alpha);
      canvas.drawLine(
        Offset(sx + math.cos(angle) * 33, sy + math.sin(angle) * 33),
        Offset(sx + math.cos(angle) * 58, sy + math.sin(angle) * 58),
        rayPaint,
      );
    }

    // Core disc
    canvas.drawCircle(Offset(sx, sy), 28, Paint()..color = LaraColors.yellow);
    // Shine highlight
    canvas.drawCircle(Offset(sx - 8, sy - 7), 10,
        Paint()..color = LaraColors.cream.withValues(alpha: 0.62));
  }

  void _drawStars(Canvas canvas) {
    for (final s in _stars) {
      final alpha =
          (0.40 + 0.35 * math.sin(s.phase + _rayAngle * 2.8)).clamp(0.12, 0.82);
      final p = Paint()
        ..color = LaraColors.cream.withValues(alpha: alpha)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      // 4-pointed sparkle
      for (int i = 0; i < 4; i++) {
        final a = i * math.pi / 2;
        canvas.drawLine(
          Offset(s.x, s.y),
          Offset(s.x + math.cos(a) * s.radius, s.y + math.sin(a) * s.radius),
          p,
        );
      }
      canvas.drawCircle(Offset(s.x, s.y), s.radius * 0.28, p);
    }
  }

  void _drawBgBirds(Canvas canvas) {
    final p = Paint()
      ..color = LaraColors.ink.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (final b in _birds) {
      final path = Path()
        ..moveTo(b.x - 9, b.y - 4)
        ..quadraticBezierTo(b.x, b.y + 5, b.x + 9, b.y - 4);
      canvas.drawPath(path, p);
    }
  }
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.phase,
  });
  double x;
  double y;
  final double speed;
  final double radius;
  final double phase;
}

class _BgBird {
  _BgBird({required this.x, required this.y, required this.speed});
  double x;
  double y;
  final double speed;
}
