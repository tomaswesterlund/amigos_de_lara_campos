enum FallingLaneItemTypes { acorn, bird, bone, branch, coin, honeycomb, pause, pinecone, redHeart, rock }

class FallingLaneItem {
  final FallingLaneItemTypes type;
  final double spawnTimeInSeconds;
  final int lane;
  bool isProcessed = false;

  bool get isHazard =>
      type == FallingLaneItemTypes.acorn ||
      type == FallingLaneItemTypes.branch ||
      type == FallingLaneItemTypes.honeycomb ||
      type == FallingLaneItemTypes.pinecone;

  FallingLaneItem({required this.type, required this.spawnTimeInSeconds, required this.lane});
}
