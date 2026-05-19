import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/bird_obstacle.dart';
import 'components/bone_pickup.dart';
import 'components/cloud.dart';
import 'components/coin_pickup.dart';
import 'components/coin_pop.dart';
import 'components/corazon_pickup.dart';
import 'components/galleta.dart';
import 'components/ground.dart';
import 'components/hill.dart';
import 'components/obstacle.dart';
import 'components/score_popup.dart';
import 'components/sky_layer.dart';
import 'components/tutorial_hint.dart';
import 'leaderboard.dart';

/// Galleta auto-runs to the right; tap to jump rocks and collect hearts.
///
/// Spawning uses a chunk system (Super Mario-style block slots) so that:
///   - Birds are never within 2 chunks of a rock (≥640 px gap).
///   - Hearts/bones paired with a rock float directly above or ≤1 chunk
///     before/after it, giving the player a skill-reward trade-off.
///   - Two rocks are always at least 1 chunk apart.
class GalletaRunGame extends LaraGame with TapCallbacks, HasCollisionDetection {
  GalletaRunGame() : super(gradient: LaraGradients.sunny, bgm: LaraBgm.galleta);

  static const _baseSpeed = 220.0;
  static const _gravity = 1800.0;
  static const _jumpVelocity = -780.0;

  // Spatial chunk spacing — keeps distances consistent regardless of speed.
  static const _chunkPx = 320.0;

  Galleta? _galleta;
  Sprite? _rockSprite;
  Sprite? _heartSprite;
  Sprite? _boneSprite;
  final _rng = Random();

  double _speed = _baseSpeed;

  // Chunk sequencer
  double _chunkTimer = 1.0;
  int _chunksSinceRock = 10; // start high → full variety from the first chunk
  int _chunksSinceBird = 10;

  bool _running = true;
  int _score = 0;
  int _coinsCollected = 0;

  /// Set on crash; read by the gameOverBuilder in home_screen.dart.
  GalletaRunEntry? lastEntry;

  int get coinsCollected => _coinsCollected;

  double get groundY => size.y * 0.82;
  double get speed => _speed;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Randomise first chunk so consecutive sessions feel distinct.
    _chunkTimer = 0.4 + _rng.nextDouble() * 1.2;

    _rockSprite = await loadSprite('obstacle_rock.png');
    _heartSprite = await loadSprite('corazon.png');
    _boneSprite = await loadSprite('treat_bone.png');

    _addBackground();

    final g = Galleta(await loadSprite('galleta.png'));
    _galleta = g;
    add(g);
    _placeGalleta();
    if (!TutorialHint.shown) add(TutorialHint());
  }

  void _addBackground() {
    // Sky — sun, sparkle stars, and faint background birds (priority -70).
    add(SkyLayer(screenWidth: size.x, screenHeight: size.y, rng: _rng));

    final hillDefs = [
      (x: 0.0, w: 290.0, h: 180.0, color: LaraColors.mint.withValues(alpha: 0.42), spd: 18.0),
      (x: 230.0, w: 230.0, h: 145.0, color: LaraColors.rhenneGreen.withValues(alpha: 0.32), spd: 25.0),
      (x: 460.0, w: 270.0, h: 165.0, color: LaraColors.mint.withValues(alpha: 0.38), spd: 21.0),
    ];
    for (final d in hillDefs) {
      add(Hill(
        startPosition: Vector2(d.x, groundY - d.h + 14),
        hillWidth: d.w,
        hillHeight: d.h,
        scrollSpeed: d.spd,
        color: d.color,
        rng: _rng,
      ));
    }

    // Mid clouds — main layer (priority -30 inside Cloud)
    final cloudDefs = [
      (x: 55.0, y: 48.0, w: 115.0, spd: 30.0),
      (x: 285.0, y: 82.0, w: 92.0, spd: 22.0),
      (x: 490.0, y: 38.0, w: 132.0, spd: 27.0),
    ];
    for (final d in cloudDefs) {
      add(Cloud(
        startPosition: Vector2(d.x, d.y),
        cloudWidth: d.w,
        scrollSpeed: d.spd,
        rng: _rng,
      ));
    }

    // Far-background clouds — smaller, slower, higher y range (priority -45)
    final farCloudDefs = [
      (x: 30.0, y: 130.0, w: 68.0, spd: 10.0),
      (x: 240.0, y: 110.0, w: 54.0, spd: 12.0),
      (x: 430.0, y: 145.0, w: 74.0, spd: 9.0),
      (x: 610.0, y: 118.0, w: 60.0, spd: 11.0),
    ];
    for (final d in farCloudDefs) {
      add(Cloud(
        startPosition: Vector2(d.x, d.y),
        cloudWidth: d.w,
        scrollSpeed: d.spd,
        rng: _rng,
        renderPriority: -45,
      ));
    }

    add(Ground(
      groundY: groundY,
      screenWidth: size.x,
      screenHeight: size.y,
    ));
  }

  // Sink Galleta 10 px into the grass cap so her feet visually touch the ground.
  static const _groundSink = 10.0;

  void _placeGalleta() {
    final g = _galleta;
    if (g == null) return;
    g.position = Vector2(size.x * 0.22, groundY - g.size.y / 2 + _groundSink);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final g = _galleta;
    if (g != null && !g.airborne) _placeGalleta();
  }

  // ─── Update ──────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    // Cap dt so a frame spike (e.g. audio player init, app resume) never
    // causes the jump physics to overshoot and invisibly cancel mid-air.
    final safeDt = dt.clamp(0.0, 0.05);
    super.update(safeDt);
    if (!_running) return;
    final g = _galleta;
    if (g == null) return;

    _speed = _baseSpeed + _score * 3;

    // Gravity / landing
    if (g.airborne) {
      g.velocityY += _gravity * safeDt;
      g.position.y += g.velocityY * safeDt;
      final feetY = g.position.y + g.size.y / 2;
      if (feetY >= groundY) {
        g.position.y = groundY - g.size.y / 2 + _groundSink;
        g.velocityY = 0;
        g.airborne = false;
      }
    }

    // Chunk-based spawning
    _chunkTimer -= safeDt;
    if (_chunkTimer <= 0) {
      _chunkTimer = _chunkInterval();
      _spawnChunk();
    }
  }

  // Constant pixel gap between chunks keeps spatial rhythm speed-independent.
  double _chunkInterval() {
    return (_chunkPx / _speed).clamp(0.50, 2.2) +
        _rng.nextDouble() * (70.0 / _speed).clamp(0.08, 0.45);
  }

  // ─── Chunk spawner ────────────────────────────────────────────────────────────

  void _spawnChunk() {
    _chunksSinceRock++;
    _chunksSinceBird++;

    // Enforce minimum spacing rules
    // Bird needs ≥2 empty chunks after a rock (and vice-versa).
    // Rock needs ≥1 empty chunk after the previous rock.
    final canRock = _chunksSinceBird >= 3 && _chunksSinceRock >= 2;
    final canBird = _chunksSinceRock >= 3 && _chunksSinceBird >= 3;

    // Weighted option list
    final options = <(String, double)>[
      ('gap', 1.0),
      ('pickup', 1.8),
      ('coin', 1.4),
    ];
    if (canRock) {
      options.add(('rock', 1.6));
      options.add(('rock_pickup', 2.2)); // rewarding: risk + collectible
    }
    if (canBird) {
      options.add(('bird', 1.8));
    }

    final total = options.fold(0.0, (s, o) => s + o.$2);
    double roll = _rng.nextDouble() * total;
    String choice = 'gap';
    for (final o in options) {
      roll -= o.$2;
      if (roll <= 0) {
        choice = o.$1;
        break;
      }
    }

    final rx = size.x + 70.0;

    switch (choice) {
      case 'rock':
        _addRock(rx);

      case 'rock_pickup':
        _addRock(rx);
        // Pickup floats above, or up to one chunk before/after the rock.
        final hOff = _rng.nextDouble() * 120 - 70; // −70…+50 px
        final yOff = groundY - 100 - _rng.nextDouble() * 50;
        _addPickup(Vector2(rx + hOff, yOff));

      case 'bird':
        add(BirdObstacle(speed: _speed * 0.85, centerY: groundY - 175)
          ..position.x = rx);
        _chunksSinceBird = 0;

      case 'pickup':
        _addPickup(Vector2(rx, groundY - 80 - _rng.nextDouble() * 100));

      case 'coin':
        final yOff = groundY - 60 - _rng.nextDouble() * 80;
        add(CoinPickup(speed: _speed)..position = Vector2(rx, yOff));

      // 'gap': nothing spawned
    }
  }

  void _addRock(double x) {
    add(Obstacle(sprite: _rockSprite!, speed: _speed)
      ..position = Vector2(x, groundY + 14));
    _chunksSinceRock = 0;
  }

  void _addPickup(Vector2 pos) {
    if (_rng.nextDouble() < 0.75) {
      final roll = _rng.nextDouble();
      final type = roll < 0.10
          ? HeartType.golden
          : roll < 0.32
              ? HeartType.big
              : HeartType.normal;
      add(CorazonPickup(sprite: _heartSprite!, speed: _speed, type: type)
        ..position = pos);
    } else {
      add(BonePickup(sprite: _boneSprite!, speed: _speed)..position = pos);
    }
  }

  // ─── Input ───────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (!_running) return;
    final g = _galleta;
    if (g == null) return;
    if (!g.airborne) {
      LaraAudio.playSfx(LaraSfx.hitGood);
      g.velocityY = _jumpVelocity;
      g.airborne = true;
    }
  }

  // ─── Callbacks from components ────────────────────────────────────────────────

  void onHeartCollected(CorazonPickup pickup) {
    LaraAudio.playSfx(
      pickup.points >= 10 ? LaraSfx.hitPerfect : pickup.points >= 3 ? LaraSfx.coin : LaraSfx.hitGood,
    );
    add(ScorePopup(points: pickup.points, spawnPosition: pickup.position.clone()));
    pickup.removeFromParent();
    _score += pickup.points;
    setScore(_score);
  }

  void onBoneCollected(BonePickup pickup) {
    LaraAudio.playSfx(LaraSfx.hitGood);
    add(ScorePopup(points: 2, spawnPosition: pickup.position.clone()));
    pickup.removeFromParent();
    _score += 2;
    setScore(_score);
  }

  void onCoinCollected(CoinPickup pickup) {
    if (!_running) return;
    LaraAudio.playSfx(LaraSfx.coin);
    add(CoinPop(startPosition: pickup.position.clone()));
    pickup.removeFromParent();
    _coinsCollected++;
  }

  void onCrash() {
    if (!_running) return;
    LaraAudio.playSfx(LaraSfx.miss);
    _running = false;
    lastEntry = GalletaRunLeaderboard.submit(_score);
    showGameOver('¡Galleta tropezó!\nPuntos: $_score', () {});
  }
}
