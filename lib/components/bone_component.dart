import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:lara_demo/core/constants.dart';

class BoneComponent extends PositionComponent {
  BoneComponent({required Vector2 size, super.position, super.key}) : super(size: size, anchor: Anchor.center);

  late final SpineComponent _spine;

  @override
  Future onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/bone/bone.atlas',
      skeletonFile: 'assets/sprites/bone/bone.json',
      anchor: Anchor.center,
      position: size / 2,
    );

    _spine.scale = Vector2.all(size.x / _spine.size.x);

    await add(_spine);

    await add(CircleHitbox(radius: size.y / 4, anchor: Anchor.center, position: size / 2 + Vector2(0, size.y * 0.1)));

    _spine.animationState.setAnimation(0, 'animation', true);
  }

  void move(Vector2 targetPosition, double duration) {
    add(
      MoveByEffect(
        targetPosition,
        EffectController(duration: duration),
        onComplete: () {
          removeFromParent();
        },
      ),
    );
  }
}
