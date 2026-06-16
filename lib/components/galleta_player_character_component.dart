import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/widgets.dart';
import 'package:lara_demo/core/constants.dart';
import 'package:lara_demo/core/lara_audio.dart';

enum GalletaPlayerCharacterState { die, jump, run }

class GalletaPlayerCharacterComponent extends PositionComponent with CollisionCallbacks {
  final Function(PositionComponent player, PositionComponent other) onCollisionStarted;

  GalletaPlayerCharacterComponent({
    required this.onCollisionStarted,
    required super.size,
    super.position,
    super.anchor = Anchor.center,
  });

  late final SpineComponent _spine;

  GalletaPlayerCharacterState _currentState = GalletaPlayerCharacterState.run;

  bool get isDead => _currentState == GalletaPlayerCharacterState.die;
  bool get isJumping => _currentState == GalletaPlayerCharacterState.jump;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/galleta/galleta.atlas',
      skeletonFile: 'assets/sprites/galleta/galleta.json',
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

    setAnimation(GalletaPlayerCharacterState.run);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    onCollisionStarted(this, other);
  }

  void setAnimation(GalletaPlayerCharacterState newState, {VoidCallback? onComplete}) {
    try {
      if (_currentState == GalletaPlayerCharacterState.die) return;

      switch (newState) {
        case GalletaPlayerCharacterState.run:
          final track = _spine.animationState.setAnimation(0, 'Galleta_run', true);
          track.timeScale = 1.30;
          break;

        case GalletaPlayerCharacterState.jump:
          final track = _spine.animationState.setAnimation(0, 'Galleta_jump', false);
          track.timeScale = 1;

          // Listen for when the jump finishes so we can automatically return to idle
          track.setListener((type, entry, event) {
            if (type == EventType.complete && _currentState == GalletaPlayerCharacterState.jump) {
              setAnimation(GalletaPlayerCharacterState.run);
            }
          });

          break;

        case GalletaPlayerCharacterState.die:
          final track = _spine.animationState.setAnimation(0, 'Galleta_gameover', false);
          track.timeScale = 0.25;

          track.setListener((type, entry, event) {
            if (type == EventType.complete && _currentState == GalletaPlayerCharacterState.die) {
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

  void die({VoidCallback? onAnimationComplete}) {
    if (_currentState == GalletaPlayerCharacterState.die) return;
    
    setAnimation(GalletaPlayerCharacterState.die, onComplete: onAnimationComplete);
    _currentState = GalletaPlayerCharacterState.die;
  }

  void jump() {
    if (_currentState == GalletaPlayerCharacterState.die) return;
    if (_currentState == GalletaPlayerCharacterState.jump) return;

    _currentState = GalletaPlayerCharacterState.jump;
    LaraAudio.playSfx(LaraSfx.jump);
    setAnimation(GalletaPlayerCharacterState.jump);

    const jumpHeight = 120.0;
    const duration = 0.4;

    add(
      SequenceEffect(
        [
          MoveByEffect(Vector2(0, -jumpHeight), EffectController(duration: duration, curve: Curves.easeOutQuad)),

          MoveByEffect(Vector2(0, jumpHeight), EffectController(duration: duration, curve: Curves.easeInQuad)),
        ],
        onComplete: () {
          if (_currentState == GalletaPlayerCharacterState.jump) {
            _currentState = GalletaPlayerCharacterState.run;
            setAnimation(GalletaPlayerCharacterState.run);
          }
        },
      ),
    );
  }
}
