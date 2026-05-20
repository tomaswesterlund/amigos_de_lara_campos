import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../rhenne_nada_game.dart';

class SwimmingFish extends SpriteAnimationComponent
    with HasGameReference<RhenneNadaGame>, CollisionCallbacks {
  SwimmingFish(
    SpriteAnimation animation, {
    required this.amplitude,
    required this.frequency,
  }) : super(animation: animation, size: Vector2.all(78), anchor: Anchor.center);

  final double amplitude;
  final double frequency;
  double _time = 0;
  double _baseY = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(Vector2(0.6, 0.55), parentSize: size));
    _baseY = position.y;
    // Fish face left toward the player
    scale.x = -1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    position.x -= game.scrollSpeed * dt;
    position.y = _baseY + math.sin(_time * frequency * math.pi * 2) * amplitude;
    if (position.x < -size.x) removeFromParent();
  }
}
