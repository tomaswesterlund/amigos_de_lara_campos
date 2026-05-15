import 'dart:ui';

import 'package:flame/components.dart';

import '../../../shared/lara_theme.dart';

/// Full-width ground strip rendered at the bottom of the playfield.
/// A grass cap (rhenneGreen) sits on top of a dirt body (galletaBrown)
/// with a subtle alternating stripe texture.
class Ground extends PositionComponent {
  Ground({required double groundY, required double screenWidth, required double screenHeight})
      : super(
          position: Vector2(0, groundY),
          size: Vector2(screenWidth, screenHeight - groundY),
          priority: -10,
        );

  static const _capHeight = 14.0;

  @override
  void render(Canvas canvas) {
    // Grass cap
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, _capHeight),
      Paint()..color = LaraColors.rhenneGreen,
    );
    // Darker leading edge at base of cap
    canvas.drawRect(
      Rect.fromLTWH(0, _capHeight - 3, size.x, 3),
      Paint()..color = LaraColors.rhenneGreenDark,
    );
    // Dirt body
    canvas.drawRect(
      Rect.fromLTWH(0, _capHeight, size.x, size.y - _capHeight),
      Paint()..color = LaraColors.galletaBrown,
    );
    // Subtle alternating stripes for texture
    final stripe = Paint()..color = const Color(0x18000000);
    var x = 0.0;
    while (x < size.x) {
      canvas.drawRect(
        Rect.fromLTWH(x, _capHeight, 18, size.y - _capHeight),
        stripe,
      );
      x += 36;
    }
  }
}
