import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_fly_game.dart';
import 'flying_rhenne.dart';

/// Bamboo-reed pipe scrolling left. The pair (top + bottom) leaves a gap
/// Rhenné must fly through. Only the [scorer] pipe of a pair increments
/// the score when its right edge passes the player.
class Pipe extends PositionComponent
    with CollisionCallbacks, HasGameReference<RhenneFlyGame> {
  Pipe({
    required this.top,
    required this.gapCenter,
    required this.gap,
    required double pipeWidth,
    this.scorer = false,
  }) : _pipeWidth = pipeWidth;

  final bool top;
  final double gapCenter;
  final double gap;
  final double _pipeWidth;
  final bool scorer;
  bool _scored = false;

  @override
  Future<void> onLoad() async {
    if (top) {
      size = Vector2(_pipeWidth, gapCenter - gap / 2);
      // position.y stays at 0 (set by parent on spawn)
    } else {
      final yTop = gapCenter + gap / 2;
      size = Vector2(_pipeWidth, game.size.y - yTop);
      position.y = yTop;
    }
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = LaraColors.rhenneGreen;
    final dark = Paint()..color = LaraColors.rhenneGreenDark;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, body);
    // Cap at the gap-facing end.
    final capH = 18.0;
    final capRect = top
        ? Rect.fromLTWH(-4, size.y - capH, size.x + 8, capH)
        : Rect.fromLTWH(-4, 0, size.x + 8, capH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(8)),
      dark,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= game.scrollSpeed * dt;
    if (position.x + size.x < 0) {
      removeFromParent();
      return;
    }
    if (scorer && !_scored && position.x + size.x < game.playerX) {
      _scored = true;
      game.onPipePassed();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is FlyingRhenne) game.onCrash();
  }
}
