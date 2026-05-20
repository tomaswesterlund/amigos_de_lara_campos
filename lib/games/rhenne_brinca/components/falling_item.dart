import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_brinca_game.dart';
import 'brinca_rhenne.dart';

enum FallingItemKind { raindrop, leaf, acorn, firefly, heart, pinkHeart, star }

double _sizeFor(FallingItemKind k) => switch (k) {
      FallingItemKind.raindrop  => 26,
      FallingItemKind.leaf      => 48,
      FallingItemKind.acorn     => 42,
      FallingItemKind.firefly   => 36,
      FallingItemKind.heart     => 58,
      FallingItemKind.pinkHeart => 52,
      FallingItemKind.star      => 50,
    };

double _speedFor(FallingItemKind k) => switch (k) {
      // Raindrop reduced from 1.45 → 1.20 to limit tunneling risk at max speed.
      FallingItemKind.raindrop  => 1.20,
      FallingItemKind.leaf      => 0.72,
      FallingItemKind.acorn     => 1.25,
      FallingItemKind.firefly   => 0.60,
      FallingItemKind.heart     => 0.90,
      FallingItemKind.pinkHeart => 0.90,
      FallingItemKind.star      => 0.80,
    };

bool _isObstacle(FallingItemKind k) =>
    k == FallingItemKind.raindrop ||
    k == FallingItemKind.leaf ||
    k == FallingItemKind.acorn;

int _pointsFor(FallingItemKind k) => switch (k) {
      FallingItemKind.firefly   => 1,
      FallingItemKind.heart     => 3,
      FallingItemKind.pinkHeart => 5,
      FallingItemKind.star      => 10,
      _                         => 0,
    };

const _leafColors = [
  Color(0xFF2D5A0E), // dark forest green
  Color(0xFF5C4A1A), // muddy brown-green
  Color(0xFF3A5C1A), // deep olive
];

/// A falling collectible or obstacle.
///
/// Split into two layers so that scale animations on the visual never
/// change the hitbox size:
///   • [FallingItem] (PositionComponent) owns the hitbox and movement.
///     Hitboxes are sized at 0.65 relative (was 0.44) — combined detection
///     zone with Rhenné's 0.68 hitbox is now ~54 px vs the previous ~25 px.
///   • [_ItemVisual] (PositionComponent child) owns all rendering and any
///     scale/rotate idle animations (firefly pulse, star spin, heart throb).
class FallingItem extends PositionComponent
    with CollisionCallbacks, HasGameReference<RhenneBrincaGame> {
  FallingItem({required this.kind, required this.lane, this.sprite})
      : super(
          size: Vector2.all(_sizeFor(kind)),
          anchor: Anchor.center,
        );

  final FallingItemKind kind;
  final int lane;
  final Sprite? sprite;

  double _pulseTimer  = 0;
  double _wobblePhase = 0;
  final _rng = math.Random();
  late final Color _leafColor;
  late final List<double> _trailDx;

  @override
  Future<void> onLoad() async {
    _leafColor   = _leafColors[_rng.nextInt(_leafColors.length)];
    _wobblePhase = _rng.nextDouble() * math.pi * 2;
    _trailDx     = List.generate(3, (_) => (_rng.nextDouble() - 0.5) * size.x * 0.55);

    // Hitbox on the parent — fixed size, never affected by visual effects.
    // Raindrop uses a narrower rectangle to match its teardrop silhouette;
    // all others use a circle at 65 % of the sprite diameter.
    switch (kind) {
      case FallingItemKind.raindrop:
        add(RectangleHitbox.relative(Vector2(0.60, 0.88), parentSize: size));
      default:
        add(CircleHitbox.relative(0.65, parentSize: size));
    }

    // Visual child — all idle scale/rotate effects live here so the hitbox
    // above is never resized by animation.
    final visual = _ItemVisual(parent: this, size: size);
    add(visual);

    if (kind == FallingItemKind.firefly) {
      visual.add(ScaleEffect.by(
        Vector2.all(1.28),
        EffectController(duration: 0.38, alternate: true, infinite: true, curve: Curves.easeInOut),
      ));
    }
    if (kind == FallingItemKind.star) {
      visual.add(RotateEffect.by(
        math.pi * 2,
        EffectController(duration: 1.8, infinite: true, curve: Curves.linear),
      ));
    }
    if (kind == FallingItemKind.heart || kind == FallingItemKind.pinkHeart) {
      visual.add(ScaleEffect.by(
        Vector2.all(kind == FallingItemKind.pinkHeart ? 1.14 : 1.10),
        EffectController(duration: 0.45, alternate: true, infinite: true, curve: Curves.easeInOut),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTimer += dt;

    final speed = game.scrollSpeed * _speedFor(kind);
    position.y += speed * dt;

    if (kind == FallingItemKind.leaf) {
      position.x += math.sin(_pulseTimer * 1.8 + _wobblePhase) * 1.6;
    }

    if (position.y > game.size.y + size.y) removeFromParent();
  }

  /// All drawing is delegated here from [_ItemVisual.render] so that the
  /// visual's scale/rotate effects affect only the canvas, not the hitbox.
  void _renderVisual(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    if (_isObstacle(kind)) {
      _drawDangerAura(canvas, w, h, _pulseTimer);
    } else {
      final glowColor = switch (kind) {
        FallingItemKind.firefly   => LaraColors.yellow,
        FallingItemKind.heart     => LaraColors.pink,
        FallingItemKind.pinkHeart => LaraColors.pink,
        _                         => LaraColors.yellow,
      };
      _drawCollectibleGlow(canvas, w, h, glowColor);
      _drawSparkleTrail(canvas, w, h, _pulseTimer, glowColor, _trailDx);
    }

    switch (kind) {
      case FallingItemKind.raindrop:
        _drawRaindrop(canvas, w, h);
      case FallingItemKind.leaf:
        _drawLeaf(canvas, w, h, _leafColor);
      case FallingItemKind.acorn:
        _drawAcorn(canvas, w, h);
      case FallingItemKind.firefly:
        _drawFirefly(canvas, w, h, _pulseTimer);
      case FallingItemKind.star:
        _drawStar(canvas, w, h);
      case FallingItemKind.heart:
      case FallingItemKind.pinkHeart:
        sprite?.render(canvas, size: size);
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! BrincaRhenne) return;
    // Guard against mid-arc phantom collisions: only register when Rhenné's
    // centre is within ±45 % of this lane's width from the lane centre.
    // This prevents an item in lane 0 from hitting Rhenné mid-jump to lane 2.
    if ((other.position.x - game.laneCenterX(lane)).abs() > game.laneWidth * 0.45) return;
    if (_isObstacle(kind)) {
      game.onObstacleHit();
    } else {
      game.onItemCaught(this, _pointsFor(kind));
    }
  }
}

// ── Visual-only child ─────────────────────────────────────────────────────────

/// Rendering + idle-animation child of [FallingItem]. Scale/rotate effects
/// applied here never affect the parent's hitbox.
class _ItemVisual extends PositionComponent {
  _ItemVisual({required FallingItem parent, required Vector2 size})
      : _parent = parent,
        super(
          size: size,
          anchor: Anchor.center,
          // Centre of this visual = centre of parent's local space.
          position: size / 2,
        );

  final FallingItem _parent;

  @override
  void render(Canvas canvas) => _parent._renderVisual(canvas);
}

// ── Shared aura helpers ───────────────────────────────────────────────────────

/// Pulsing red-orange rings drawn just outside the actual hitbox (≈ 1.10×
/// item size) so the danger zone is not visually exaggerated.
void _drawDangerAura(Canvas canvas, double w, double h, double t) {
  final pulse = math.sin(t * 4.2) * 0.5 + 0.5;

  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(w / 2, h * 0.68),
      width:  w * 1.00,
      height: h * 0.26,
    ),
    Paint()..color = Colors.black.withValues(alpha: 0.10 + pulse * 0.08),
  );

  // Outer warning ring — sized close to the hitbox boundary (0.65 × sprite).
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width:  w * (1.10 + pulse * 0.08),
      height: h * (1.10 + pulse * 0.08),
    ),
    Paint()
      ..color       = const Color(0xFFFF3300).withValues(alpha: 0.10 + pulse * 0.13)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 3.2,
  );

  // Inner ring for depth.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width:  w * (0.84 + pulse * 0.06),
      height: h * (0.84 + pulse * 0.06),
    ),
    Paint()
      ..color       = const Color(0xFFFF1100).withValues(alpha: 0.06 + pulse * 0.08)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.8,
  );
}

/// Warm halo drawn just outside the hitbox (≈ 1.20× item size) so the
/// catch zone is not visually overstated.
void _drawCollectibleGlow(Canvas canvas, double w, double h, Color glowColor) {
  final cx = w / 2;
  final cy = h / 2;
  final r  = w / 2;

  canvas.drawCircle(
    Offset(cx, cy), r * 1.20,
    Paint()..color = glowColor.withValues(alpha: 0.12),
  );
  canvas.drawCircle(
    Offset(cx, cy), r * 0.95,
    Paint()..color = glowColor.withValues(alpha: 0.28),
  );
}

/// Tiny glitter dots above the item — simulate a "magic trail" as it falls.
void _drawSparkleTrail(
    Canvas canvas, double w, double h, double t, Color color,
    List<double> dxOffsets) {
  const yOffsets = [-16.0, -27.0, -38.0];
  const alphas   = [0.40,   0.25,   0.12];
  const radii    = [2.4,    1.8,    1.2];

  for (var i = 0; i < 3; i++) {
    final twinkle = math.sin(t * 3.5 + i * 1.4) * 0.15 + 0.85;
    canvas.drawCircle(
      Offset(w / 2 + dxOffsets[i], h / 2 + yOffsets[i]),
      radii[i],
      Paint()..color = color.withValues(alpha: alphas[i] * twinkle),
    );
  }
}

// ── Per-kind drawing ─────────────────────────────────────────────────────────

void _drawRaindrop(Canvas canvas, double w, double h) {
  const bodyColor = Color(0xFF1A2E4A);

  final path = Path()
    ..moveTo(w / 2, h)
    ..cubicTo(0, h * 0.55, 0, h * 0.15, w / 2, h * 0.08)
    ..cubicTo(w, h * 0.15, w, h * 0.55, w / 2, h)
    ..close();

  canvas.drawPath(path, Paint()..color = bodyColor.withValues(alpha: 0.92));

  canvas.drawLine(
    Offset(w * 0.36, h * 0.18),
    Offset(w * 0.36, h * 0.56),
    Paint()
      ..color       = const Color(0xFFFF6622).withValues(alpha: 0.65)
      ..strokeWidth = 2.2
      ..strokeCap   = StrokeCap.round,
  );
}

void _drawLeaf(Canvas canvas, double w, double h, Color color) {
  final paint = Paint()..color = color.withValues(alpha: 0.88);
  canvas.drawOval(Rect.fromLTWH(w * 0.08, h * 0.10, w * 0.84, h * 0.80), paint);

  canvas.drawLine(
    Offset(w / 2, h * 0.12),
    Offset(w / 2, h * 0.88),
    Paint()
      ..color       = Colors.black.withValues(alpha: 0.30)
      ..strokeWidth = 1.8
      ..strokeCap   = StrokeCap.round,
  );
  for (final sign in [-1, 1]) {
    canvas.drawLine(
      Offset(w / 2, h * 0.38),
      Offset(w / 2 + sign * w * 0.30, h * 0.62),
      Paint()
        ..color       = Colors.black.withValues(alpha: 0.20)
        ..strokeWidth = 1.2
        ..strokeCap   = StrokeCap.round,
    );
  }
}

void _drawAcorn(Canvas canvas, double w, double h) {
  const bodyColor = Color(0xFF5C3010);
  const capColor  = Color(0xFF2E1808);

  canvas.drawOval(
    Rect.fromLTWH(w * 0.18, h * 0.38, w * 0.64, h * 0.56),
    Paint()..color = bodyColor,
  );
  canvas.drawOval(
    Rect.fromLTWH(w * 0.30, h * 0.42, w * 0.22, h * 0.18),
    Paint()..color = Colors.white.withValues(alpha: 0.14),
  );
  canvas.drawOval(
    Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.30),
    Paint()..color = capColor,
  );
  canvas.drawLine(
    Offset(w * 0.50, h * 0.20),
    Offset(w * 0.55, h * 0.04),
    Paint()
      ..color       = capColor
      ..strokeWidth = 3
      ..strokeCap   = StrokeCap.round,
  );
  for (var i = 0; i < 5; i++) {
    canvas.drawCircle(
      Offset(w * (0.22 + i * 0.14), h * 0.30),
      2.0,
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
  }
}

void _drawFirefly(Canvas canvas, double w, double h, double time) {
  final cx = w / 2;
  final cy = h / 2;
  final r  = w / 2 * 0.38;

  canvas.drawCircle(Offset(cx, cy), r * 1.6,
      Paint()..color = LaraColors.yellow.withValues(alpha: 0.25));
  canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = LaraColors.yellow.withValues(alpha: 0.96));
  canvas.drawCircle(Offset(cx - r * 0.30, cy - r * 0.30), r * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.78));

  const orbitR = [1.85, 1.85, 1.85];
  const speeds = [0.8,  1.3,  1.9];
  const phases = [0.0,  2.1,  4.2];
  for (var i = 0; i < 3; i++) {
    final angle = time * speeds[i] + phases[i];
    final dx    = math.cos(angle) * r * orbitR[i];
    final dy    = math.sin(angle) * r * orbitR[i];
    canvas.drawCircle(
      Offset(cx + dx, cy + dy),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: 0.70),
    );
  }
}

void _drawStar(Canvas canvas, double w, double h) {
  final cx     = w / 2;
  final cy     = h / 2;
  final outerR = w / 2 * 0.88;
  final innerR = outerR * 0.40;
  const n      = 5;

  final path = Path();
  for (var i = 0; i < n * 2; i++) {
    final r     = i.isEven ? outerR : innerR;
    final angle = i * math.pi / n - math.pi / 2;
    final x = cx + r * math.cos(angle);
    final y = cy + r * math.sin(angle);
    if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
  }
  path.close();

  canvas.drawPath(path, Paint()..color = LaraColors.yellow);
  canvas.drawPath(
    path,
    Paint()
      ..color       = Colors.white.withValues(alpha: 0.52)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 2.2,
  );
  canvas.drawCircle(Offset(cx, cy), outerR * 0.24,
      Paint()..color = Colors.white.withValues(alpha: 0.68));

  for (var i = 0; i < n; i++) {
    final angle = i * (math.pi * 2) / n - math.pi / 2;
    final tipX  = cx + math.cos(angle) * outerR;
    final tipY  = cy + math.sin(angle) * outerR;
    canvas.drawCircle(
      Offset(tipX, tipY), 2.8,
      Paint()..color = Colors.white.withValues(alpha: 0.60),
    );
  }
}
