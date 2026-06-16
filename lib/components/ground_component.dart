import 'dart:ui';

import 'package:flame/components.dart';
import 'package:lara_demo/core/lara_theme.dart';
import 'package:lara_demo/games/galleta_runs_game.dart';

class GroundComponent extends PositionComponent with HasGameReference<GalletaRunsGame> {
  GroundComponent({required double groundY, required double screenWidth, required double screenHeight})
    : super(position: Vector2(0, groundY), size: Vector2(screenWidth, screenHeight - groundY), priority: -10);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final newGroundY = size.y * 0.82;
    position.y = newGroundY;
    this.size = Vector2(size.x, size.y - newGroundY);
  }

  static const _capHeight = 14.0;
  // Soil depth layers (height, color) from top to bottom — lighter near surface,
  // darker deeper underground.
  static const _soilLayers = [
    (10.0, Color(0xFFBE824E)), // topsoil
    (12.0, Color(0xFFAA6E3A)), // mid-soil
    (14.0, Color(0xFF8F5A2A)), // deep-soil
  ];
  static const _bedrock = Color(0xFF6A3D18);

  double _scrollOffset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _scrollOffset += game.groundSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    // Grass cap
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, _capHeight), Paint()..color = LaraColors.rhenneGreen);
    // Sub-grass shadow edge
    canvas.drawRect(Rect.fromLTWH(0, _capHeight - 3, size.x, 3), Paint()..color = LaraColors.rhenneGreenDark);
    // Layered soil body — each band gets progressively darker
    var y = _capHeight;
    for (final (layerH, color) in _soilLayers) {
      final h = layerH.clamp(0.0, size.y - y);
      if (h <= 0) break;
      canvas.drawRect(Rect.fromLTWH(0, y, size.x, h), Paint()..color = color);
      y += h;
    }
    // Bedrock fills the rest
    if (y < size.y) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.x, size.y - y), Paint()..color = _bedrock);
    }
    // Scrolling vertical stripe texture on the full soil area
    final stripe = Paint()..color = const Color(0x18000000);
    var x = -(_scrollOffset % 36);
    while (x < size.x) {
      canvas.drawRect(Rect.fromLTWH(x, _capHeight, 18, size.y - _capHeight), stripe);
      x += 36;
    }
  }
}
