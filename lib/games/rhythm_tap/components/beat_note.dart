import 'package:flame/components.dart';

import '../rhythm_tap_game.dart';

class BeatNote extends SpriteComponent with HasGameReference<RhythmTapGame> {
  BeatNote({
    required this.lane,
    required Sprite sprite,
    required this.speed,
  }) : super(sprite: sprite);

  final int lane;
  final double speed;
  bool consumed = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (consumed) return;
    position.y += speed * dt;
    if (position.y > game.size.y + 40) {
      consumed = true;
      game.onNoteMissed(this);
      removeFromParent();
    }
  }
}
