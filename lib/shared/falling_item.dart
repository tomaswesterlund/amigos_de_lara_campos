enum LaneFallingItemTypes { acorn, branch, coin, honeycomb, pinecone, redHeart }

class LaneFallingItem {
  final LaneFallingItemTypes type;
  final double spawnTimeInSeconds;
  final int lane;
  bool isProcessed = false;

  bool get isHazard =>
      type == LaneFallingItemTypes.acorn ||
      type == LaneFallingItemTypes.branch ||
      type == LaneFallingItemTypes.honeycomb ||
      type == LaneFallingItemTypes.pinecone;

  LaneFallingItem({required this.type, required this.spawnTimeInSeconds, required this.lane});
}
