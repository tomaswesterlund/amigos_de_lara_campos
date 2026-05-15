import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/flying_rhenne.dart';
import 'components/pipe.dart';

/// Simplified Flappy Bird with Rhenné the frog. Tap to flap; gravity pulls
/// down. Hit a pipe or fall off the screen → game over.
class RhenneFlyGame extends LaraGame
    with TapCallbacks, HasCollisionDetection {
  RhenneFlyGame() : super(gradient: LaraGradients.pond);

  static const _gravity = 1500.0;
  static const _flapVelocity = -480.0;
  static const _scrollSpeed = 170.0;
  static const _pipeInterval = 1.8;
  static const _pipeGap = 200.0;
  static const _pipeWidth = 74.0;

  FlyingRhenne? _rhenne;
  TextComponent? _hint;
  double _velocityY = 0;
  double _spawnTimer = 0;
  int _score = 0;
  bool _running = true;
  bool _started = false;
  final _rng = Random();

  double get scrollSpeed => _scrollSpeed;
  double get playerX => size.x * 0.3;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final r = FlyingRhenne(await loadSprite('rhenne.png'));
    _rhenne = r;
    r.position = Vector2(playerX, size.y * 0.4);
    add(r);

    final hint = TextComponent(
      text: '¡Toca para volar!',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.22),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(offset: Offset(0, 3), blurRadius: 0, color: LaraColors.magenta),
          ],
        ),
      ),
    );
    _hint = hint;
    add(hint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_running) return;
    if (!_started) {
      _started = true;
      // TextComponent isn't an OpacityProvider, so we can't fadeOut it
      // directly. Shrink it instead — same friendly "poof" effect, and
      // ScaleEffect works because PositionComponent is a ScaleProvider.
      final hint = _hint;
      if (hint != null) {
        hint.add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(duration: 0.25, curve: Curves.easeIn),
            onComplete: hint.removeFromParent,
          ),
        );
      }
    }
    _velocityY = _flapVelocity;
    _rhenne?.flap();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    final r = _rhenne;
    if (r == null) return;
    // Hover gently until the first tap so kids can prep.
    if (!_started) {
      r.position.y = size.y * 0.4 + sin(currentTime() * 3) * 6;
      return;
    }
    _velocityY += _gravity * dt;
    r.position.y += _velocityY * dt;
    r.tiltFromVelocity(_velocityY);

    final halfH = r.size.y / 2;
    if (r.position.y > size.y - halfH - 4 || r.position.y < halfH + 4) {
      onCrash();
      return;
    }

    _spawnTimer += dt;
    if (_spawnTimer >= _pipeInterval) {
      _spawnTimer = 0;
      _spawnPipePair();
    }
  }

  void _spawnPipePair() {
    final gapCenter = size.y * 0.28 + _rng.nextDouble() * size.y * 0.44;
    add(
      Pipe(top: true, gapCenter: gapCenter, gap: _pipeGap, pipeWidth: _pipeWidth)
        ..position = Vector2(size.x + _pipeWidth, 0),
    );
    add(
      Pipe(
        top: false,
        gapCenter: gapCenter,
        gap: _pipeGap,
        pipeWidth: _pipeWidth,
        scorer: true,
      )..position = Vector2(size.x + _pipeWidth, 0),
    );
  }

  void onPipePassed() {
    if (!_running) return;
    _score++;
    setScore(_score);
    final r = _rhenne;
    if (r != null) {
      _spawnSparkle(r.position + Vector2(0, -r.size.y * 0.4));
    }
  }

  void _spawnSparkle(Vector2 at) {
    final sparkle = CircleComponent(
      radius: 8,
      anchor: Anchor.center,
      position: at,
      paint: Paint()..color = LaraColors.yellow,
    );
    sparkle.add(
      ScaleEffect.to(
        Vector2.all(2.4),
        EffectController(duration: 0.45, curve: Curves.easeOut),
      ),
    );
    sparkle.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.45),
        onComplete: sparkle.removeFromParent,
      ),
    );
    add(sparkle);
  }

  void onCrash() {
    if (!_running) return;
    _running = false;
    showGameOver('¡Rhenné se cayó!\nPuntos: $_score', () {});
  }
}
