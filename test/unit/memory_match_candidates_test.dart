/// Regression tests for the _candidateNames() duplicate-pair bug.
///
/// When collectible level-0 sprites (e.g. rhenne_l1.png) are in the pool their
/// base fallback (rhenne.png) must be excluded to prevent two visually-identical
/// pairs from appearing on the board.
///
/// These tests exercise the logic via CollectiblesState + QrUnlockState directly
/// rather than through the Flame game (no FlameTest needed).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/shared/collectibles_state.dart';
import 'package:lara_demo/shared/coin_wallet.dart';
import 'package:lara_demo/shared/qr_unlock_state.dart';

// Mirror the candidate-building logic so we can test it in isolation.
// If _candidateNames() in memory_match_game.dart changes, update this mirror.
const _fallbacks = [
  'rhenne.png', 'reina.png', 'galleta.png',
  'corazon.png', 'music_note.png', 'lara.png',
];

List<String> _candidateNames() {
  final pool = <String>[];
  final excludeFallbacks = <String>{};
  for (var i = 0; i < CollectiblesState.count; i++) {
    if (CollectiblesState.isUnlocked('rhenne', i)) {
      pool.add('rhenne_l${i + 1}.png');
      excludeFallbacks.add('rhenne.png');
    }
    if (CollectiblesState.isUnlocked('galleta', i)) {
      pool.add('galleta_l${i + 1}.png');
      excludeFallbacks.add('galleta.png');
    }
    if (CollectiblesState.isUnlocked('heart', i)) {
      pool.add('corazon_l${i + 1}.png');
      excludeFallbacks.add('corazon.png');
    }
  }
  for (var i = 0; i < QrUnlockState.count; i++) {
    if (QrUnlockState.isUnlocked(i)) {
      pool.add('lara_d${i + 1}.png');
      excludeFallbacks.add('lara.png');
    }
  }
  for (final f in _fallbacks) {
    if (!excludeFallbacks.contains(f) && !pool.contains(f)) pool.add(f);
  }
  return pool;
}

void main() {
  setUp(() {
    CoinWallet.balance.value = 1000;
    CollectiblesState.resetForTest();
    QrUnlockState.resetForTest();
  });

  test('pool has no duplicate filenames', () {
    final pool = _candidateNames();
    expect(pool.toSet().length, pool.length, reason: 'duplicate filename found in pool');
  });

  test('pool has at least 6 entries (enough for 1 game)', () {
    expect(_candidateNames().length, greaterThanOrEqualTo(6));
  });

  test('rhenne_l1.png and rhenne.png do not both appear (default unlock state)', () {
    final pool = _candidateNames();
    final hasL1 = pool.contains('rhenne_l1.png');
    final hasBase = pool.contains('rhenne.png');
    expect(hasL1 && hasBase, isFalse,
        reason: 'rhenne_l1.png and rhenne.png must not coexist — they are visually identical');
  });

  test('galleta_l1.png and galleta.png do not both appear', () {
    final pool = _candidateNames();
    expect(pool.contains('galleta_l1.png') && pool.contains('galleta.png'), isFalse);
  });

  test('corazon_l1.png and corazon.png do not both appear', () {
    final pool = _candidateNames();
    expect(pool.contains('corazon_l1.png') && pool.contains('corazon.png'), isFalse);
  });

  test('when QR index 0 is unlocked, lara.png fallback is excluded', () {
    QrUnlockState.unlock(0);
    final pool = _candidateNames();
    expect(pool.contains('lara_d1.png'), isTrue);
    expect(pool.contains('lara.png'), isFalse);
  });

  test('fallbacks reina.png and music_note.png are always included (no collectible replaces them)', () {
    final pool = _candidateNames();
    expect(pool, contains('reina.png'));
    expect(pool, contains('music_note.png'));
  });

  test('unlocking additional collectible levels adds more candidates', () {
    final baseCount = _candidateNames().length;
    CoinWallet.balance.value = 1000;
    CollectiblesState.unlock('rhenne', 1); // adds rhenne_l2.png
    final newCount = _candidateNames().length;
    expect(newCount, greaterThan(baseCount));
  });
}
