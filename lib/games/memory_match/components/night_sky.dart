import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../shared/collectibles_state.dart';
import '../../../shared/lara_theme.dart';
import '../../../shared/qr_unlock_state.dart';

// Y fraction where the ground strip begins (shared by ground and walkers).
const _kGroundY = 0.88;

class NightSkyLayer extends PositionComponent with HasGameReference {
  NightSkyLayer() : super(priority: -500);

  static const _seed = 42;

  static List<String> _unlockedSpriteNames() {
    final names = <String>[];
    for (var i = 0; i < CollectiblesState.count; i++) {
      if (CollectiblesState.isUnlocked('rhenne', i))  names.add('rhenne_l${i + 1}.png');
      if (CollectiblesState.isUnlocked('galleta', i)) names.add('galleta_l${i + 1}.png');
      if (CollectiblesState.isUnlocked('heart', i))   names.add('corazon_l${i + 1}.png');
    }
    for (var i = 0; i < QrUnlockState.count; i++) {
      if (QrUnlockState.isUnlocked(i)) names.add('lara_d${i + 1}.png');
    }
    if (names.isEmpty) names.addAll(['rhenne.png', 'galleta.png']);
    return names;
  }

  late final List<_Star> _stars;
  late final _ShootingStar _shooting;
  double _elapsed = 0;

  @override
  Future<void> onLoad() async {
    final rng = Random(_seed);
    _stars = List.generate(28, (i) => _Star(
      fx: rng.nextDouble(),
      fy: rng.nextDouble() * 0.75,
      radius: i < 22 ? 1.0 + rng.nextDouble() : 3.0 + rng.nextDouble() * 2,
      isSpark: i >= 22,
      phase: rng.nextDouble() * pi * 2,
      speed: 0.6 + rng.nextDouble() * 1.2,
      color: i >= 22
          ? (rng.nextBool() ? LaraColors.yellow : LaraColors.mint)
          : Colors.white,
    ));

    final shootDelay = 4.0 + Random().nextDouble() * 4;
    _shooting = _ShootingStar(delay: shootDelay);

    add(_GroundStrip());

    final walkRng = Random();
    final walkerNames = _unlockedSpriteNames()..shuffle(walkRng);
    final delays = [3.0 + walkRng.nextDouble() * 5, 9.0 + walkRng.nextDouble() * 7];
    for (var i = 0; i < 2; i++) {
      add(_Walker(
        sprite: await game.loadSprite(walkerNames[i % walkerNames.length]),
        initialDelay: delays[i],
        fromLeft: i == 0,
      ));
    }
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    _shooting.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;

    _drawMoon(canvas, w, h);
    _drawStars(canvas, w, h);
    _shooting.render(canvas, w, h);
  }

  void _drawMoon(Canvas canvas, double w, double h) {
    final cx = w * 0.82;
    final cy = h * 0.13;
    final r = (w * 0.07).clamp(22.0, 52.0);

    for (final (factor, alpha) in [
      (2.6, 0.04),
      (1.9, 0.08),
      (1.45, 0.13),
    ]) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * factor,
        Paint()..color = const Color(0xFFFFFDE7).withValues(alpha: alpha),
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFFFFFDE7),
    );

    canvas.drawCircle(
      Offset(cx - r * 0.28, cy - r * 0.12),
      r * 0.82,
      Paint()..color = const Color(0xFF1A1050).withValues(alpha: 0.55),
    );
  }

  void _drawStars(Canvas canvas, double w, double h) {
    for (final star in _stars) {
      final alpha = 0.45 + 0.55 * (0.5 + 0.5 * sin(_elapsed * star.speed + star.phase));
      final paint = Paint()..color = star.color.withValues(alpha: alpha);

      final x = star.fx * w;
      final y = star.fy * h;

      if (star.isSpark) {
        _drawSparkle(canvas, x, y, star.radius, paint);
      } else {
        canvas.drawCircle(Offset(x, y), star.radius, paint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, double x, double y, double r, Paint paint) {
    final linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y - r), Offset(x, y + r), linePaint);
    canvas.drawLine(Offset(x - r, y), Offset(x + r, y), linePaint);
    final d = r * 0.6;
    final dimPaint = Paint()
      ..color = paint.color.withValues(alpha: paint.color.a * 0.5)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x - d, y - d), Offset(x + d, y + d), dimPaint);
    canvas.drawLine(Offset(x + d, y - d), Offset(x - d, y + d), dimPaint);
  }

}

// ─── Ground strip ─────────────────────────────────────────────────────────────

class _GroundStrip extends PositionComponent with HasGameReference {
  _GroundStrip() : super(priority: -100);

  // Layers from top (far/horizon) to bottom (near). Each entry is
  // (height in px, color). The final soil fills whatever remains.
  static const _layers = [
    (2.0,  Color(0xFF1A3020)), // shadow edge at horizon
    (5.0,  Color(0xFF3D5C4E)), // distant moonlit field — muted teal-green
    (7.0,  Color(0xFF35523A)), // mid-far — slightly greener
    (9.0,  Color(0xFF2E5232)), // mid — richer green
    (9.0,  Color(0xFF3A6E30)), // near ground — most saturated
  ];
  static const _soilColor = Color(0xFF0E1A10);

  void _refit(Vector2 gameSize) {
    position = Vector2(0, gameSize.y * _kGroundY);
    size = Vector2(gameSize.x, gameSize.y * (1 - _kGroundY));
  }

  @override
  void onMount() {
    super.onMount();
    _refit(game.size);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _refit(gameSize);
  }

  @override
  void render(Canvas canvas) {
    var y = 0.0;
    for (final (layerH, color) in _layers) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.x, layerH), Paint()..color = color);
      y += layerH;
    }
    // Soil fills the rest of the component area.
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.x, size.y - y),
      Paint()..color = _soilColor,
    );
  }
}

// ─── Walking characters ───────────────────────────────────────────────────────

class _Walker extends SpriteComponent with HasGameReference {
  _Walker({
    required Sprite sprite,
    required double initialDelay,
    required bool fromLeft,
  })  : _wait = initialDelay,
        _fromLeft = fromLeft,
        super(
          sprite: sprite,
          size: Vector2.all(36),
          anchor: Anchor.bottomCenter,
          priority: -90,
        );

  static const _speed = 42.0;
  static const _bobAmp = 1.8;
  static const _bobFreq = 2.2; // steps per second
  static const _minGap = 10.0;
  static const _maxGap = 22.0;

  bool _fromLeft;
  double _wait;
  bool _walking = false;
  double _t = 0; // continuous time for bobbing

  double get _groundY => game.size.y * _kGroundY;

  @override
  void onMount() {
    super.onMount();
    position = Vector2(-300, -300); // park off-screen until first walk
  }

  @override
  void update(double dt) {
    _t += dt;

    if (!_walking) {
      _wait -= dt;
      if (_wait <= 0) _beginWalk();
      return;
    }

    position.x += _speed * (_fromLeft ? 1.0 : -1.0) * dt;

    // Smooth footstep bob: (1 - cos) lifts the feet periodically from ground.
    final bob = (1 - cos(_t * _bobFreq * 2 * pi)) / 2 * _bobAmp;
    position.y = _groundY - bob;

    final w = game.size.x;
    if ((_fromLeft && position.x > w + size.x) ||
        (!_fromLeft && position.x < -size.x)) {
      _endWalk();
    }
  }

  void _beginWalk() {
    _walking = true;
    final w = game.size.x;
    position.x = _fromLeft ? -size.x / 2 : w + size.x / 2;
    position.y = _groundY;
    // Mirror sprite when walking right-to-left.
    scale = _fromLeft ? Vector2(1, 1) : Vector2(-1, 1);
  }

  void _endWalk() {
    _walking = false;
    position = Vector2(-300, -300);
    _fromLeft = !_fromLeft; // alternate direction each crossing
    _wait = _minGap + Random().nextDouble() * (_maxGap - _minGap);
  }
}

// ─── Star data ────────────────────────────────────────────────────────────────

class _Star {
  const _Star({
    required this.fx,
    required this.fy,
    required this.radius,
    required this.isSpark,
    required this.phase,
    required this.speed,
    required this.color,
  });

  final double fx;
  final double fy;
  final double radius;
  final bool isSpark;
  final double phase;
  final double speed;
  final Color color;
}

// ─── Shooting star ────────────────────────────────────────────────────────────

class _ShootingStar {
  _ShootingStar({required double delay}) : _delay = delay;

  final double _delay;
  double _t = 0;
  static const _duration = 0.6;
  static const _length = 80.0;

  bool get _active => _t >= _delay && _t < _delay + _duration;

  void update(double dt) => _t += dt;

  void render(Canvas canvas, double w, double h) {
    if (!_active) return;

    final progress = (_t - _delay) / _duration;
    const startFx = 0.75;
    const startFy = 0.08;
    const dx = -0.18;
    const dy = 0.10;

    final sx = (startFx + dx * progress) * w;
    final sy = (startFy + dy * progress) * h;
    final ex = sx - _length * cos(pi / 4);
    final ey = sy - _length * sin(pi / 4);

    final alpha = sin(progress * pi).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.9)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
  }
}
