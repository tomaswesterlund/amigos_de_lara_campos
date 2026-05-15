import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class Reina extends SpriteComponent {
  Reina(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2.all(96),
          anchor: Anchor.center,
        );

  bool celebrating = false;

  void celebrate() {
    celebrating = true;
    add(
      SequenceEffect(
        [
          ScaleEffect.to(Vector2.all(1.25), EffectController(duration: 0.25, curve: Curves.easeOut)),
          ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.25, curve: Curves.easeIn)),
        ],
        infinite: true,
      ),
    );
  }
}
