import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../rhenne_run_game.dart';

class TutorialHint extends PositionComponent with HasGameReference<RhenneRunGame> {
  TutorialHint() : super(anchor: Anchor.center);

  static bool shown = false;

  double _opacity = 0.0;
  double _elapsed = 0;
  bool _fadingOut = false;

  @override
  void onMount() {
    super.onMount();
    size = Vector2(game.size.x * 0.72, 72);
    position = Vector2(game.size.x / 2, game.size.y * 0.34);
    priority = 100;
    TutorialHint.shown = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (!_fadingOut) {
      _opacity = (_opacity + dt * 5).clamp(0.0, 1.0);
      if (_elapsed >= 2.2) _fadingOut = true;
    } else {
      _opacity -= dt * 2.5;
      if (_opacity <= 0) {
        removeFromParent();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0) return;
    final bgPaint = Paint()
      ..color = Color.fromARGB((_opacity * 160).round(), 0, 0, 0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(18),
      ),
      bgPaint,
    );
    final alpha = (_opacity * 255).round();
    TextPaint(
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color.fromARGB(alpha, 255, 255, 255),
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            color: Color.fromARGB((_opacity * 128).round(), 0, 0, 0),
          )
        ],
      ),
    ).render(canvas, '← Toca o desliza →', Vector2(size.x / 2, 10),
        anchor: Anchor.topCenter);
    TextPaint(
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB((_opacity * 216).round(), 255, 255, 255),
      ),
    ).render(canvas, 'para cambiar de carril', Vector2(size.x / 2, 40),
        anchor: Anchor.topCenter);
  }
}
