import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'lara_audio.dart';

class LaraLeaderboardEntry {
  final String name;
  final int points;
  final DateTime timestamp;

  LaraLeaderboardEntry({required this.name, required this.points, required this.timestamp});
}

abstract class LaraBaseGame extends FlameGame {
  final Gradient gradient;
  final String? bgm;

  LaraBaseGame({required this.gradient, this.bgm});

  int _points = 0;
  int get points => _points;

  int _coins = 0;
  int get coins => _coins;

  String? _gameOverMessage;
  String? get gameOverMessage => _gameOverMessage;

  VoidCallback? _onRestart;
  VoidCallback? get onRestart => _onRestart;

  VoidCallback? _onHome;
  VoidCallback? get onHome => _onHome;

  final List<LaraLeaderboardEntry> _leaderboardEntries = [];
  List<LaraLeaderboardEntry> get leaderboardEntries => List.unmodifiable(_leaderboardEntries);

  LaraLeaderboardEntry? _justPlayedEntry;
  LaraLeaderboardEntry? get justPlayedEntry => _justPlayedEntry;

  void addCoins(int value) {
    _coins += value;
  }

  void addPoints(int value) {
    _points += value;
    refreshHud();
  }

  void setScore(int value) {
    if (value == _points) return;
    _points = value;
    refreshHud();
  }

  void refreshHud() {
    if (overlays.isActive('hud')) {
      overlays.remove('hud');
      overlays.add('hud');
    }
  }

  int getRankOf(LaraLeaderboardEntry entry) {
    final sorted = List<LaraLeaderboardEntry>.from(_leaderboardEntries)..sort((a, b) => b.points.compareTo(a.points));

    final index = sorted.indexWhere((e) => identical(e, entry));
    return index != -1 ? index + 1 : sorted.length + 1;
  }

  void _ensureInitialLeaderboardEntries() {
    if (_leaderboardEntries.isNotEmpty) return;

    final random = Random();
    final baseValue = _points < 20 ? 20 : _points;

    final mockData = [
      {'name': 'Rhenne', 'multiplier': 1.5},
      {'name': 'Lara', 'multiplier': 1.2},
      {'name': 'Diego', 'multiplier': 0.8},
      {'name': 'Santi', 'multiplier': 0.5},
    ];

    for (var mock in mockData) {
      final name = mock['name'] as String;
      final multiplier = mock['multiplier'] as double;

      final variance = (baseValue * 0.1 * (0.5 - random.nextDouble()));
      final mockScore = ((baseValue * multiplier) + variance).round().clamp(1, 9999);

      _leaderboardEntries.add(
        LaraLeaderboardEntry(
          name: name,
          points: mockScore,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
    }
  }

  void showGameOver({
    required String message,
    required VoidCallback onRestart,
    required VoidCallback onHome,
    String defaultPlayerName = 'Amigo de Lara',
  }) {
    _gameOverMessage = message;
    _onRestart = onRestart;
    _onHome = onHome;

    _ensureInitialLeaderboardEntries();

    _justPlayedEntry = LaraLeaderboardEntry(name: defaultPlayerName, points: _points, timestamp: DateTime.now());
    _leaderboardEntries.add(_justPlayedEntry!);
    _leaderboardEntries.sort((a, b) => b.points.compareTo(a.points));

    pauseEngine();
    LaraAudio.stopBgm();
    overlays.add('gameOver');
  }

  void clearGameOver() {
    overlays.remove('gameOver');
    _gameOverMessage = null;
    _onRestart = null;
    _onHome = null;
    _justPlayedEntry = null;

    resumeEngine();
    if (bgm != null) LaraAudio.startBgm(bgm!);
  }

  @override
  Future<void> onLoad() async {
    add(_GradientBackground(gradient: gradient));
    overlays.add('hud');
    if (bgm != null) LaraAudio.startBgm(bgm!);
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
