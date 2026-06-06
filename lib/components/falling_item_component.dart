import 'package:flame/components.dart';

class FallingItemComponent extends PositionComponent {
  bool isProcessed = false;
  final double spawnTimeInSeconds;
  final Vector2 startPosition;
  bool started = false;

  FallingItemComponent({required super.size, required this.spawnTimeInSeconds, required this.startPosition});
}
