import 'package:flame/components.dart';

import '../rhythm_tap_game.dart';

class BeatNote extends SpriteComponent with HasGameReference<RhythmTapGame> {
  BeatNote({
    required this.lane,
    required this.chartTime,
    required Sprite sprite,
    required this.speed,
  }) : super(sprite: sprite);

  final int lane;

  /// The audio timestamp (seconds) at which this note should be hit.
  /// Used for time-based hit-window evaluation.
  final double chartTime;

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
