import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../maze_dir.dart';

class MazeGalleta extends SpriteComponent {
  MazeGalleta({required Sprite sprite})
      : super(sprite: sprite, anchor: Anchor.center);

  int gridCol = 0;
  int gridRow = 0;
  MazeDir currentDir = MazeDir.none;

  Future<void> moveTo(Vector2 target, {required double duration}) {
    final completer = Completer<void>();
    add(
      MoveByEffect(
        target - position,
        EffectController(duration: duration, curve: Curves.linear),
        onComplete: completer.complete,
      ),
    );
    return completer.future;
  }

  /// Tiny squish on the moving axis when stepping — gives Galleta some
  /// bounce instead of sliding stiff between cells.
  void waddle() {
    add(
      ScaleEffect.by(
        Vector2(1.06, 0.94),
        EffectController(
          duration: 0.09,
          alternate: true,
          reverseDuration: 0.09,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}
