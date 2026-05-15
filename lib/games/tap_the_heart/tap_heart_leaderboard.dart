/// In-memory leaderboard for Atrapa Corazones. Higher score = better.
/// Seeded with dummy entries so "Lupita" has someone to beat from the
/// very first game. Resets when the app restarts — persistence is
/// intentionally out of scope for the demo.
class TapHeartEntry {
  const TapHeartEntry({
    required this.name,
    required this.score,
    this.isCurrentPlayer = false,
  });

  final String name;
  final int score;
  final bool isCurrentPlayer;
}

class TapHeartLeaderboard {
  TapHeartLeaderboard._();

  static const currentPlayerName = 'Lupita';

  static final List<TapHeartEntry> _entries = [
    const TapHeartEntry(name: 'Sofía', score: 38),
    const TapHeartEntry(name: 'Camila', score: 29),
    const TapHeartEntry(name: 'Valentina', score: 21),
    const TapHeartEntry(name: 'Isabella', score: 14),
    const TapHeartEntry(name: 'Daniela', score: 8),
  ];

  static TapHeartEntry? _latest;
  static TapHeartEntry? get latest => _latest;

  /// Entries sorted by score descending — highest score = rank 1.
  static List<TapHeartEntry> get topEntries {
    final sorted = [..._entries]..sort((a, b) => b.score.compareTo(a.score));
    return List.unmodifiable(sorted);
  }

  /// Returns the 1-based rank of [entry] within the current leaderboard.
  static int rankOf(TapHeartEntry entry) {
    final sorted = topEntries;
    final idx = sorted.indexOf(entry);
    return idx < 0 ? sorted.length + 1 : idx + 1;
  }

  /// Records a completed game. Returns the entry so the caller can highlight it.
  static TapHeartEntry submit(int score) {
    final entry = TapHeartEntry(
      name: currentPlayerName,
      score: score,
      isCurrentPlayer: true,
    );
    _entries.add(entry);
    _latest = entry;
    return entry;
  }
}
