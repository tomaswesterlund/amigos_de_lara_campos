import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/falling_heart.dart';
import 'tap_heart_leaderboard.dart';

/// Hearts fall from the sky; tap them before they hit the grass. Miss 3 → game over.
class TapHeartGame extends LaraGame {
  TapHeartGame() : super(gradient: LaraGradients.sunny, bgm: LaraBgm.corazon);

  static const _maxLives = 3;
  static const _floorHeight = 72.0;

  late final Sprite _heartRed;
  late final Sprite _heartPink;
  late final Sprite _heartGold;
  late final Sprite _rhenneSprite;
  final _rng = Random();
  double _spawnTimer = 0;
  double _cloudTimer = 0;
  double _spawnInterval = 1.5;
  int _lives = _maxLives;
  int _hits = 0;
  int _score = 0;
  bool _running = true;

  TapHeartEntry? lastEntry;

  int get lives => _lives;

  /// Y coordinate of the grass surface — hearts splat here instead of leaving the screen.
  double get floorY => size.y - _floorHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _heartRed = await loadSprite('corazon.png');
    _heartPink = await loadSprite('corazon_pink.png');
    _heartGold = await loadSprite('corazon_yellow.png');
    _rhenneSprite = await loadSprite('rhenne.png');
    add(_GrassFloor());
    add(_LivesDisplay(rhenneSprite: _rhenneSprite));
    for (var i = 0; i < 3; i++) {
      _spawnCloud(initial: true);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    _spawnTimer += dt;
    _cloudTimer += dt;
    // Kid-friendly pace: gentle acceleration from 1.5s to 0.8s between hearts.
    _spawnInterval = (1.5 - _hits * 0.008).clamp(0.8, 1.5);
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnHeart();
    }
    if (_cloudTimer >= 4.0) {
      _cloudTimer = 0;
      _spawnCloud();
    }
  }

  void _spawnHeart() {
    final roll = _rng.nextDouble();
    final Sprite sprite;
    final int points;
    // Consistent with Rhenné Corre: yellow = 10 pts (rare), pink = 3 pts, red = 1 pt.
    if (roll < 0.10) {
      sprite = _heartGold;
      points = 10;
    } else if (roll < 0.35) {
      sprite = _heartPink;
      points = 3;
    } else {
      sprite = _heartRed;
      points = 1;
    }
    // Slow start, gentle ramp — comfortable for ages 4–9.
    final fallSpeed = 100.0 + _rng.nextDouble() * 50.0 + _hits * 0.8;
    final heart = FallingHeart(sprite: sprite, fallSpeed: fallSpeed, points: points)
      ..position = Vector2(40 + _rng.nextDouble() * (size.x - 80), -40);
    add(heart);
  }

  void _spawnCloud({bool initial = false}) {
    final w = 70.0 + _rng.nextDouble() * 90.0;
    final h = w * 0.55;
    final speed = 14.0 + _rng.nextDouble() * 22.0;
    final goingRight = _rng.nextBool();
    add(_Cloud(driftSpeed: goingRight ? speed : -speed)
      ..size = Vector2(w, h)
      ..priority = -800
      ..position = Vector2(
        initial ? _rng.nextDouble() * size.x : (goingRight ? -w : size.x + w),
        18 + _rng.nextDouble() * size.y * 0.28,
      ));
  }

  // Heart removes itself via _pop(); game just updates state and shows popup.
  void onHeartTapped(FallingHeart heart) {
    if (!_running) return;
    LaraAudio.playSfx(
      heart.points >= 10 ? LaraSfx.hitPerfect : heart.points >= 3 ? LaraSfx.coin : LaraSfx.hitGood,
    );
    _hits += 1;
    _score += heart.points;
    setScore(_score);
    add(_ScorePopup(heart.position.clone(), heart.points));
  }

  // Heart calls this the instant it touches the grass, then animates itself away.
  void onHeartMissed(FallingHeart heart) {
    if (!_running) return;
    LaraAudio.playSfx(LaraSfx.miss);
    _flashMiss();
    _lives -= 1;
    if (_lives <= 0) {
      _running = false;
      lastEntry = TapHeartLeaderboard.submit(_score);
      showGameOver('¡Se cayeron los corazones!\nPuntos: $_score', () {});
    }
  }

  void _flashMiss() {
    final flash = RectangleComponent(
      size: size.clone(),
      paint: Paint()..color = const Color(0x55E33282),
      priority: 200,
    );
    add(flash);
    flash.add(OpacityEffect.to(
      0,
      EffectController(duration: 0.45, curve: Curves.easeOut),
      onComplete: flash.removeFromParent,
    ));
  }
}

// ─── Rhenné lives display ──────────────────────────────────────────────────────

class _LivesDisplay extends PositionComponent
    with HasGameReference<TapHeartGame> {
  _LivesDisplay({required this.rhenneSprite});

  final Sprite rhenneSprite;
  static const _iconSize = 38.0;
  static const _gap = 6.0;

  @override
  void onMount() {
    super.onMount();
    priority = 150;
    position = Vector2(12, 62);
  }

  @override
  void render(Canvas canvas) {
    final lives = game.lives;
    for (var i = 0; i < TapHeartGame._maxLives; i++) {
      final x = i * (_iconSize + _gap);
      final isActive = i < lives;
      rhenneSprite.render(
        canvas,
        position: Vector2(x, 0),
        size: Vector2.all(_iconSize),
        overridePaint: isActive ? null : (Paint()..color = const Color(0x55FFFFFF)),
      );
    }
  }
}

// ─── Grass floor ──────────────────────────────────────────────────────────────

class _GrassFloor extends PositionComponent
    with HasGameReference<TapHeartGame> {
  @override
  void onMount() {
    super.onMount();
    priority = -100;
    _resize(game.size);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _resize(gameSize);
  }

  void _resize(Vector2 gameSize) {
    size = Vector2(gameSize.x, TapHeartGame._floorHeight);
    position = Vector2(0, gameSize.y - TapHeartGame._floorHeight);
  }

  @override
  void render(Canvas canvas) {
    // Soil layers.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF2E7D32),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 28, size.x, size.y - 28),
      Paint()..color = const Color(0xFF1B5E20),
    );

    // Grass blades — triangular, varying height and colour.
    const stride = 11.0;
    final count = (size.x / stride).ceil() + 1;
    const heights = [18.0, 13.0, 20.0, 11.0, 16.0, 22.0, 14.0];
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF388E3C),
      Color(0xFF66BB6A),
      Color(0xFF43A047),
      Color(0xFF2E7D32),
      Color(0xFF81C784),
      Color(0xFF388E3C),
    ];

    for (var i = 0; i < count; i++) {
      final x = i * stride;
      final h = heights[i % heights.length];
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stride, 0)
        ..lineTo(x + stride / 2, -h)
        ..close();
      canvas.drawPath(path, Paint()..color = colors[i % colors.length]);
    }
  }
}

// ─── Drifting cloud ───────────────────────────────────────────────────────────

class _Cloud extends PositionComponent with HasGameReference<TapHeartGame> {
  _Cloud({required this.driftSpeed});

  final double driftSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    position.x += driftSpeed * dt;
    final offLeft = driftSpeed < 0 && position.x < -size.x;
    final offRight = driftSpeed > 0 && position.x > game.size.x + size.x;
    if (offLeft || offRight) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.78);
    final cx = size.x / 2;
    final cy = size.y * 0.58;
    final r = size.y * 0.44;
    // Three overlapping circles + base rectangle to form a fluffy cloud.
    canvas.drawCircle(Offset(cx, cy), r, paint);
    canvas.drawCircle(Offset(cx - size.x * 0.26, cy + r * 0.12), r * 0.76, paint);
    canvas.drawCircle(Offset(cx + size.x * 0.26, cy + r * 0.12), r * 0.76, paint);
    canvas.drawRect(
      Rect.fromLTWH(cx - size.x * 0.34, cy, size.x * 0.68, size.y * 0.36),
      paint,
    );
  }
}

// ─── Score popup ──────────────────────────────────────────────────────────────

class _ScorePopup extends TextComponent {
  _ScorePopup(Vector2 pos, int points)
      : super(
          text: '+$points',
          anchor: Anchor.center,
          position: pos,
          priority: 100,
          textRenderer: TextPaint(
            style: TextStyle(
              color: Colors.white,
              fontSize: points >= 10 ? 42 : points >= 3 ? 36 : 30,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: points >= 10
                      ? const Color(0xFFCB8A1A)
                      : points >= 3
                          ? LaraColors.pink
                          : LaraColors.corazonRed,
                  blurRadius: 8,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
        );

  @override
  void onMount() {
    super.onMount();
    add(MoveEffect.by(
      Vector2(0, -65),
      EffectController(duration: 0.7, curve: Curves.easeOut),
    ));
    add(ScaleEffect.to(
      Vector2.all(0.01),
      EffectController(duration: 0.3, startDelay: 0.4, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }
}
