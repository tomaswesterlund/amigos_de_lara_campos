import 'package:flutter/foundation.dart' show visibleForTesting;

import '../widgets/coin_wallet.dart';

class GameUnlockState {
  GameUnlockState._();

  @visibleForTesting
  static void resetForTest() => _unlocked.clear();

  static const Map<String, int> costs = {
    'memory_match': 500,
  };

  static final Set<String> _unlocked = {};

  static bool isUnlocked(String gameKey) => _unlocked.contains(gameKey);

  /// Spends coins and unlocks the game. Returns true on success.
  static bool unlock(String gameKey) {
    if (isUnlocked(gameKey)) return false;
    final cost = costs[gameKey];
    if (cost == null) return false;
    if (!CoinWallet.spend(cost)) return false;
    _unlocked.add(gameKey);
    return true;
  }
}
