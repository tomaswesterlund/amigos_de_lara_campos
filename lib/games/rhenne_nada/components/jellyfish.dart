import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../rhenne_nada_game.dart';

class Jellyfish extends SpriteAnimationComponent
    with HasGameReference<RhenneNadaGame>, CollisionCallbacks {
  Jellyfish(SpriteAnimation animation)
      : super(animation: animation, size: Vector2.all(78), anchor: Anchor.center);

  double _time = 0;
  double _baseY = 0;
  // Jellyfish drift slowly — 60 % of the main scroll speed
  static const _driftFraction = 0.6;
  static const _driftAmplitude = 28.0;
  static const _driftFrequency = 0.33; // one full cycle every ~3 s

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.5, parentSize: size));
    _baseY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    position.x -= game.scrollSpeed * _driftFraction * dt;
    position.y = _baseY + math.sin(_time * _driftFrequency * math.pi * 2) * _driftAmplitude;
    if (position.x < -size.x) removeFromParent();
  }
}
