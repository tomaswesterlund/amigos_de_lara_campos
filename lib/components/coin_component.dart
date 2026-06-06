import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:lara_demo/core/constants.dart';

class CoinComponent extends PositionComponent {
  CoinComponent({required super.size}) : super(anchor: Anchor.center);

  late final SpineComponent _spine;

  @override
  Future onLoad() async {
    super.onLoad();

    debugMode = Constants.DEBUG;

    _spine = await SpineComponent.fromAssets(
      atlasFile: 'assets/sprites/coin/coin.atlas',
      skeletonFile: 'assets/sprites/coin/coin.json',
      anchor: Anchor.center,
      position: size / 2,
    );

    _spine.scale = Vector2(size.x / _spine.size.x, size.y / _spine.size.y);

    await add(
      RectangleHitbox.relative(
        Vector2(0.7, 1.0),
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

    await add(_spine);

    startAnimation();
  }

  void startAnimation() {
    _spine.animationState.setAnimation(0, 'animation', true);
  }

  @override
  void onMount() {}
}
