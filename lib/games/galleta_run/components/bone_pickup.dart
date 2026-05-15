import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galleta_run_game.dart';
import 'galleta.dart';

/// Treat-bone pickup worth 2 points. Uses the existing treat_bone.png sprite.
class BonePickup extends SpriteComponent
    with CollisionCallbacks, HasGameReference<GalletaRunGame> {
  BonePickup({required Sprite sprite, required this.speed})
      : super(
          sprite: sprite,
          size: Vector2(62, 36),
          anchor: Anchor.center,
        );

  final double speed;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(Vector2(0.7, 0.65), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Galleta) game.onBoneCollected(this);
  }
}
