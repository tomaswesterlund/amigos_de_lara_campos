import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/brinca_cloud.dart';
import 'components/brinca_rhenne.dart';
import 'components/brinca_sky_layer.dart';
import 'components/brinca_water_layer.dart';
import 'components/falling_item.dart';
import 'components/lily_pad.dart';

/// 3-lane lily-pad jumping game.
/// Items fall from the sky — catch fireflies and hearts, dodge rain, leaves, acorns.
/// Tap left/right half of screen to jump Rhenné between pads.
class RhenneBrincaGame extends LaraGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  RhenneBrincaGame()
      : super(gradient: LaraGradients.pond, bgm: LaraBgm.rhenne);

  static const _laneCount = 3;

  // Sprite fields (nullable — onGameResize fires before onLoad on web)
  Sprite? _heartSprite;
  Sprite? _pinkHeartSprite;
  Sprite? _goldenHeartSprite;

  BrincaRhenne? _rhenne;
  final List<LilyPad> _pads = [];

  int _lane           = 1;
  int _score          = 0;
  int _coinsCollected = 0;
  bool _running       = true;

  double _laneCooldown = 0;
  double _spawnTimer   = 0;
  double _cloudTimer   = 0;

  final _rng = Random();

  int get coinsCollected => _coinsCollected;

  // Exposed to components
  double get laneWidth    => size.x / _laneCount;
  double get padY         => size.y * 0.79;
  double get scrollSpeed  => (180.0 + _score * 2.5).clamp(180.0, 440.0);
  double get _spawnInterval => (1.4 - _score * 0.006).clamp(0.62, 1.4);

  double laneCenterX(int lane) => laneWidth * (lane + 0.5);

  /// The pad Rhenné is currently on. Null until pads are loaded.
  LilyPad? get currentPad => _pads.isNotEmpty ? _pads[_lane] : null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load sprites in parallel
    final sprites = await Future.wait([
      loadSprite('rhenne_swim_1.png'),
      loadSprite('rhenne_swim_2.png'),
      loadSprite('rhenne_swim_3.png'),
      loadSprite('rhenne_swim_4.png'),
      loadSprite('corazon.png'),
      loadSprite('corazon_pink.png'),
      loadSprite('corazon_yellow.png'),
    ]);
    _heartSprite       = sprites[4];
    _pinkHeartSprite   = sprites[5];
    _goldenHeartSprite = sprites[6];

    final swimAnim = SpriteAnimation.spriteList(
      sprites.sublist(0, 4),
      stepTime: 0.14,
      loop: true,
    );

    // Environment layers (background → foreground order)
    add(BrincaSkyLayer());
    add(BrincaWaterLayer());

    // Lily pads
    for (var i = 0; i < _laneCount; i++) {
      final pad = LilyPad(laneIndex: i);
      _pads.add(pad);
      add(pad);
    }

    // Player
    final rhenne = BrincaRhenne(swimAnim);
    _rhenne = rhenne;
    add(rhenne);
    _placeRhenne(animate: false);

    // Seed clouds so sky isn't empty at start
    for (var i = 0; i < 4; i++) {
      _spawnCloud(initial: true);
    }
  }

  void _placeRhenne({bool animate = true}) {
    final r = _rhenne;
    if (r == null) return;
    final target = Vector2(laneCenterX(_lane), padY - 38);
    if (animate) {
      r.jumpTo(target);
    } else {
      r.position = target;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_rhenne != null) _placeRhenne(animate: false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;

    _laneCooldown = (_laneCooldown - dt).clamp(0.0, 1.0);
    _spawnTimer  += dt;
    _cloudTimer  += dt;

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnItems();
    }
    if (_cloudTimer >= 3.2) {
      _cloudTimer = 0;
      _spawnCloud();
    }
  }

  void _spawnItems() {
    final heart  = _heartSprite;
    final pink   = _pinkHeartSprite;
    final golden = _goldenHeartSprite;
    if (heart == null || pink == null || golden == null) return;

    // Always leave ≥1 safe lane
    final lanesShuffled = List.generate(_laneCount, (i) => i)..shuffle(_rng);
    final fillCount = _rng.nextDouble() < 0.42 ? 2 : 1;

    for (var i = 0; i < fillCount; i++) {
      final lane = lanesShuffled[i];
      final roll = _rng.nextDouble();

      FallingItemKind kind;
      Sprite? sprite;

      if (roll < 0.22) {
        kind = FallingItemKind.raindrop; sprite = null;
      } else if (roll < 0.40) {
        kind = FallingItemKind.leaf;     sprite = null;
      } else if (roll < 0.53) {
        kind = FallingItemKind.acorn;    sprite = null;
      } else if (roll < 0.68) {
        kind = FallingItemKind.firefly;  sprite = null;
      } else if (roll < 0.78) {
        kind = FallingItemKind.pinkHeart; sprite = pink;
      } else if (roll < 0.90) {
        kind = FallingItemKind.heart;    sprite = heart;
      } else {
        kind = FallingItemKind.star;     sprite = null;
      }

      add(
        FallingItem(kind: kind, lane: lane, sprite: sprite)
          ..position = Vector2(laneCenterX(lane), -55),
      );
    }
  }

  void _spawnCloud({bool initial = false}) {
    final w      = 90.0 + _rng.nextDouble() * 110.0;
    final speed  = 14.0 + _rng.nextDouble() * 18.0;
    final goRight = _rng.nextBool();
    add(
      BrincaCloud(driftSpeed: goRight ? speed : -speed)
        ..size     = Vector2(w, w * 0.52)
        ..priority = -700
        ..position = Vector2(
          initial
              ? _rng.nextDouble() * size.x
              : (goRight ? -w : size.x + w),
          18 + _rng.nextDouble() * (size.y * 0.28),
        ),
    );
  }

  // ── Input ────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (!_running) return;
    final tappedLane = (event.canvasPosition.x / laneWidth)
        .floor()
        .clamp(0, _laneCount - 1);
    _switchLane((tappedLane - _lane).sign);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_running) return;
    if (event.localDelta.x.abs() < 8) return;
    _switchLane(event.localDelta.x > 0 ? 1 : -1);
  }

  void _switchLane(int delta) {
    if (delta == 0 || _laneCooldown > 0) return;
    final next = (_lane + delta).clamp(0, _laneCount - 1);
    if (next == _lane) return;
    _lane         = next;
    _laneCooldown = 0.22;
    _placeRhenne();
  }

  // ── Game-event callbacks (called by components) ──────────────────────────

  void onItemCaught(FallingItem item, int points) {
    if (!_running) return;
    final pos = item.position.clone();
    item.removeFromParent();
    _score          += points;
    _coinsCollected += points >= 10 ? 2 : 1;
    setScore(_score);
    LaraAudio.playSfx(points >= 10 ? LaraSfx.hitPerfect : LaraSfx.hitGood);
    _rhenne?.playPickupBurst();
    currentPad?.ripple();
    add(_ScorePop(startPosition: pos, points: points));
  }

  Future<void> onObstacleHit() async {
    if (!_running) return;
    _running = false;
    LaraAudio.playSfx(LaraSfx.miss);
    final r = _rhenne;
    if (r != null) await r.crash();
    showGameOver('¡Rhenné cayó!\nPuntos: $_score', _restart);
  }

  void _restart() {
    clearGameOver();
    _score          = 0;
    _coinsCollected = 0;
    _spawnTimer     = 0;
    _cloudTimer     = 0;
    _lane           = 1;
    _running        = true;
    setScore(0);

    final toRemove = children.whereType<FallingItem>().toList();
    for (final c in toRemove) { c.removeFromParent(); }

    _placeRhenne(animate: false);
  }
}

// ── Score pop ────────────────────────────────────────────────────────────────

class _ScorePop extends TextComponent {
  _ScorePop({required Vector2 startPosition, required int points})
      : super(
          text: '+$points',
          anchor: Anchor.center,
          position: startPosition,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: const [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 0,
                  color: LaraColors.rhenneGreenDark,
                ),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(SequenceEffect(
      [
        MoveByEffect(
          Vector2(0, -65),
          EffectController(duration: 0.55, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.15, curve: Curves.easeIn),
        ),
      ],
      onComplete: removeFromParent,
    ));
  }
}
