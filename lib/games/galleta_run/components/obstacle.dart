// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';

// import '../galleta_run_game.dart';
// import 'galleta.dart';

// class Obstacle extends SpriteComponent
//     with CollisionCallbacks, HasGameReference<GalletaRunGame> {
//   Obstacle({required Sprite sprite, required this.speed})
//       : super(
//           sprite: sprite,
//           size: Vector2(72, 60),
//           anchor: Anchor.bottomCenter,
//         );

//   final double speed;

//   @override
//   Future<void> onLoad() async {
//     add(RectangleHitbox.relative(Vector2(0.6, 0.6), parentSize: size));
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     position.x -= speed * dt;
//     if (position.x < -size.x) removeFromParent();
//   }

//   @override
//   void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollisionStart(intersectionPoints, other);
//     if (other is Galleta) {
//       game.onCrash();
//     }
//   }
// }
