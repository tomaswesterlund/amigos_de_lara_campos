import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/lily_pad.dart';
import 'components/reina.dart';
import 'components/rhenne.dart';

/// Rhenné hops between lily pads scrolling right-to-left.
/// Tap to hop in place; if a pad is under Rhenné when he lands → score+1.
/// Land in the water → game over. Reach 8 in a row → Reina celebrates.
class RhenneJumpGame extends LaraGame with TapCallbacks {
  RhenneJumpGame() : super(gradient: LaraGradients.pond, bgm: LaraBgm.rhenne);

  static const _padInterval = 1.1;
  static const _basePadSpeed = 130.0;
  static const _winStreak = 8;

  Rhenne? _rhenne;
  Reina? _reina;
  Sprite? _padSprite;
  final _rng = Random();
  double _spawnTimer = 0;
  bool _running = true;
  int _streak = 0;

  double get _groundY => size.y * 0.78;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _padSprite = await loadSprite('lilypad.png');
    final rhenne = Rhenne(await loadSprite('rhenne.png'));
    final reina = Reina(await loadSprite('reina.png'));
    _rhenne = rhenne;
    _reina = reina;
    add(rhenne);
    add(reina);
    _placeActors();
    // Seed an initial pad directly under Rhenné so the first tap is fair.
    _spawnPad(atX: rhenne.position.x);
  }

  void _placeActors() {
    final r = _rhenne;
    final q = _reina;
    if (r == null || q == null) return;
    r.position = Vector2(size.x * 0.28, _groundY - r.size.y / 2);
    q.position = Vector2(size.x - q.size.x / 2 - 24, _groundY - q.size.y / 2);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_rhenne != null) _placeActors();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    _spawnTimer += dt;
    if (_spawnTimer >= _padInterval) {
      _spawnTimer = 0;
      _spawnPad();
    }
  }

  void _spawnPad({double? atX}) {
    final sprite = _padSprite;
    if (sprite == null) return;
    final speed = _basePadSpeed + _streak * 6;
    final pad = LilyPad(sprite: sprite, speed: speed)
      ..position = Vector2(
        atX ?? size.x + 80,
        _groundY + 18 + _rng.nextDouble() * 4,
      );
    add(pad);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final r = _rhenne;
    if (!_running || r == null || r.isJumping) return;
    LaraAudio.playSfx(LaraSfx.hitGood);
    r.hop(onLand: _evaluateLanding);
  }

  void _evaluateLanding() {
    final r = _rhenne;
    final q = _reina;
    if (r == null || q == null) return;
    final landX = r.position.x;
    bool landed = false;
    for (final p in children.whereType<LilyPad>()) {
      if ((p.position.x - landX).abs() < 70) {
        landed = true;
        break;
      }
    }
    if (landed) {
      _streak++;
      setScore(_streak);
      LaraAudio.playSfx(LaraSfx.hitPerfect);
      if (_streak >= _winStreak && !q.celebrating) {
        _running = false;
        LaraAudio.playSfx(LaraSfx.coin);
        q.celebrate();
        showGameOver('¡Encontraste a Reina!\nRhenné está feliz', () {});
      }
    } else {
      _running = false;
      LaraAudio.playSfx(LaraSfx.miss);
      showGameOver('¡Splash! Rhenné cayó al agua.\nPuntos: $_streak', () {});
    }
  }
}
