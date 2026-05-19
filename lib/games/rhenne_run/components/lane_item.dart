import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../shared/coin_draw.dart';

import '../../../shared/lara_theme.dart';

import '../rhenne_run_game.dart';
import 'runner_rhenne.dart';

enum LaneItemKind { heart, goldenHeart, pinkHeart, rock, fish, coin }

double _sizeFor(LaneItemKind k) {
  switch (k) {
    case LaneItemKind.rock:
      return 78;
    case LaneItemKind.goldenHeart:
      return 76;
    case LaneItemKind.pinkHeart:
      return 68;
    case LaneItemKind.heart:
      return 60;
    case LaneItemKind.fish:
      return 78;
    case LaneItemKind.coin:
      return 54;
  }
}

class LaneItem extends PositionComponent
    with CollisionCallbacks, HasGameReference<RhenneRunGame> {
  LaneItem({
    this.sprite,
    required this.kind,
    required this.lane,
  }) : super(
          size: Vector2.all(_sizeFor(kind)),
          anchor: Anchor.center,
        );

  final Sprite? sprite;
  final LaneItemKind kind;
  final int lane;
  double _pulseTimer = 0;

  @override
  Future<void> onLoad() async {
    switch (kind) {
      case LaneItemKind.rock:
        add(CircleHitbox.relative(0.38, parentSize: size));
      case LaneItemKind.fish:
        add(RectangleHitbox.relative(Vector2(0.55, 0.65), parentSize: size));
      case LaneItemKind.coin:
        add(CircleHitbox.relative(0.5, parentSize: size));
      default:
        add(CircleHitbox.relative(0.5, parentSize: size));
    }
    if (kind == LaneItemKind.goldenHeart) {
      add(
        ScaleEffect.by(
          Vector2.all(1.12),
          EffectController(
            duration: 0.45,
            alternate: true,
            infinite: true,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
    if (kind == LaneItemKind.fish) {
      add(
        ScaleEffect.by(
          Vector2.all(1.12),
          EffectController(
            duration: 0.30,
            alternate: true,
            infinite: true,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
    if (kind == LaneItemKind.coin) {
      add(ScaleEffect.by(
        Vector2.all(1.18),
        EffectController(duration: 0.48, alternate: true, infinite: true, curve: Curves.easeInOut),
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    if (kind == LaneItemKind.coin) {
      drawCoin(canvas, size.x, size.y);
      return;
    }
    if (kind == LaneItemKind.rock || kind == LaneItemKind.fish) {
      final pulse = sin(_pulseTimer * 7.0) * 0.5 + 0.5;
      final auraColor = kind == LaneItemKind.rock
          ? const Color(0xFF6E6470)
          : LaraColors.corazonRed;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2),
          width:  size.x * (0.68 + pulse * 0.18),
          height: size.y * (0.72 + pulse * 0.18),
        ),
        Paint()
          ..color = auraColor.withValues(alpha: 0.12 + pulse * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }
    if (kind == LaneItemKind.fish) {
      _drawFish(canvas, size.x, size.y);
      return;
    }
    sprite?.render(canvas, size: size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTimer += dt;
    position.y += game.scrollSpeed * dt;
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! RunnerRhenne) return;
    switch (kind) {
      case LaneItemKind.heart:
        game.onHeartPicked(this, points: 1);
      case LaneItemKind.goldenHeart:
        game.onHeartPicked(this, points: 10);
      case LaneItemKind.pinkHeart:
        game.onHeartPicked(this, points: 3);
      case LaneItemKind.rock:
        game.onCrash();
      case LaneItemKind.fish:
        game.onCrash();
      case LaneItemKind.coin:
        game.onCoinPicked(this);
    }
  }
}

// ─── Programmatic fish drawing ────────────────────────────────────────────────

void _drawFish(Canvas canvas, double w, double h) {
  const bodyColor = LaraColors.corazonRed;
  const finColor  = Color(0xFFB02040);

  final bodyPaint = Paint()..color = bodyColor;
  final finPaint  = Paint()..color = finColor;

  // Forked tail on the right
  canvas.drawPath(
    Path()
      ..moveTo(w * 0.65, h * 0.50)
      ..lineTo(w * 0.98, h * 0.10)
      ..lineTo(w * 0.80, h * 0.50)
      ..close(),
    finPaint,
  );
  canvas.drawPath(
    Path()
      ..moveTo(w * 0.65, h * 0.50)
      ..lineTo(w * 0.98, h * 0.90)
      ..lineTo(w * 0.80, h * 0.50)
      ..close(),
    finPaint,
  );

  // Body — elongated oval, facing left
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(w * 0.38, h * 0.50),
      width:  w * 0.72,
      height: h * 0.56,
    ),
    bodyPaint,
  );

  // Dorsal fin (top)
  canvas.drawPath(
    Path()
      ..moveTo(w * 0.25, h * 0.22)
      ..lineTo(w * 0.40, h * 0.01)
      ..lineTo(w * 0.55, h * 0.22)
      ..close(),
    finPaint,
  );

  // Pectoral fin (bottom)
  canvas.drawPath(
    Path()
      ..moveTo(w * 0.32, h * 0.70)
      ..lineTo(w * 0.18, h * 0.92)
      ..lineTo(w * 0.44, h * 0.72)
      ..close(),
    finPaint,
  );

  // Eye
  canvas.drawCircle(Offset(w * 0.16, h * 0.44), w * 0.08,
      Paint()..color = Colors.white);
  canvas.drawCircle(Offset(w * 0.15, h * 0.45), w * 0.046,
      Paint()..color = const Color(0xFF1A1A2E));

  // Angry eyebrow
  canvas.drawLine(
    Offset(w * 0.08, h * 0.34),
    Offset(w * 0.23, h * 0.32),
    Paint()
      ..color = finColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round,
  );

  // Mouth
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(w * 0.035, h * 0.54),
      width: w * 0.10, height: h * 0.18,
    ),
    Paint()..color = const Color(0xFF800020),
  );

  // Tooth
  canvas.drawPath(
    Path()
      ..moveTo(w * 0.04, h * 0.47)
      ..lineTo(w * 0.00, h * 0.52)
      ..lineTo(w * 0.07, h * 0.52)
      ..close(),
    Paint()..color = Colors.white,
  );
}
