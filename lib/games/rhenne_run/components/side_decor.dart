import 'package:flame/components.dart';

import '../rhenne_run_game.dart';

/// Decorative lily pad drifting down the side of the screen (outside the
/// 3-lane play area) to add a sense of forward motion. Non-colliding.
class SideLilyPad extends SpriteComponent with HasGameReference<RhenneRunGame> {
  SideLilyPad({required Sprite sprite, required this.speedFactor})
      : super(sprite: sprite, anchor: Anchor.center);

  final double speedFactor;

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.scrollSpeed * speedFactor * dt;
    if (position.y > game.size.y + size.y) removeFromParent();
  }
}
