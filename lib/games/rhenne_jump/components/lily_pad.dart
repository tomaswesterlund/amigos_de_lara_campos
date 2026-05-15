import 'package:flame/components.dart';

class LilyPad extends SpriteComponent with HasGameReference {
  LilyPad({required Sprite sprite, required this.speed})
      : super(
          sprite: sprite,
          size: Vector2(120, 60),
          anchor: Anchor.center,
        );

  final double speed;

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    if (position.x < -size.x) {
      removeFromParent();
    }
  }
}
