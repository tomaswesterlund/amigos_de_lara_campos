import 'package:flutter/foundation.dart' show visibleForTesting;

class QrUnlockState {
  QrUnlockState._();

  @visibleForTesting
  static void resetForTest() => _unlocked.clear();

  static const int count = 3;

  static final Set<int> _unlocked = {};

  static bool isUnlocked(int index) => _unlocked.contains(index);

  static void unlock(int index) => _unlocked.add(index);
}
