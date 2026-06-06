import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../core/lara_theme.dart';

/// Single running-dust puff that trails behind Galleta while she is on ground.
///
/// The game spawns one every ~0.10 s via [DustEmitter].
class DustParticle extends CircleComponent {
  DustParticle({required Vector2 spawnPosition, required Random rng})
      : super(
          radius: 5 + rng.nextDouble() * 4,
          anchor: Anchor.center,
          position: spawnPosition +
              Vector2(
                (rng.nextDouble() - 0.5) * 14,
                (rng.nextDouble() - 0.5) * 8,
              ),
          paint: Paint()
            ..color = LaraColors.galletaBrown.withValues(alpha: 0.55),
        );

  @override
  Future<void> onLoad() async {
    add(MoveByEffect(
      Vector2(-22, -10),
      EffectController(duration: 0.42, curve: Curves.easeOut),
    ));
    add(OpacityEffect.fadeOut(EffectController(duration: 0.42)));
    add(RemoveEffect(delay: 0.44));
  }
}

/// Manages the timed emission of [DustParticle]s while Galleta runs.
///
/// Add to the game scene once. Call [update] every frame (happens
/// automatically since it's a component). Pass [enabled] = false while
/// Galleta is airborne; [emitPosition] should follow Galleta's feet.
class DustEmitter extends Component {
  DustEmitter();

  static const _interval = 0.10;
  double _timer = 0;
  bool enabled = true;
  Vector2 emitPosition = Vector2.zero();

  final _rng = Random();

  @override
  void update(double dt) {
    if (!enabled) {
      _timer = 0;
      return;
    }
    _timer += dt;
    if (_timer >= _interval) {
      _timer = 0;
      parent?.add(DustParticle(spawnPosition: emitPosition, rng: _rng));
    }
  }
}
