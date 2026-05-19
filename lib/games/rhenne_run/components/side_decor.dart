import 'package:flame/components.dart';

import '../rhenne_run_game.dart';

/// Decorative lily pad drifting down the screen to add a sense of forward motion.
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

class SideReed extends SpriteComponent with HasGameReference<RhenneRunGame> {
  SideReed({required Sprite sprite, required this.speedFactor})
      : super(sprite: sprite, anchor: Anchor.center);

  final double speedFactor;

  @override
  void onMount() {
    super.onMount();
    opacity = 0.55;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.scrollSpeed * speedFactor * dt;
    if (position.y > game.size.y + size.y) removeFromParent();
  }
}

class SideWaterFlower extends SpriteComponent with HasGameReference<RhenneRunGame> {
  SideWaterFlower({required Sprite sprite, required this.speedFactor})
      : super(sprite: sprite, anchor: Anchor.center);

  final double speedFactor;

  @override
  void onMount() {
    super.onMount();
    opacity = 0.48;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.scrollSpeed * speedFactor * dt;
    if (position.y > game.size.y + size.y) removeFromParent();
  }
}
