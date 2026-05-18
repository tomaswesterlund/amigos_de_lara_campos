import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'lara_audio.dart';

/// Shared base class for every mini-game in the demo.
///
/// Wires:
/// - a brand-consistent gradient backdrop sized to the viewport
/// - a top-of-screen score HUD overlay key (`hud`)
/// - a centred game-over / win overlay key (`gameOver`)
/// - a centred pause overlay key (`pause`)
/// - optional looping background music via [LaraAudio]
///
/// Individual games own their score/state and just call [setScore],
/// [showGameOver], etc. Pass a [bgm] asset path (relative to assets/audio/)
/// to have the base class start/stop music automatically.
abstract class LaraGame extends FlameGame {
  LaraGame({required this.gradient, this.bgm});

  final Gradient gradient;

  /// Asset path relative to `assets/audio/`, e.g. `'bgm/rhenne_theme.m4a'`.
  /// Null means no background music for this game.
  final String? bgm;

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
    LaraAudio.stopBgm();
  }

  void clearGameOver() {
    overlays.remove('gameOver');
    _gameOverMessage = null;
    _onRestart = null;
    resumeEngine();
    if (bgm != null) LaraAudio.startBgm(bgm!);
  }

  @override
  Future<void> onLoad() async {
    add(_GradientBackground(gradient: gradient));
    overlays.add('hud');
    if (bgm != null) await LaraAudio.startBgm(bgm!);
  }

  @override
  void onDetach() {
    super.onDetach();
    LaraAudio.stopBgm();
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
