import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:lara_demo/core/constants.dart';

class BranchComponent extends PositionComponent {
  BranchComponent({required super.size});

  late final SpineComponent _spine;

  @override
  Future onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/branch/branch.atlas',
      skeletonFile: 'assets/sprites/branch/branch.json',
      anchor: Anchor.center,
      position: size / 2,
    );

    anchor = Anchor.center;

    _spine.scale = Vector2(size.x / _spine.size.x, size.y / _spine.size.y);

    await add(CircleHitbox(radius: size.y, anchor: Anchor.center, position: size / 2 + Vector2(0, size.y * 0.1)));

    await add(_spine);

    startAnimation();
  }

  void startAnimation() {
    _spine.animationState.setAnimation(0, 'animation', true);
  }

  @override
  void onMount() {}
}
