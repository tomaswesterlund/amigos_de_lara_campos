import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/games/memory_match/memory_match_leaderboard.dart';

void main() {
  setUp(() => MemoryMatchLeaderboard.resetForTest());

  test('topEntries are sorted ascending by moves (fewest first)', () {
    final entries = MemoryMatchLeaderboard.topEntries;
    for (var i = 0; i < entries.length - 1; i++) {
      expect(entries[i].moves <= entries[i + 1].moves, isTrue);
    }
  });

  test('rankOf returns 1 for the entry with fewest moves', () {
    final best = MemoryMatchLeaderboard.topEntries.first;
    expect(MemoryMatchLeaderboard.rankOf(best), 1);
  });

  test('rankOf returns length+1 for an entry not in the board', () {
    final ghost = const MemoryMatchEntry(name: 'Ghost', moves: 999);
    expect(MemoryMatchLeaderboard.rankOf(ghost), MemoryMatchLeaderboard.topEntries.length + 1);
  });

  test('submit creates entry marked as current player', () {
    final entry = MemoryMatchLeaderboard.submit(10);
    expect(entry.isCurrentPlayer, isTrue);
    expect(entry.name, MemoryMatchLeaderboard.currentPlayerName);
    expect(entry.moves, 10);
  });

  test('submit stores entry as latest', () {
    final entry = MemoryMatchLeaderboard.submit(12);
    expect(MemoryMatchLeaderboard.latest, same(entry));
  });

  test('new best (fewest moves) ranks at position 1', () {
    final entry = MemoryMatchLeaderboard.submit(1);
    expect(MemoryMatchLeaderboard.rankOf(entry), 1);
  });

  test('high move count ranks near the bottom', () {
    final entry = MemoryMatchLeaderboard.submit(999);
    final rank = MemoryMatchLeaderboard.rankOf(entry);
    expect(rank, greaterThan(1));
  });

  test('topEntries contains submitted entry', () {
    final entry = MemoryMatchLeaderboard.submit(15);
    expect(MemoryMatchLeaderboard.topEntries, contains(entry));
  });

  test('seeded entries contain correct move counts', () {
    final moves = MemoryMatchLeaderboard.topEntries.map((e) => e.moves).toList();
    expect(moves, containsAll([8, 11, 14, 18, 22]));
  });
}
