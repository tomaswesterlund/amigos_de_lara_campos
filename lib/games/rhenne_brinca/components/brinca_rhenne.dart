import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../rhenne_brinca_game.dart';

/// Rhenné on lily pads — animated frog that jumps between 3 lanes.
///
/// Split into two layers to keep collision detection stable:
///   • [BrincaRhenne] (PositionComponent) owns the [CircleHitbox] and all
///     jump/movement effects. Its size and position are never modified by
///     visual animations, so the hitbox is always authoritative.
///   • [_RhenneVisual] (SpriteAnimationComponent) is a child that receives
///     every transient effect — idle bounce, landing squash, pickup burst,
///     lean, crash flash/spin. Scaling or moving the visual never touches
///     the parent's hitbox.
class BrincaRhenne extends PositionComponent
    with HasGameReference<RhenneBrincaGame> {
  BrincaRhenne(SpriteAnimation animation)
      : _animation = animation,
        super(
          size: Vector2.all(78),
          anchor: Anchor.center,
        );

  final SpriteAnimation _animation;
  bool _isHit = false;
  late _RhenneVisual _visual;

  @override
  Future<void> onLoad() async {
    // Hitbox lives on the parent — never affected by visual scale/move effects.
    // 0.68 relative → radius ≈ 26.5 px on a 78 px sprite (~34 % increase over
    // the previous 0.44 value, which gave only a 17 px radius).
    add(CircleHitbox.relative(0.68, parentSize: size));

    _visual = _RhenneVisual(_animation, size);
    add(_visual);
  }

  /// Arc jump from current position to [target].
  void jumpTo(Vector2 target) {
    if (_isHit) return;
    // Cancel any in-flight move effects on the parent so the hitbox snaps to
    // the new arc immediately rather than fighting the old one.
    children.whereType<MoveEffect>().toList().forEach((e) => e.removeFromParent());

    final peak = Vector2(
      (position.x + target.x) / 2,
      target.y - 45,
    );

    // Move effects on the parent → hitbox travels with Rhenné.
    add(SequenceEffect(
      [
        MoveToEffect(peak,   EffectController(duration: 0.11, curve: Curves.easeOut)),
        MoveToEffect(target, EffectController(duration: 0.10, curve: Curves.easeIn)),
      ],
      onComplete: () {
        if (!isMounted) return;
        _onLanded();
      },
    ));

    // Lean goes on the visual child only — hitbox stays unrotated.
    final dir = (target.x - position.x).sign;
    if (dir != 0) {
      _visual.add(RotateEffect.to(
        dir * 0.22,
        EffectController(duration: 0.11, alternate: true, reverseDuration: 0.10),
      ));
    }
  }

  void _onLanded() {
    // Squash/stretch on the visual child — hitbox size is unaffected.
    _visual.add(ScaleEffect.to(
      Vector2(1.38, 0.62),
      EffectController(duration: 0.045, curve: Curves.easeOut),
    ));
    _visual.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(
        duration: 0.18,
        startDelay: 0.045,
        curve: Curves.elasticOut,
      ),
    ));
    game.currentPad?.ripple();
  }

  /// Scale pop + multi-colour sparkles on collectible pickup.
  void playPickupBurst() {
    if (_isHit) return;
    // Scale effects on the visual child — hitbox stays at its fixed size,
    // so the momentary 1.45× expansion cannot trigger phantom obstacle hits.
    _visual.add(ScaleEffect.to(
      Vector2.all(1.45),
      EffectController(duration: 0.07, curve: Curves.easeOut),
    ));
    _visual.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.11, startDelay: 0.07, curve: Curves.easeIn),
    ));
    for (var i = 0; i < 6; i++) {
      _spawnSparkle();
    }
  }

  void _spawnSparkle() {
    final rng    = math.Random();
    final offset = Vector2(
      (rng.nextDouble() - 0.5) * 72,
      (rng.nextDouble() - 0.5) * 72,
    );
    const colors = [LaraColors.yellow, LaraColors.mint, LaraColors.pink, LaraColors.corazonRed];
    final color  = colors[rng.nextInt(colors.length)];
    final sparkle = CircleComponent(
      radius: 4,
      anchor: Anchor.center,
      position: position + offset,
      paint: Paint()..color = color,
    );
    sparkle.add(ScaleEffect.to(
      Vector2.all(2.6),
      EffectController(duration: 0.36, curve: Curves.easeOut),
    ));
    sparkle.add(OpacityEffect.fadeOut(EffectController(duration: 0.36)));
    sparkle.add(RemoveEffect(delay: 0.38));
    game.add(sparkle);
  }

  /// Flash + spin + shrink on obstacle hit.
  Future<void> crash() async {
    _isHit = true;
    _visual.stopBounce();
    for (var i = 0; i < 3; i++) {
      _visual.add(OpacityEffect.to(0.2, EffectController(duration: 0.07)));
      await Future<void>.delayed(const Duration(milliseconds: 75));
      _visual.add(OpacityEffect.to(1.0, EffectController(duration: 0.07)));
      await Future<void>.delayed(const Duration(milliseconds: 75));
    }
    _visual.add(RotateEffect.by(
      math.pi * 2,
      EffectController(duration: 0.45, curve: Curves.easeIn),
    ));
    _visual.add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.45, curve: Curves.easeIn),
    ));
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }
}

// ── Visual-only child ─────────────────────────────────────────────────────────

/// Sprite + idle animation for Rhenné. Receives every transient effect
/// (scale, lean, flash) so that [BrincaRhenne]'s hitbox stays unaffected.
class _RhenneVisual extends SpriteAnimationComponent {
  _RhenneVisual(SpriteAnimation animation, Vector2 parentSize)
      : super(
          animation: animation,
          size: parentSize,
          anchor: Anchor.center,
          // Centre of this visual sits at the centre of the parent's local space.
          position: parentSize / 2,
        );

  Effect? _bounce;

  @override
  Future<void> onLoad() async {
    _bounce = MoveByEffect(
      Vector2(0, -5),
      EffectController(
        duration: 0.48,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    );
    add(_bounce!);
  }

  void stopBounce() => _bounce?.removeFromParent();
}
