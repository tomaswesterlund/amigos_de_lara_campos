import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/ambient_fish.dart';
import 'components/bubble_particle.dart';
import 'components/caustic_layer.dart';
import 'components/collectible_heart.dart';
import 'components/coral_fan.dart';
import 'components/jellyfish.dart';
import 'components/nada_rhenne.dart';
import 'components/seaweed_strip.dart';
import 'components/swimming_fish.dart';
import 'components/underwater_rock.dart';
import 'components/water_surface.dart';

/// Free-movement underwater side-scroller.
/// Drag up/down to control Rhenné as she swims right through the pond.
/// Dodge fish, jellyfish, and rocks; catch hearts for bonus points.
class RhenneNadaGame extends LaraGame with HasCollisionDetection, DragCallbacks {
  RhenneNadaGame() : super(gradient: LaraGradients.underwater, bgm: LaraBgm.rhenne);

  // Sprite/animation fields — nullable to avoid LateInitializationError
  // (Flame fires onGameResize before onLoad resolves on web).
  List<Sprite>? _swimSprites;
  List<Sprite>? _fishSprites;
  List<Sprite>? _jellySprites;
  List<Sprite>? _rockSprites;
  Sprite? _heartSprite;
  Sprite? _pinkHeartSprite;
  Sprite? _goldenHeartSprite;

  NadaRhenne? _rhenne;
  int _score = 0;
  int _pickupPoints = 0;
  int _coinsCollected = 0;
  double _elapsed = 0;
  bool _running = true;

  double _spawnTimer = 0;
  double _bubbleTimer = 0;

  final _rng = Random();

  int get coinsCollected => _coinsCollected;

  double get scrollSpeed => (140.0 + _score * 1.5).clamp(140.0, 320.0);
  double get _spawnInterval => (2.0 - _score * 0.008).clamp(0.9, 2.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load all animation frames in parallel
    _swimSprites = await Future.wait([
      loadSprite('rhenne_swim_1.png'),
      loadSprite('rhenne_swim_2.png'),
      loadSprite('rhenne_swim_3.png'),
      loadSprite('rhenne_swim_4.png'),
    ]);
    _fishSprites = await Future.wait([
      loadSprite('fish_swim_1.png'),
      loadSprite('fish_swim_2.png'),
      loadSprite('fish_swim_3.png'),
      loadSprite('fish_swim_4.png'),
    ]);
    _jellySprites = await Future.wait([
      loadSprite('jellyfish_1.png'),
      loadSprite('jellyfish_2.png'),
      loadSprite('jellyfish_3.png'),
      loadSprite('jellyfish_4.png'),
    ]);
    _rockSprites = await Future.wait([
      loadSprite('obstacle_water_rock_1.png'),
      loadSprite('obstacle_water_rock_2.png'),
      loadSprite('obstacle_water_rock_3.png'),
      loadSprite('obstacle_water_rock_4.png'),
    ]);
    _heartSprite = await loadSprite('corazon.png');
    _pinkHeartSprite = await loadSprite('corazon_pink.png');
    _goldenHeartSprite = await loadSprite('corazon_yellow.png');

    // Background atmosphere layers (lowest priorities first)
    add(CausticLayer());
    add(SeaweedStrip());
    add(CoralFan());
    add(AmbientFishSchool());

    // Player
    final swimAnim = SpriteAnimation.spriteList(_swimSprites!, stepTime: 0.12, loop: true);
    final rhenne = NadaRhenne(swimAnim)
      ..position = Vector2(size.x * 0.22, size.y * 0.5);
    _rhenne = rhenne;
    add(rhenne);

    // Water surface on top of everything
    add(WaterSurface());

    // Seed a couple of bubbles so the screen isn't empty at start
    for (var i = 0; i < 4; i++) {
      _spawnBubble(initial: true);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final r = _rhenne;
    if (r != null) {
      r.position.x = size.x * 0.22;
      r.position.y = r.position.y.clamp(r.size.y * 0.5, size.y - r.size.y * 0.5);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;

    _elapsed += dt;
    _spawnTimer += dt;
    _bubbleTimer += dt;

    // Score = seconds survived + pickup bonus
    final newScore = _elapsed.floor() + _pickupPoints;
    if (newScore != _score) {
      _score = newScore;
      setScore(_score);
    }

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawn();
    }

    if (_bubbleTimer >= 0.9) {
      _bubbleTimer = 0;
      _spawnBubble();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_running) return;
    _rhenne?.applyDragDelta(event.localDelta.y);
  }

  void _spawn() {
    final y = size.y * (0.15 + _rng.nextDouble() * 0.70);
    final x = size.x + 60;

    // 35 % chance collectible, rest obstacles
    final roll = _rng.nextDouble();
    if (roll < 0.22) {
      // Heart collectibles — rarer tiers more valuable
      final heartRoll = _rng.nextDouble();
      final Sprite sprite;
      final int points;
      if (heartRoll < 0.65) {
        sprite = _heartSprite!;
        points = 1;
      } else if (heartRoll < 0.90) {
        sprite = _pinkHeartSprite!;
        points = 3;
      } else {
        sprite = _goldenHeartSprite!;
        points = 10;
      }
      add(CollectibleHeart(sprite, points: points)..position = Vector2(x, y));
    } else if (roll < 0.30) {
      // Jellyfish
      final jellyAnim =
          SpriteAnimation.spriteList(_jellySprites!, stepTime: 0.15, loop: true);
      add(Jellyfish(jellyAnim)..position = Vector2(x, y));
    } else if (roll < 0.55) {
      // Underwater rock
      final rockAnim =
          SpriteAnimation.spriteList(_rockSprites!, stepTime: 0.4, loop: true);
      add(UnderwaterRock(rockAnim)..position = Vector2(x, y));
    } else {
      // Swimming fish — varied amplitude/frequency for unpredictability
      final fishAnim =
          SpriteAnimation.spriteList(_fishSprites!, stepTime: 0.08, loop: true);
      add(SwimmingFish(
        fishAnim,
        amplitude: 25 + _rng.nextDouble() * 40,
        frequency: 0.8 + _rng.nextDouble() * 1.2,
      )..position = Vector2(x, y));
    }
  }

  void _spawnBubble({bool initial = false}) {
    final x = _rng.nextDouble() * size.x;
    final startY = initial
        ? size.y * (0.3 + _rng.nextDouble() * 0.65)
        : size.y * (0.75 + _rng.nextDouble() * 0.2);
    add(BubbleParticle(
      startPosition: Vector2(x, startY),
      riseSpeed: 45 + _rng.nextDouble() * 40,
      driftX: (_rng.nextDouble() - 0.5) * 14,
    ));
  }

  /// Called by NadaRhenne on obstacle collision.
  void onObstacleHit() {
    if (!_running) return;
    _running = false;
    LaraAudio.playSfx(LaraSfx.miss);
    _rhenne?.playHitAnimation().then((_) {
      showGameOver('¡Rhenné chocó!\nPuntos: $_score', _restart);
    });
  }

  /// Called by NadaRhenne on collectible collision.
  void onCollectiblePicked(CollectibleHeart heart, int points) {
    if (!_running) return;
    final pos = heart.absolutePosition.clone();
    heart.removeFromParent();
    _pickupPoints += points;
    _coinsCollected += points >= 10 ? 2 : 1;
    LaraAudio.playSfx(points >= 10 ? LaraSfx.hitPerfect : LaraSfx.hitGood);
    _rhenne?.playPickupBurst();
    add(_ScorePop(startPosition: pos, points: points));
    add(_RippleRing(position: pos));
    if (points >= 3) add(_RippleRing(position: pos, delay: 0.08));
    if (points >= 10) add(_RippleRing(position: pos, delay: 0.16));
  }

  void _restart() {
    clearGameOver();
    _score = 0;
    _pickupPoints = 0;
    _coinsCollected = 0;
    _elapsed = 0;
    _spawnTimer = 0;
    _bubbleTimer = 0;
    _running = true;
    setScore(0);

    // Remove all gameplay components except background layers and player
    final toRemove = children.whereType<PositionComponent>().where((c) =>
        c is SwimmingFish ||
        c is Jellyfish ||
        c is UnderwaterRock ||
        c is CollectibleHeart ||
        c is BubbleParticle).toList();
    for (final c in toRemove) {
      c.removeFromParent();
    }

    // Reset Rhenné
    final r = _rhenne;
    if (r != null) {
      r.position = Vector2(size.x * 0.22, size.y * 0.5);
    }

    // Seed new bubbles
    for (var i = 0; i < 4; i++) {
      _spawnBubble(initial: true);
    }
  }
}

/// Floating "+N" score pop — same pattern as rhenne_run's ScorePop.
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
                Shadow(offset: Offset(0, 2), blurRadius: 0, color: LaraColors.rhenneGreenDark),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(SequenceEffect(
      [
        MoveByEffect(Vector2(0, -60), EffectController(duration: 0.55, curve: Curves.easeOut)),
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.15, curve: Curves.easeIn)),
      ],
      onComplete: removeFromParent,
    ));
  }
}

/// Expanding translucent ring that bursts out on pickup.
class _RippleRing extends PositionComponent {
  _RippleRing({required Vector2 position, double delay = 0.0})
      : _delay = delay,
        super(position: position, anchor: Anchor.center);

  static const _duration = 0.48;
  final double _delay;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _delay + _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = ((_elapsed - _delay) / _duration).clamp(0.0, 1.0);
    if (t <= 0) return;
    final radius = 8 + t * 52;
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = LaraColors.yellow.withValues(alpha: (1 - t) * 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 - t * 2.5,
    );
  }
}
