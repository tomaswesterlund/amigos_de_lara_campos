import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../rhenne_run_game.dart';
import 'runner_rhenne.dart';

enum LaneItemKind { heart, goldenHeart, pinkHeart, rock, bird }

double _sizeFor(LaneItemKind k) {
  switch (k) {
    case LaneItemKind.rock:
      return 78;
    case LaneItemKind.goldenHeart:
      return 76;
    case LaneItemKind.pinkHeart:
      return 68;
    case LaneItemKind.heart:
      return 60;
    case LaneItemKind.bird:
      return 78;
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
    switch (kind) {
      case LaneItemKind.rock:
        add(CircleHitbox.relative(0.38, parentSize: size));
      case LaneItemKind.bird:
        add(RectangleHitbox.relative(Vector2(0.55, 0.65), parentSize: size));
      default:
        add(CircleHitbox.relative(0.5, parentSize: size));
    }
    if (kind == LaneItemKind.goldenHeart) {
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
    if (kind == LaneItemKind.bird) {
      add(
        ScaleEffect.by(
          Vector2.all(1.12),
          EffectController(
            duration: 0.30,
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
      case LaneItemKind.goldenHeart:
        game.onHeartPicked(this, points: 10);
      case LaneItemKind.pinkHeart:
        game.onHeartPicked(this, points: 3);
      case LaneItemKind.rock:
        game.onCrash();
      case LaneItemKind.bird:
        game.onCrash();
    }
  }
}
