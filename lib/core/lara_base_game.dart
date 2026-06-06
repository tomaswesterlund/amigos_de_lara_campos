import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'lara_audio.dart';

class LaraLeaderboardEntry {
  final String name;
  final int score;
  final DateTime timestamp;

  LaraLeaderboardEntry({required this.name, required this.score, required this.timestamp});
}

abstract class LaraBaseGame extends FlameGame {
  final Gradient gradient;
  final String? bgm;

  LaraBaseGame({required this.gradient, this.bgm});

  int _score = 0;
  int get score => _score;

  String? _gameOverMessage;
  String? get gameOverMessage => _gameOverMessage;

  VoidCallback? _onRestart;
  VoidCallback? get onRestart => _onRestart;

  VoidCallback? _onHome;
  VoidCallback? get onHome => _onHome;

  /// Holds the leaderboard listings during runtime for this specific session.
  final List<LaraLeaderboardEntry> _leaderboardEntries = [];
  List<LaraLeaderboardEntry> get leaderboardEntries => List.unmodifiable(_leaderboardEntries);

  /// Tracks the precise run item instance that was just created on death
  /// so that the layout UI can accurately highlight your score line.
  LaraLeaderboardEntry? _justPlayedEntry;
  LaraLeaderboardEntry? get justPlayedEntry => _justPlayedEntry;

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

  /// Calculates the placement ranking for an entry item.
  int getRankOf(LaraLeaderboardEntry entry) {
    // Sort matching entries descending by score value
    final sorted = List<LaraLeaderboardEntry>.from(_leaderboardEntries)..sort((a, b) => b.score.compareTo(a.score));

    final index = sorted.indexWhere((e) => identical(e, entry));
    return index != -1 ? index + 1 : sorted.length + 1;
  }

  /// Seeds mock high scores if the leaderboard history list is empty.
  /// This generates believable target scores anchored around the player's performance.
  void _ensureInitialLeaderboardEntries() {
    if (_leaderboardEntries.isNotEmpty) return;

    final random = Random();

    // Generate 4 baseline scores. We anchor them around the player's score
    // so the competition feels realistic whether they scored 10 points or 500 points.
    final baseValue = _score < 20 ? 20 : _score;

    final mockData = [
      {'name': 'Rhenne', 'multiplier': 1.5},
      {'name': 'Lara', 'multiplier': 1.2},
      {'name': 'Diego', 'multiplier': 0.8},
      {'name': 'Santi', 'multiplier': 0.5},
    ];

    for (var mock in mockData) {
      final name = mock['name'] as String;
      final multiplier = mock['multiplier'] as double;

      // Add a little variance so scores aren't identical on every game-over screen
      final variance = (baseValue * 0.1 * (0.5 - random.nextDouble()));
      final mockScore = ((baseValue * multiplier) + variance).round().clamp(1, 9999);

      _leaderboardEntries.add(
        LaraLeaderboardEntry(name: name, score: mockScore, timestamp: DateTime.now().subtract(const Duration(days: 1))),
      );
    }
  }

  void showGameOver({
    required String message,
    required VoidCallback onRestart,
    required VoidCallback onHome,
    String defaultPlayerName = 'Lupita',
  }) {
    _gameOverMessage = message;
    _onRestart = onRestart;
    _onHome = onHome;

    _ensureInitialLeaderboardEntries();

    _justPlayedEntry = LaraLeaderboardEntry(name: defaultPlayerName, score: _score, timestamp: DateTime.now());
    _leaderboardEntries.add(_justPlayedEntry!);
    _leaderboardEntries.sort((a, b) => b.score.compareTo(a.score));
    
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
