import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/games/rhenne_run/leaderboard.dart';

void main() {
  setUp(() => RhenneRunLeaderboard.resetForTest());

  test('topEntries are sorted descending by score', () {
    final entries = RhenneRunLeaderboard.topEntries;
    for (var i = 0; i < entries.length - 1; i++) {
      expect(entries[i].score >= entries[i + 1].score, isTrue);
    }
  });

  test('rankOf returns 1 for the highest score', () {
    final top = RhenneRunLeaderboard.topEntries.first;
    expect(RhenneRunLeaderboard.rankOf(top), 1);
  });

  test('rankOf returns length+1 for an entry not in the board', () {
    final ghost = const LeaderboardEntry(name: 'Ghost', score: 0);
    expect(RhenneRunLeaderboard.rankOf(ghost), RhenneRunLeaderboard.topEntries.length + 1);
  });

  test('submit creates entry marked as current player', () {
    final entry = RhenneRunLeaderboard.submit(200);
    expect(entry.isCurrentPlayer, isTrue);
    expect(entry.name, RhenneRunLeaderboard.currentPlayerName);
    expect(entry.score, 200);
  });

  test('submit stores entry as latest', () {
    final entry = RhenneRunLeaderboard.submit(50);
    expect(RhenneRunLeaderboard.latest, same(entry));
  });

  test('new top score ranks at position 1', () {
    final entry = RhenneRunLeaderboard.submit(9999);
    expect(RhenneRunLeaderboard.rankOf(entry), 1);
  });

  test('low score ranks at or near the bottom', () {
    final entry = RhenneRunLeaderboard.submit(0);
    final rank = RhenneRunLeaderboard.rankOf(entry);
    expect(rank, greaterThan(1));
  });

  test('topEntries contains submitted entry', () {
    final entry = RhenneRunLeaderboard.submit(100);
    expect(RhenneRunLeaderboard.topEntries, contains(entry));
  });

  test('seeded entries have the correct scores', () {
    final entries = RhenneRunLeaderboard.topEntries;
    final scores = entries.map((e) => e.score).toList();
    expect(scores, containsAll([142, 118, 95, 76, 54]));
  });
}
