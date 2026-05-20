import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_nada_game.dart';
import 'collectible_heart.dart';
import 'jellyfish.dart';
import 'swimming_fish.dart';
import 'underwater_rock.dart';

/// Rhenné the swimmer — drag-controlled, velocity-based movement with tilt.
/// Uses SpriteAnimationComponent for the first frame-based animation in this codebase.
class NadaRhenne extends SpriteAnimationComponent
    with HasGameReference<RhenneNadaGame>, CollisionCallbacks {
  NadaRhenne(SpriteAnimation animation)
      : super(animation: animation, size: Vector2.all(88), anchor: Anchor.center);

  // Drag physics constants
  static const _kDragSensitivity = 3.2;
  static const _kDamping = 0.88; // velocity fraction retained per frame at 60fps
  static const _kMaxVelocity = 340.0;
  static const _kMaxAngle = 0.349; // ~20 degrees in radians

  double _velocityY = 0;
  bool _isHit = false;

  double get _minY => size.y * 0.5;
  double get _maxY => game.size.y - size.y * 0.5;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox.relative(0.52, parentSize: size));
  }

  /// Called from the game's onDragUpdate — accumulates vertical velocity.
  void applyDragDelta(double dy) {
    _velocityY = (_velocityY + dy * _kDragSensitivity).clamp(-_kMaxVelocity, _kMaxVelocity);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isHit) return;

    // Exponential damping — frame-rate independent via pow()
    _velocityY *= math.pow(_kDamping, dt * 60).toDouble();

    // Integrate position and clamp to playfield
    position.y = (position.y + _velocityY * dt).clamp(_minY, _maxY);

    // Tilt: nose dips when diving down, lifts when rising
    angle = (_velocityY / _kMaxVelocity * _kMaxAngle).clamp(-_kMaxAngle, _kMaxAngle);
  }

  /// Scale burst + sparkles on heart/coin pickup.
  void playPickupBurst() {
    if (_isHit) return;
    // Quick scale pop: up then back
    add(ScaleEffect.to(
      Vector2.all(1.4),
      EffectController(duration: 0.08, curve: Curves.easeOut),
    ));
    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.09, startDelay: 0.08, curve: Curves.easeIn),
    ));
    // Spawn 4 sparkles around Rhenné
    for (var i = 0; i < 4; i++) {
      _spawnSparkle();
    }
  }

  void _spawnSparkle() {
    final rng = math.Random();
    final offset = Vector2(
      (rng.nextDouble() - 0.5) * 56,
      (rng.nextDouble() - 0.5) * 56,
    );
    final sparkle = CircleComponent(
      radius: 5,
      anchor: Anchor.center,
      position: position + offset,
      paint: Paint()..color = LaraColors.yellow,
    );
    sparkle.add(ScaleEffect.to(
      Vector2.all(2.4),
      EffectController(duration: 0.32, curve: Curves.easeOut),
    ));
    sparkle.add(OpacityEffect.fadeOut(
      EffectController(duration: 0.32),
    ));
    sparkle.add(RemoveEffect(delay: 0.35));
    game.add(sparkle);
  }

  /// Flash + spin + shrink on obstacle hit.
  Future<void> playHitAnimation() async {
    _isHit = true;
    // Three opacity flashes
    for (var i = 0; i < 3; i++) {
      add(OpacityEffect.to(0.25, EffectController(duration: 0.07)));
      await Future<void>.delayed(const Duration(milliseconds: 75));
      add(OpacityEffect.to(1.0, EffectController(duration: 0.07)));
      await Future<void>.delayed(const Duration(milliseconds: 75));
    }
    // Spin and shrink simultaneously
    add(RotateEffect.by(math.pi * 2, EffectController(duration: 0.42, curve: Curves.easeIn)));
    add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.42, curve: Curves.easeIn)));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isHit) return;
    if (other is UnderwaterRock || other is SwimmingFish || other is Jellyfish) {
      game.onObstacleHit();
    } else if (other is CollectibleHeart) {
      game.onCollectiblePicked(other, other.points);
    }
  }
}
