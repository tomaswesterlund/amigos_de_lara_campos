import 'dart:ui';

import 'package:flame/components.dart';

import '../../../shared/lara_theme.dart';
import '../galleta_run_game.dart';

/// Full-width ground strip rendered at the bottom of the playfield.
/// A grass cap (rhenneGreen) sits on top of a dirt body (galletaBrown)
/// with a scrolling alternating stripe texture.
class Ground extends PositionComponent with HasGameReference<GalletaRunGame> {
  Ground({required double groundY, required double screenWidth, required double screenHeight})
      : super(
          position: Vector2(0, groundY),
          size: Vector2(screenWidth, screenHeight - groundY),
          priority: -10,
        );

  static const _capHeight = 14.0;
  double _scrollOffset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _scrollOffset += game.speed * dt;
  }

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
    // Scrolling alternating stripes for texture
    final stripe = Paint()..color = const Color(0x18000000);
    var x = -(_scrollOffset % 36);
    while (x < size.x) {
      canvas.drawRect(
        Rect.fromLTWH(x, _capHeight, 18, size.y - _capHeight),
        stripe,
      );
      x += 36;
    }
  }
}
