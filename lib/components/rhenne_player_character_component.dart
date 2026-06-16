import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/widgets.dart';
import 'package:lara_demo/core/constants.dart';

enum RhennePlayerCharacterState { idle, jump, die }

class RhennePlayerCharacterComponent extends PositionComponent with CollisionCallbacks {
  final Function(PositionComponent player, PositionComponent other) onCollisionStarted;

  RhennePlayerCharacterComponent({
    required this.onCollisionStarted,
    super.position,
    super.size,
    super.anchor = Anchor.center,
  });

  late final SpineComponent _spine;

  RhennePlayerCharacterState _currentState = RhennePlayerCharacterState.idle;
  bool get isJumping => _currentState == RhennePlayerCharacterState.jump;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/rhenne/rhenne.atlas',
      skeletonFile: 'assets/sprites/rhenne/rhenne.json',
      anchor: Anchor.center,
      position: size / 2,
    );

    _spine.scale = Vector2.all(size.x / _spine.size.x);

    await add(_spine);

    await add(
      RectangleHitbox.relative(
        Vector2(0.7, 1.0),
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2 + Vector2(0, size.y * 0.1),
      ),
    );

    setAnimation(RhennePlayerCharacterState.idle);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    onCollisionStarted(this, other);
  }

  void setAnimation(RhennePlayerCharacterState newState, {VoidCallback? onComplete}) {
    try {
      if (_currentState == RhennePlayerCharacterState.die) return;
      //if (_currentState == newState && newState != RhennePlayerCharacterState.jump) return;

      _currentState = newState;

      switch (newState) {
        case RhennePlayerCharacterState.idle:
          _spine.animationState.setAnimation(0, 'Rhenne_iddle', true);
          break;

        case RhennePlayerCharacterState.jump:
          final track = _spine.animationState.setAnimation(0, 'Rhenne_jump', false);
          track.timeScale = 1;

          // Listen for when the jump finishes so we can automatically return to idle
          track.setListener((type, entry, event) {
            if (type == EventType.complete && _currentState == RhennePlayerCharacterState.jump) {
              setAnimation(RhennePlayerCharacterState.idle);
            }
          });

          break;

        case RhennePlayerCharacterState.die:
          final track = _spine.animationState.setAnimation(0, 'Rhenne_game over', false);
          track.timeScale = 0.25;

          track.setListener((type, entry, event) {
            if (type == EventType.complete && _currentState == RhennePlayerCharacterState.die) {
              onComplete?.call();
            }
          });
          break;
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  void jumpTo(Vector2 targetPosition) {
    if (isJumping) return;
    _currentState = RhennePlayerCharacterState.jump;

    setAnimation(RhennePlayerCharacterState.jump);

    const jumpDuration = 0.4;
    final jumpHeight = size.y * 1;

    // Calculate the total distance we need to travel
    final deltaX = targetPosition.x - position.x;
    final deltaY = targetPosition.y - position.y;

    add(
      SequenceEffect(
        [
          // First half: Move halfway on X, and arc UP by the jumpHeight
          MoveEffect.by(
            Vector2(deltaX / 2, deltaY / 2 - jumpHeight),
            EffectController(duration: jumpDuration / 2, curve: Curves.easeOutQuad),
          ),
          // Second half: Move the remaining halfway on X, and drop DOWN to the target Y
          MoveEffect.by(
            Vector2(deltaX / 2, deltaY / 2 + jumpHeight),
            EffectController(duration: jumpDuration / 2, curve: Curves.easeInQuad),
          ),
        ],
        onComplete: () {
          if (_currentState == RhennePlayerCharacterState.die) return;
          _currentState = RhennePlayerCharacterState.idle;
          setAnimation(RhennePlayerCharacterState.idle);
        },
      ),
    );
  }
}
