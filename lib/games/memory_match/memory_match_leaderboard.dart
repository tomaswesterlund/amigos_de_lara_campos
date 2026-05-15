/// In-memory leaderboard for Memoria Amigos. Lower move counts are better.
/// Seeded with dummy entries so "Lupita" has someone to beat from the very
/// first game. Resets when the app process restarts — persistence is
/// intentionally out of scope for the demo.
class MemoryMatchEntry {
  const MemoryMatchEntry({
    required this.name,
    required this.moves,
    this.isCurrentPlayer = false,
  });

  final String name;
  final int moves;
  final bool isCurrentPlayer;
}

class MemoryMatchLeaderboard {
  MemoryMatchLeaderboard._();

  static const currentPlayerName = 'Lupita';

  static final List<MemoryMatchEntry> _entries = [
    const MemoryMatchEntry(name: 'Sofía', moves: 8),
    const MemoryMatchEntry(name: 'Camila', moves: 11),
    const MemoryMatchEntry(name: 'Valentina', moves: 14),
    const MemoryMatchEntry(name: 'Isabella', moves: 18),
    const MemoryMatchEntry(name: 'Daniela', moves: 22),
  ];

  static MemoryMatchEntry? _latest;
  static MemoryMatchEntry? get latest => _latest;

  /// Entries sorted by moves ascending — fewest moves = rank 1.
  static List<MemoryMatchEntry> get topEntries {
    final sorted = [..._entries]..sort((a, b) => a.moves.compareTo(b.moves));
    return List.unmodifiable(sorted);
  }

  /// Returns the 1-based rank of [entry] within the current leaderboard.
  static int rankOf(MemoryMatchEntry entry) {
    final sorted = topEntries;
    final idx = sorted.indexOf(entry);
    return idx < 0 ? sorted.length + 1 : idx + 1;
  }

  /// Records a completed game. Returns the entry so the caller can highlight it.
  static MemoryMatchEntry submit(int moves) {
    final entry = MemoryMatchEntry(
      name: currentPlayerName,
      moves: moves,
      isCurrentPlayer: true,
    );
    _entries.add(entry);
    _latest = entry;
    return entry;
  }
}
