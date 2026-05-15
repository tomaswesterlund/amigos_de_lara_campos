import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class FlyingRhenne extends SpriteComponent with CollisionCallbacks {
  FlyingRhenne(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2.all(72),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.65, parentSize: size));
  }

  /// Pop animation on each flap.
  void flap() {
    add(
      ScaleEffect.by(
        Vector2.all(1.18),
        EffectController(
          duration: 0.08,
          alternate: true,
          reverseDuration: 0.08,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  /// Tilt the sprite toward the velocity vector for character.
  void tiltFromVelocity(double velocityY) {
    angle = (velocityY / 800).clamp(-0.55, 0.7);
  }
}
