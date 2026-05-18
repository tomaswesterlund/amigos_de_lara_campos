/// In-memory leaderboard for Rhenné Corre. Seeded with dummy entries so the
/// player ("Lupita") has someone to beat from the very first run. Scores
/// reset when the app process restarts — persistence is intentionally
/// out of scope for the demo.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.score,
    this.isCurrentPlayer = false,
  });

  final String name;
  final int score;
  final bool isCurrentPlayer;
}

class RhenneRunLeaderboard {
  RhenneRunLeaderboard._();

  // ignore: invalid_use_of_visible_for_testing_member
  static void resetForTest() {
    _entries
      ..clear()
      ..addAll([
        const LeaderboardEntry(name: 'Sofía', score: 142),
        const LeaderboardEntry(name: 'Camila', score: 118),
        const LeaderboardEntry(name: 'Mateo', score: 95),
        const LeaderboardEntry(name: 'Valentina', score: 76),
        const LeaderboardEntry(name: 'Diego', score: 54),
      ]);
    _latest = null;
  }

  static const currentPlayerName = 'Lupita';

  static final List<LeaderboardEntry> _entries = [
    const LeaderboardEntry(name: 'Sofía', score: 142),
    const LeaderboardEntry(name: 'Camila', score: 118),
    const LeaderboardEntry(name: 'Mateo', score: 95),
    const LeaderboardEntry(name: 'Valentina', score: 76),
    const LeaderboardEntry(name: 'Diego', score: 54),
  ];

  /// Most recent entry submitted via [submit]. Used by the overlay to
  /// visually mark "this just-played run" even when the same name appears
  /// multiple times.
  static LeaderboardEntry? _latest;
  static LeaderboardEntry? get latest => _latest;

  static List<LeaderboardEntry> get topEntries {
    final sorted = [..._entries]..sort((a, b) => b.score.compareTo(a.score));
    return List.unmodifiable(sorted);
  }

  /// Returns the 1-based rank of [entry] within the current leaderboard.
  static int rankOf(LeaderboardEntry entry) {
    final sorted = topEntries;
    final idx = sorted.indexOf(entry);
    return idx < 0 ? sorted.length + 1 : idx + 1;
  }

  /// Adds a score for the current player. Returns the entry that was created
  /// so the caller can highlight it in the UI.
  static LeaderboardEntry submit(int score) {
    final entry = LeaderboardEntry(
      name: currentPlayerName,
      score: score,
      isCurrentPlayer: true,
    );
    _entries.add(entry);
    _latest = entry;
    return entry;
  }
}
