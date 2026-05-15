import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class Rhenne extends SpriteComponent {
  Rhenne(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2.all(96),
          anchor: Anchor.center,
        );

  bool isJumping = false;

  void hop({required void Function() onLand}) {
    if (isJumping) return;
    isJumping = true;
    add(
      MoveByEffect(
        Vector2(0, -90),
        EffectController(duration: 0.28, curve: Curves.easeOut),
        onComplete: () {
          add(
            MoveByEffect(
              Vector2(0, 90),
              EffectController(duration: 0.28, curve: Curves.easeIn),
              onComplete: () {
                isJumping = false;
                onLand();
              },
            ),
          );
        },
      ),
    );
  }
}
