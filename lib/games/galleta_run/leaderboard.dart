/// In-memory leaderboard for Galleta Corre. Seeded with dummy entries so the
/// player ("Lupita") has someone to beat from the very first run. Scores
/// reset when the app process restarts — persistence is intentionally
/// out of scope for the demo.
class GalletaRunEntry {
  const GalletaRunEntry({
    required this.name,
    required this.score,
    this.isCurrentPlayer = false,
  });

  final String name;
  final int score;
  final bool isCurrentPlayer;
}

class GalletaRunLeaderboard {
  GalletaRunLeaderboard._();

  static const currentPlayerName = 'Lupita';

  static final List<GalletaRunEntry> _entries = [
    const GalletaRunEntry(name: 'Sofía', score: 38),
    const GalletaRunEntry(name: 'Camila', score: 27),
    const GalletaRunEntry(name: 'Mateo', score: 19),
    const GalletaRunEntry(name: 'Valentina', score: 12),
    const GalletaRunEntry(name: 'Diego', score: 7),
  ];

  static GalletaRunEntry? _latest;
  static GalletaRunEntry? get latest => _latest;

  static List<GalletaRunEntry> get topEntries {
    final sorted = [..._entries]..sort((a, b) => b.score.compareTo(a.score));
    return List.unmodifiable(sorted);
  }

  /// Returns the 1-based rank of [entry] in the current leaderboard.
  static int rankOf(GalletaRunEntry entry) {
    final sorted = topEntries;
    final idx = sorted.indexOf(entry);
    return idx < 0 ? sorted.length + 1 : idx + 1;
  }

  /// Records a score for the current player and returns the created entry.
  static GalletaRunEntry submit(int score) {
    final entry = GalletaRunEntry(
      name: currentPlayerName,
      score: score,
      isCurrentPlayer: true,
    );
    _entries.add(entry);
    _latest = entry;
    return entry;
  }
}
