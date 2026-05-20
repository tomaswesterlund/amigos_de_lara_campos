import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../rhenne_nada_game.dart';

class UnderwaterRock extends SpriteAnimationComponent
    with HasGameReference<RhenneNadaGame>, CollisionCallbacks {
  UnderwaterRock(SpriteAnimation animation)
      : super(animation: animation, size: Vector2.all(78), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.48, parentSize: size));
    // Gentle breathing pulse — feels alive underwater
    add(ScaleEffect.by(
      Vector2.all(1.02),
      EffectController(duration: 1.0, alternate: true, infinite: true, curve: Curves.easeInOut),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= game.scrollSpeed * dt;
    if (position.x < -size.x) removeFromParent();
  }
}
