import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../../shared/lara_theme.dart';
import '../galleta_run_game.dart';
import 'galleta.dart';

enum HeartType { normal, big, golden }

class CorazonPickup extends SpriteComponent
    with CollisionCallbacks, HasGameReference<GalletaRunGame> {
  CorazonPickup({
    required Sprite sprite,
    required this.speed,
    required this.type,
  }) : super(sprite: sprite, anchor: Anchor.center) {
    switch (type) {
      case HeartType.normal:
        size = Vector2.all(48);
      case HeartType.big:
        size = Vector2.all(68);
        paint = Paint()
          ..colorFilter = ColorFilter.mode(
            LaraColors.pink.withValues(alpha: 0.45),
            BlendMode.srcATop,
          );
      case HeartType.golden:
        size = Vector2.all(54);
        paint = Paint()
          ..colorFilter = ColorFilter.mode(
            LaraColors.yellow.withValues(alpha: 0.6),
            BlendMode.srcATop,
          );
    }
  }

  final double speed;
  final HeartType type;

  /// Points awarded when collected.
  int get points => switch (type) {
        HeartType.normal => 1,
        HeartType.big => 3,
        HeartType.golden => 5,
      };

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.5, parentSize: size));
    if (type == HeartType.golden) {
      // Slow spin to make golden hearts stand out.
      add(
        RotateEffect.by(
          math.pi * 2,
          EffectController(duration: 1.4, infinite: true, curve: Curves.linear),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Galleta) game.onHeartCollected(this);
  }
}
