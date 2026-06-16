import 'package:flutter/foundation.dart' show visibleForTesting;

import 'coin_wallet.dart';

class CollectiblesState {
  CollectiblesState._();

  @visibleForTesting
  static void resetForTest() {
    _unlocked
      ..clear()
      ..addAll({
        'rhenne': {0},
        'galleta': {0},
        'heart': {0},
      });
    _unlockOrder
      ..clear()
      ..addAll([
        (char: 'rhenne', index: 0),
        (char: 'galleta', index: 0),
        (char: 'heart', index: 0),
      ]);
  }

  static const int count = 5;

  /// Cost in coins for each unlock level (index 0–4). Index 0 is always free.
  static const List<int> costs = [0, 25, 50, 75, 100];

  static final Map<String, Set<int>> _unlocked = {
    'rhenne': {0},
    'galleta': {0},
    'heart': {0},
  };

  // Insertion-ordered list: oldest first. Default items seeded in a stable order.
  static final _unlockOrder = <({String char, int index})>[
    (char: 'rhenne', index: 0),
    (char: 'galleta', index: 0),
    (char: 'heart', index: 0),
  ];

  static bool isUnlocked(String charKey, int index) =>
      _unlocked[charKey]?.contains(index) ?? false;

  /// All unlocked items in unlock order, oldest first.
  /// Reverse to get newest-first display order.
  static List<({String char, int index})> unlockedInOrder() =>
      List.unmodifiable(_unlockOrder);

  /// Attempts to spend coins and unlock the card. Returns true on success.
  static bool unlock(String charKey, int index) {
    if (!_unlocked.containsKey(charKey)) return false;
    if (index < 0 || index >= costs.length) return false;
    if (isUnlocked(charKey, index)) return false;
    if (!CoinWallet.spend(costs[index])) return false;
    _unlocked[charKey]!.add(index);
    _unlockOrder.add((char: charKey, index: index));
    return true;
  }
}
