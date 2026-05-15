import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galleta_catch_game.dart';

enum TreatKind { heart, bone, rock }

class FallingTreat extends SpriteComponent
    with CollisionCallbacks, HasGameReference<GalletaCatchGame> {
  FallingTreat({
    required Sprite sprite,
    required this.kind,
    required this.fallSpeed,
  }) : super(
          sprite: sprite,
          size: Vector2.all(kind == TreatKind.rock ? 64 : 56),
          anchor: Anchor.center,
        );

  final TreatKind kind;
  final double fallSpeed;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.55, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;
    if (position.y > game.size.y + size.y) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // The Galleta catcher is the only sibling with a hitbox.
    game.onTreatCaught(this);
  }
}
