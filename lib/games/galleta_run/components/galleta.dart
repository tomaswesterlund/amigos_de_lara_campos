import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Galleta extends SpriteComponent with CollisionCallbacks {
  Galleta(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2.all(110),
          anchor: Anchor.center,
        );

  bool airborne = false;
  double velocityY = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(Vector2(0.7, 0.7), parentSize: size));
  }
}
