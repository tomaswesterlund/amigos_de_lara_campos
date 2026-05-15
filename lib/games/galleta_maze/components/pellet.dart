import 'package:flame/components.dart';

class Pellet extends SpriteComponent {
  Pellet({
    required Sprite sprite,
    required this.col,
    required this.row,
  }) : super(sprite: sprite, anchor: Anchor.center);

  final int col;
  final int row;
}
