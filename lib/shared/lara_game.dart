import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Shared base class for every mini-game in the demo.
///
/// Wires:
/// - a brand-consistent gradient backdrop sized to the viewport
/// - a top-of-screen score HUD overlay key (`hud`)
/// - a centred game-over / win overlay key (`gameOver`)
/// - a centred pause overlay key (`pause`)
///
/// Individual games own their score/state and just call [setScore],
/// [showGameOver], etc.
abstract class LaraGame extends FlameGame {
  LaraGame({required this.gradient});

  final Gradient gradient;

  int _score = 0;
  int get score => _score;
  String? _gameOverMessage;
  String? get gameOverMessage => _gameOverMessage;
  VoidCallback? _onRestart;
  VoidCallback? get onRestart => _onRestart;

  void setScore(int value) {
    if (value == _score) return;
    _score = value;
    refreshHud();
  }

  void refreshHud() {
    if (overlays.isActive('hud')) {
      overlays.remove('hud');
      overlays.add('hud');
    }
  }

  void showGameOver(String message, VoidCallback onRestart) {
    _gameOverMessage = message;
    _onRestart = onRestart;
    pauseEngine();
    overlays.add('gameOver');
  }

  void clearGameOver() {
    overlays.remove('gameOver');
    _gameOverMessage = null;
    _onRestart = null;
    resumeEngine();
  }

  @override
  Future<void> onLoad() async {
    add(_GradientBackground(gradient: gradient));
    overlays.add('hud');
  }
}

class _GradientBackground extends PositionComponent with HasGameReference<FlameGame> {
  _GradientBackground({required this.gradient});

  final Gradient gradient;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  void onMount() {
    super.onMount();
    priority = -1000;
    size = game.size;
    position = Vector2.zero();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    size = newSize;
  }
}
