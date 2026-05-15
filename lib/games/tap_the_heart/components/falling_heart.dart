import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';

import '../tap_heart_game.dart';

class FallingHeart extends SpriteComponent
    with TapCallbacks, HasGameReference<TapHeartGame> {
  FallingHeart({
    required Sprite sprite,
    required this.fallSpeed,
    required this.points,
  }) : super(
          sprite: sprite,
          size: Vector2.all(72),
          anchor: Anchor.center,
        );

  final double fallSpeed;
  final int points;
  bool _tapped = false;
  bool _missed = false;

  @override
  Future<void> onLoad() async {
    // Size and pulse vary with rarity — consistent with Rhenné Corre's golden heart.
    if (points >= 10) {
      size = Vector2.all(82);
      add(ScaleEffect.by(
        Vector2.all(1.12),
        EffectController(
          duration: 0.45,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ));
    } else if (points >= 3) {
      size = Vector2.all(72);
    } else {
      size = Vector2.all(64);
    }

    add(RotateEffect.by(
      0.4,
      EffectController(
        duration: 0.7,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_tapped || _missed) return;
    position.y += fallSpeed * dt;
    if (position.y >= game.floorY) {
      _missed = true;
      position.y = game.floorY;
      game.onHeartMissed(this);
      _splat();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_tapped) return;
    _tapped = true;
    game.onHeartTapped(this);
    _pop();
  }

  // Scale up and fade out — satisfying "burst" when tapped.
  void _pop() {
    add(ScaleEffect.to(
      Vector2.all(1.5),
      EffectController(duration: 0.18, curve: Curves.easeOut),
    ));
    add(OpacityEffect.to(
      0,
      EffectController(duration: 0.18, startDelay: 0.06, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }

  // Squish flat against the grass, then fade out and remove.
  void _splat() {
    add(ScaleEffect.to(
      Vector2(1.5, 0.2),
      EffectController(duration: 0.14, curve: Curves.easeOut),
    ));
    add(OpacityEffect.to(
      0,
      EffectController(duration: 0.25, startDelay: 0.1, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }
}
