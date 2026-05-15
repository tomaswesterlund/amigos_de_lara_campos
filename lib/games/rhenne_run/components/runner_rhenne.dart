import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class RunnerRhenne extends SpriteComponent with CollisionCallbacks {
  RunnerRhenne(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  Effect? _bounce;
  Effect? _slide;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(Vector2(0.55, 0.6), parentSize: size));
    _bounce = MoveByEffect(
      Vector2(0, -6),
      EffectController(
        duration: 0.18,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    );
    add(_bounce!);
  }

  void slideTo(double x) {
    _slide?.removeFromParent();
    final dx = x - position.x;
    _slide = MoveByEffect(
      Vector2(dx, 0),
      EffectController(duration: 0.12, curve: Curves.easeOut),
    );
    add(_slide!);
    // Little tilt with the slide, then settle.
    final tilt = dx.sign * (pi / 14);
    add(
      RotateEffect.to(
        tilt,
        EffectController(duration: 0.08, alternate: true, reverseDuration: 0.12),
      ),
    );
  }

  /// Stops the running bounce and plays a brief "oops" crash animation.
  Future<void> crash() async {
    _bounce?.removeFromParent();
    add(
      RotateEffect.by(pi * 2, EffectController(duration: 0.55, curve: Curves.easeIn)),
    );
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.55, curve: Curves.easeIn),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 550));
  }
}
