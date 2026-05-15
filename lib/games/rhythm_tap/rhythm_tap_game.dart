import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/beat_note.dart';
import 'components/hit_zone.dart';

/// 4-lane rhythm minigame. Notes fall toward a hit zone; tap when the note
/// overlaps the zone for "Perfect", "Good", or "Miss". Audio is intentionally
/// stubbed — placeholder click could be added with `flame_audio` later.
class RhythmTapGame extends LaraGame {
  RhythmTapGame() : super(gradient: LaraGradients.party);

  static const _lanes = 4;
  static const _noteSpeed = 320.0;
  static const _spawnInterval = 0.7;
  static const _gameDuration = 35.0;

  late final List<Sprite> _noteSprites;
  final _rng = Random();
  double _spawnTimer = 0;
  double _elapsed = 0;
  int _score = 0;
  bool _running = true;
  final _hitZones = <HitZone>[];
  TextComponent? _feedback;

  static const _laneColors = [
    LaraColors.pink,
    LaraColors.mint,
    LaraColors.yellow,
    LaraColors.rhenneGreen,
  ];

  double get _laneWidth => size.x / _lanes;
  double get _hitZoneY => size.y * 0.78;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _noteSprites = await Future.wait([
      loadSprite('corazon.png'),
      loadSprite('corazon_pink.png'),
      loadSprite('corazon_yellow.png'),
      loadSprite('music_note.png'),
    ]);
    _buildHitZones();
  }

  void _buildHitZones() {
    for (final z in _hitZones) {
      z.removeFromParent();
    }
    _hitZones.clear();
    for (var i = 0; i < _lanes; i++) {
      final z = HitZone(
        lane: i,
        color: _laneColors[i],
        onTap: () => _evaluateTap(i),
      )
        ..size = Vector2(_laneWidth - 8, 70)
        ..anchor = Anchor.center
        ..position = Vector2(_laneWidth * (i + 0.5), _hitZoneY);
      _hitZones.add(z);
      add(z);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_hitZones.isNotEmpty) _buildHitZones();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    _elapsed += dt;
    if (_elapsed >= _gameDuration) {
      _running = false;
      showGameOver('¡Bien hecho!\nPuntos: $_score', () {});
      return;
    }
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnNote();
    }
  }

  void _spawnNote() {
    final lane = _rng.nextInt(_lanes);
    final sprite = _noteSprites[lane % _noteSprites.length];
    final note = BeatNote(
      lane: lane,
      sprite: sprite,
      speed: _noteSpeed,
    )
      ..size = Vector2.all(58)
      ..anchor = Anchor.center
      ..position = Vector2(_laneWidth * (lane + 0.5), -30);
    add(note);
  }

  void _evaluateTap(int lane) {
    if (!_running) return;
    BeatNote? closest;
    double bestDist = double.infinity;
    for (final n in children.whereType<BeatNote>()) {
      if (n.lane != lane || n.consumed) continue;
      final d = (n.position.y - _hitZoneY).abs();
      if (d < bestDist) {
        bestDist = d;
        closest = n;
      }
    }
    if (closest == null || bestDist > 60) {
      _flashFeedback('¡Ay!', LaraColors.magenta);
      return;
    }
    closest.consumed = true;
    closest.removeFromParent();
    if (bestDist < 18) {
      _score += 100;
      _flashFeedback('¡Perfecto!', LaraColors.rhenneGreen);
    } else if (bestDist < 40) {
      _score += 50;
      _flashFeedback('¡Bien!', LaraColors.yellow);
    } else {
      _score += 20;
      _flashFeedback('Ok', LaraColors.mint);
    }
    setScore(_score);
  }

  void onNoteMissed(BeatNote note) {
    if (!_running) return;
    _flashFeedback('Falló', LaraColors.magenta);
  }

  void _flashFeedback(String text, Color color) {
    _feedback?.removeFromParent();
    final fb = TextComponent(
      text: text,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.4),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: color,
          shadows: const [
            Shadow(offset: Offset(0, 2), blurRadius: 0, color: Colors.white),
          ],
        ),
      ),
    );
    _feedback = fb;
    add(fb);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (fb.isMounted) fb.removeFromParent();
    });
  }
}
