import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionDispatcher extends Component with CollisionCallbacks {
  final void Function(PositionComponent other) onCollisionStarted;

  CollisionDispatcher({required this.onCollisionStarted});

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    onCollisionStarted(other);
  }
}
