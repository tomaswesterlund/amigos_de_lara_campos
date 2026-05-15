import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../rhenne_run_game.dart';
import 'runner_rhenne.dart';

enum LaneItemKind { heart, goldenHeart, rock }

double _sizeFor(LaneItemKind k) {
  switch (k) {
    case LaneItemKind.rock:
      return 78;
    case LaneItemKind.goldenHeart:
      return 76;
    case LaneItemKind.heart:
      return 60;
  }
}

class LaneItem extends SpriteComponent
    with CollisionCallbacks, HasGameReference<RhenneRunGame> {
  LaneItem({
    required Sprite sprite,
    required this.kind,
    required this.lane,
  }) : super(
          sprite: sprite,
          size: Vector2.all(_sizeFor(kind)),
          anchor: Anchor.center,
        );

  final LaneItemKind kind;
  final int lane;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.5, parentSize: size));
    if (kind == LaneItemKind.goldenHeart) {
      // Gentle pulse so the rare pickup catches the eye.
      add(
        ScaleEffect.by(
          Vector2.all(1.12),
          EffectController(
            duration: 0.45,
            alternate: true,
            infinite: true,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.scrollSpeed * dt;
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! RunnerRhenne) return;
    switch (kind) {
      case LaneItemKind.heart:
        game.onHeartPicked(this, points: 1);
        break;
      case LaneItemKind.goldenHeart:
        game.onHeartPicked(this, points: 10);
        break;
      case LaneItemKind.rock:
        game.onCrash();
        break;
    }
  }
}
