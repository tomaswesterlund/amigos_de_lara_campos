// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
// import 'package:flutter/material.dart';
// import '../../../shared/coin_draw.dart';
// import '../galleta_run_game.dart';

// /// Coin collectible that scrolls left with the level.
// /// Drawn programmatically to match the daily-bonus modal coin style.
// class CoinPickup extends PositionComponent
//     with CollisionCallbacks, HasGameReference<GalletaRunGame> {
//   CoinPickup({required this.speed})
//       : super(size: Vector2.all(46), anchor: Anchor.center);

//   final double speed;

//   @override
//   Future<void> onLoad() async {
//     add(CircleHitbox.relative(0.85, parentSize: size));
//     add(ScaleEffect.by(
//       Vector2.all(1.18),
//       EffectController(duration: 0.48, alternate: true, infinite: true, curve: Curves.easeInOut),
//     ));
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     position.x -= speed * dt;
//     if (position.x < -size.x) removeFromParent();
//   }

//   @override
//   void render(Canvas canvas) {
//     drawCoin(canvas, size.x, size.y);
//   }

//   @override
//   void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollisionStart(intersectionPoints, other);
//     // if (other is Galleta) game.onCoinCollected(this);
//   }
// }
