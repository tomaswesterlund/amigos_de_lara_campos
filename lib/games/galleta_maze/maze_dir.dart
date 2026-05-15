import 'package:flame/components.dart';

enum MazeDir { none, up, down, left, right }

Vector2 mazeDirVector(MazeDir d) {
  switch (d) {
    case MazeDir.up:
      return Vector2(0, -1);
    case MazeDir.down:
      return Vector2(0, 1);
    case MazeDir.left:
      return Vector2(-1, 0);
    case MazeDir.right:
      return Vector2(1, 0);
    case MazeDir.none:
      return Vector2.zero();
  }
}

bool isOpposite(MazeDir a, MazeDir b) {
  return (a == MazeDir.up && b == MazeDir.down) ||
      (a == MazeDir.down && b == MazeDir.up) ||
      (a == MazeDir.left && b == MazeDir.right) ||
      (a == MazeDir.right && b == MazeDir.left);
}
