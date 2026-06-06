import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:lara_demo/core/constants.dart';

class LilypadComponent extends PositionComponent {
  LilypadComponent({required Vector2 size, super.key}) : super(size: size, anchor: Anchor.center);

  late final SpineComponent _spine;

  @override
  Future onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/lilypad/lilypad.atlas',
      skeletonFile: 'assets/sprites/lilypad/lilypad.json',
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
        position: size / 2, // + Vector2(0, size.y * 0.1),
      ),
    );

    
  }

  void startRippleAnimation() {
    _spine.animationState.setAnimation(0, 'animation', false);
  }
}
