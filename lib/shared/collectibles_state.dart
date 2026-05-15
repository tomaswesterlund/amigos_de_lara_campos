import 'coin_wallet.dart';

class CollectiblesState {
  CollectiblesState._();

  static const int count = 5;

  /// Cost in coins for each unlock level (index 0–4). Index 0 is always free.
  static const List<int> costs = [0, 25, 50, 75, 100];

  static final Map<String, Set<int>> _unlocked = {
    'rhenne': {0},
    'galleta': {0},
    'heart': {0},
  };

  static bool isUnlocked(String charKey, int index) =>
      _unlocked[charKey]?.contains(index) ?? false;

  /// Attempts to spend coins and unlock the card. Returns true on success.
  static bool unlock(String charKey, int index) {
    if (index < 0 || index >= costs.length) return false;
    if (isUnlocked(charKey, index)) return false;
    if (!CoinWallet.spend(costs[index])) return false;
    _unlocked[charKey]!.add(index);
    return true;
  }
}
