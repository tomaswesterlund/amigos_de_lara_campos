import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';

import '../alphabet_game.dart';

/// Rhenné as a tappable singer. Gentle idle bob; a bigger "croak" bounce
/// fires whenever the game speaks a letter.
class SpeakingRhenne extends SpriteComponent
    with TapCallbacks, HasGameReference<AlphabetGame> {
  SpeakingRhenne(Sprite sprite) : super(sprite: sprite, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Idle bob so Rhenné feels alive between letters.
    add(
      MoveByEffect(
        Vector2(0, -6),
        EffectController(
          duration: 0.9,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  /// Big bouncy reaction when a letter is spoken.
  void croak() {
    add(
      ScaleEffect.by(
        Vector2.all(1.18),
        EffectController(
          duration: 0.12,
          alternate: true,
          reverseDuration: 0.18,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.onRhenneTapped();
  }
}
