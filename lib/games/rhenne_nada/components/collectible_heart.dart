import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../rhenne_nada_game.dart';

class CollectibleHeart extends SpriteComponent
    with HasGameReference<RhenneNadaGame>, CollisionCallbacks {
  CollectibleHeart(Sprite sprite, {required this.points})
      : super(sprite: sprite, size: Vector2.all(62), anchor: Anchor.center);

  final int points;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(Vector2(0.7, 0.7), parentSize: size));
    // Idle pulse — brighter for higher-value hearts
    final pulseScale = points >= 10 ? 1.18 : (points >= 3 ? 1.12 : 1.08);
    final pulseDuration = points >= 10 ? 0.4 : 0.55;
    add(ScaleEffect.by(
      Vector2.all(pulseScale),
      EffectController(
          duration: pulseDuration, alternate: true, infinite: true, curve: Curves.easeInOut),
    ));
    // Golden hearts also rotate gently
    if (points >= 10) {
      add(RotateEffect.by(
        0.35,
        EffectController(duration: 0.8, alternate: true, infinite: true, curve: Curves.easeInOut),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= game.scrollSpeed * dt;
    if (position.x < -size.x) removeFromParent();
  }
}
