// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
// import 'package:flutter/material.dart';

// class RedHeartComponent extends PositionComponent with CollisionCallbacks, HasGameRef {
//   RedHeartComponent({required this.lane})
//       : super(
//           size: Vector2.all(58), // Match the size definition from FallingItem
//           anchor: Anchor.center,
//         );

//   final int lane;
//   Sprite? _sprite;
//   double _pulseTimer = 0;

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();

//     // 1. Load the sprite completely internally without needing a specialized game reference
//     _sprite = await gameRef.loadSprite('corazon.png');

//     // 2. Add the relative collision boundary
//     add(CircleHitbox.relative(0.65, parentSize: size));

//     // 3. Add the idle pulsing effect
//     add(
//       ScaleEffect.by(
//         Vector2.all(1.10),
//         EffectController(
//           duration: 0.45,
//           alternate: true,
//           infinite: true,
//           curve: Curves.easeInOut,
//         ),
//       ),
//     );
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     _pulseTimer += dt;

//     // Optional: If you want to use the game's scroll speed dynamically without importing RhenneJumpsGame,
//     // you can access it dynamically through gameRef if needed, or manage its downward motion here.
//     // e.g., position.y += 180 * 0.90 * dt;
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     final w = size.x;
//     final h = size.y;

//     // Draw the asset-agnostic glow aura underneath
//     final glowPaint = Paint()..color = const Color(0xFFFF69B4).withValues(alpha: 0.12);
//     canvas.drawCircle(Offset(w / 2, h / 2), (w / 2) * 1.20, glowPaint);
//     canvas.drawCircle(Offset(w / 2, h / 2), (w / 2) * 0.95, glowPaint..color = const Color(0xFFFF69B4).withValues(alpha: 0.28));

//     // Render the sprite once it loaded successfully
//     _sprite?.render(canvas, size: size);
//   }
// }

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:lara_demo/core/constants.dart';

class RedHeartComponent extends PositionComponent {
  RedHeartComponent({required super.size, super.position});

  late final SpineComponent _spine;

  @override
  Future onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/heart/heart.atlas',
      skeletonFile: 'assets/sprites/heart/heart.json',
      anchor: Anchor.center,
      position: size / 2,
    );

    anchor = Anchor.center;

    _spine.scale = Vector2(size.x / _spine.size.x, size.y / _spine.size.y);

    // await add(
    //   RectangleHitbox.relative(
    //     Vector2(0.7, 1.0),
    //     parentSize: size,
    //     anchor: Anchor.center,
    //     position: size / 2 + Vector2(0, size.y * 0.1),
    //   ),
    // );

    await add(CircleHitbox(radius: size.y / 4, anchor: Anchor.center, position: size / 2 + Vector2(0, size.y * 0.1)));

    await add(_spine);

    startAnimation();
  }

  void startAnimation() {
    _spine.animationState.setAnimation(0, 'animation', true);
  }

  void move(Vector2 targetPosition, double duration) {
    add(
      MoveByEffect(
        targetPosition,
        EffectController(duration: duration),
        onComplete: () {
          removeFromParent();
        },
      ),
    );
  }
}
