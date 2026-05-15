import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../maze_dir.dart';

class MazeEnemy extends SpriteComponent {
  MazeEnemy({required Sprite sprite})
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
}
