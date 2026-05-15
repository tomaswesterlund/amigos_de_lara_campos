import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';

/// Single maze wall cell. Painted as a rounded magenta block to match the
/// Lara sticker aesthetic.
class WallTile extends PositionComponent {
  WallTile({required Vector2 cellPosition, required double cellSize}) {
    position = cellPosition;
    size = Vector2.all(cellSize);
  }

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = LaraColors.magenta;
    final hi = Paint()..color = LaraColors.pink;
    final rect = Rect.fromLTWH(2, 2, size.x - 4, size.y - 4);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 4, rect.top + 4, rect.width - 8, rect.height * 0.35),
        const Radius.circular(4),
      ),
      hi,
    );
  }
}
