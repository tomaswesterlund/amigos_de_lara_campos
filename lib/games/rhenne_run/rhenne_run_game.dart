import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/cloud.dart';
import 'components/lane_item.dart';
import 'components/runner_rhenne.dart';
import 'components/score_pop.dart';
import 'components/side_decor.dart';
import 'leaderboard.dart';

/// 3-lane infinite runner starring Rhenné. Tap left/right (or swipe) to
/// switch lanes. Catch corazones for points, dodge rocks.
class RhenneRunGame extends LaraGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  RhenneRunGame() : super(gradient: LaraGradients.pond, bgm: LaraBgm.rhenne);

  static const _laneCount = 3;
  static const _baseScroll = 280.0;
  static const _maxScroll = 600.0;
  static const _baseSpawn = 0.85;

  RunnerRhenne? _rhenne;
  Sprite? _heartSprite;
  Sprite? _goldenHeartSprite;
  Sprite? _pinkHeartSprite;
  Sprite? _rockSprite;
  Sprite? _birdSprite;
  Sprite? _lilypadSprite;
  int _lane = 1;
  int _score = 0;
  bool _running = true;

  /// Leaderboard entry created by the most recent crash. Read by the
  /// leaderboard overlay to highlight Lupita's just-played run.
  LeaderboardEntry? lastEntry;
  double _spawnTimer = 0;
  double _laneCooldown = 0;
  double _cloudTimer = 0;
  double _decorTimer = 0;
  final _rng = Random();

  double get _laneWidth => size.x / _laneCount;
  double get _playerY => size.y * 0.78;
  double get scrollSpeed =>
      (_baseScroll + _score * 5).clamp(_baseScroll, _maxScroll);

  double laneCenterX(int lane) => _laneWidth * (lane + 0.5);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _heartSprite = await loadSprite('corazon.png');
    _goldenHeartSprite = await loadSprite('corazon_yellow.png');
    _pinkHeartSprite = await loadSprite('corazon_pink.png');
    _rockSprite = await loadSprite('obstacle_water_rock.png');
    _birdSprite = await loadSprite('bird_enemy.png');
    _lilypadSprite = await loadSprite('lilypad.png');
    final r = RunnerRhenne(await loadSprite('rhenne.png'), laneWidth: _laneWidth);
    _rhenne = r;
    add(_LaneStripes());
    add(r);
    _placeRhenne();
    // Seed a couple of clouds so the sky isn't empty at start.
    for (var i = 0; i < 3; i++) {
      _spawnCloud(initial: true);
    }
  }

  void _placeRhenne() {
    final r = _rhenne;
    if (r == null) return;
    r.position = Vector2(laneCenterX(_lane), _playerY);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_rhenne != null) _placeRhenne();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    _laneCooldown = (_laneCooldown - dt).clamp(0, 1);
    _spawnTimer += dt;
    _cloudTimer += dt;
    _decorTimer += dt;

    final spawnInterval = (_baseSpawn - _score * 0.005).clamp(0.4, _baseSpawn);
    if (_spawnTimer >= spawnInterval) {
      _spawnTimer = 0;
      _spawn();
    }
    if (_cloudTimer >= 3.5) {
      _cloudTimer = 0;
      _spawnCloud();
    }
    if (_decorTimer >= 1.6) {
      _decorTimer = 0;
      _spawnSideDecor();
    }
  }

  void _spawn() {
    final heart = _heartSprite;
    final golden = _goldenHeartSprite;
    final pink = _pinkHeartSprite;
    final rock = _rockSprite;
    final bird = _birdSprite;
    if (heart == null || golden == null || pink == null || rock == null || bird == null) return;

    // Pick 1–2 lanes to fill this wave so the player always has a safe lane.
    final lanesShuffled = List.generate(_laneCount, (i) => i)..shuffle(_rng);
    final fillCount = 1 + _rng.nextInt(2); // 1 or 2
    for (var i = 0; i < fillCount; i++) {
      final lane = lanesShuffled[i];
      final roll = _rng.nextDouble();
      // 6% golden | 20% pink | 32% red | 22% rock | 20% bird
      final LaneItemKind kind;
      final Sprite sprite;
      if (roll < 0.06) {
        kind = LaneItemKind.goldenHeart;
        sprite = golden;
      } else if (roll < 0.26) {
        kind = LaneItemKind.pinkHeart;
        sprite = pink;
      } else if (roll < 0.58) {
        kind = LaneItemKind.heart;
        sprite = heart;
      } else if (roll < 0.80) {
        kind = LaneItemKind.rock;
        sprite = rock;
      } else {
        kind = LaneItemKind.bird;
        sprite = bird;
      }
      add(
        LaneItem(sprite: sprite, kind: kind, lane: lane)
          ..position = Vector2(laneCenterX(lane), -40),
      );
    }
  }

  void _spawnCloud({bool initial = false}) {
    final w = 80.0 + _rng.nextDouble() * 80.0;
    final h = w * 0.55;
    final speed = 18.0 + _rng.nextDouble() * 18.0;
    final goingRight = _rng.nextBool();
    final cloud = Cloud(driftSpeed: goingRight ? speed : -speed)
      ..size = Vector2(w, h)
      ..priority = -800
      ..position = Vector2(
        initial
            ? _rng.nextDouble() * size.x
            : (goingRight ? -w : size.x + w),
        20 + _rng.nextDouble() * (size.y * 0.25),
      );
    add(cloud);
  }

  void _spawnSideDecor() {
    final sprite = _lilypadSprite;
    if (sprite == null) return;
    final fromLeft = _rng.nextBool();
    final w = 60.0 + _rng.nextDouble() * 30.0;
    final pad = SideLilyPad(sprite: sprite, speedFactor: 0.7)
      ..size = Vector2(w, w * 0.55)
      ..priority = -700
      ..position = Vector2(
        fromLeft ? -10 + _rng.nextDouble() * 18 : size.x + 10 - _rng.nextDouble() * 18,
        -40,
      );
    add(pad);
  }

  void _switchLane(int delta) {
    if (!_running || _laneCooldown > 0) return;
    final next = (_lane + delta).clamp(0, _laneCount - 1);
    if (next == _lane) return;
    _lane = next;
    _laneCooldown = 0.12;
    _rhenne?.slideTo(laneCenterX(_lane));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_running) return;
    final tappedLane = (event.canvasPosition.x / _laneWidth)
        .floor()
        .clamp(0, _laneCount - 1);
    _switchLane((tappedLane - _lane).sign);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_running) return;
    if (event.localDelta.x.abs() < 6) return;
    _switchLane(event.localDelta.x > 0 ? 1 : -1);
  }

  void onHeartPicked(LaneItem item, {required int points}) {
    if (!_running) return;
    final pos = item.position.clone();
    final golden = item.kind == LaneItemKind.goldenHeart;
    final isPink = item.kind == LaneItemKind.pinkHeart;
    item.removeFromParent();
    LaraAudio.playSfx(points >= 10 ? LaraSfx.hitPerfect : points == 3 ? LaraSfx.coin : LaraSfx.hitGood);
    add(
      ScorePop(
        startPosition: pos,
        points: points,
        shadowColor: golden
            ? const Color(0xFFCB8A1A)
            : isPink
                ? LaraColors.pink
                : const Color(0xFFE33282),
        fontSize: golden ? 38 : isPink ? 32 : 28,
      ),
    );
    _score += points;
    setScore(_score);
  }

  Future<void> onCrash() async {
    if (!_running) return;
    LaraAudio.playSfx(LaraSfx.miss);
    _running = false;
    final r = _rhenne;
    if (r != null) {
      await r.crash();
    }
    lastEntry = RhenneRunLeaderboard.submit(_score);
    showGameOver('¡Rhenné chocó!', () {});
  }
}

/// Decorative lane dividers.
class _LaneStripes extends PositionComponent with HasGameReference<RhenneRunGame> {
  @override
  void onMount() {
    super.onMount();
    priority = -500;
    size = game.size;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    final stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final laneWidth = game.size.x / 3;
    for (var i = 1; i < 3; i++) {
      final x = laneWidth * i;
      final dashH = 18.0;
      final gap = 12.0;
      for (var y = 0.0; y < game.size.y; y += dashH + gap) {
        canvas.drawLine(Offset(x, y), Offset(x, y + dashH), stripe);
      }
    }
  }
}
