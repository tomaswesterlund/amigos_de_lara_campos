import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/shared/coin_wallet.dart';
import 'package:lara_demo/shared/collectibles_state.dart';

void main() {
  setUp(() {
    CoinWallet.balance.value = 500;
    CollectiblesState.resetForTest();
  });

  group('initial state', () {
    test('index 0 is pre-unlocked for all characters', () {
      expect(CollectiblesState.isUnlocked('rhenne', 0), isTrue);
      expect(CollectiblesState.isUnlocked('galleta', 0), isTrue);
      expect(CollectiblesState.isUnlocked('heart', 0), isTrue);
    });

    test('indices 1–4 start locked for all characters', () {
      for (final char in ['rhenne', 'galleta', 'heart']) {
        for (var i = 1; i < CollectiblesState.count; i++) {
          expect(CollectiblesState.isUnlocked(char, i), isFalse, reason: '$char[$i] should be locked');
        }
      }
    });

    test('count is 5', () {
      expect(CollectiblesState.count, 5);
    });

    test('costs length matches count', () {
      expect(CollectiblesState.costs.length, CollectiblesState.count);
    });

    test('first cost is 0 (always free)', () {
      expect(CollectiblesState.costs[0], 0);
    });
  });

  group('unlock', () {
    test('unlock index 1 with sufficient coins succeeds', () {
      final result = CollectiblesState.unlock('rhenne', 1);
      expect(result, isTrue);
      expect(CollectiblesState.isUnlocked('rhenne', 1), isTrue);
    });

    test('unlock deducts the correct tiered cost', () {
      // costs = [0, 25, 50, 75, 100]
      CollectiblesState.unlock('rhenne', 1); // costs 25
      expect(CoinWallet.balance.value, 475);
      CollectiblesState.unlock('rhenne', 2); // costs 50
      expect(CoinWallet.balance.value, 425);
    });

    test('unlock fails when wallet has insufficient coins', () {
      CoinWallet.balance.value = 10;
      final result = CollectiblesState.unlock('galleta', 1); // costs 25
      expect(result, isFalse);
      expect(CollectiblesState.isUnlocked('galleta', 1), isFalse);
      expect(CoinWallet.balance.value, 10);
    });

    test('unlock already-unlocked index returns false, no coins charged', () {
      final before = CoinWallet.balance.value;
      final result = CollectiblesState.unlock('rhenne', 0); // pre-unlocked
      expect(result, isFalse);
      expect(CoinWallet.balance.value, before);
    });

    test('out-of-bounds index returns false', () {
      expect(CollectiblesState.unlock('rhenne', -1), isFalse);
      expect(CollectiblesState.unlock('rhenne', CollectiblesState.count), isFalse);
    });

    test('unknown character key returns false', () {
      expect(CollectiblesState.unlock('unknown_char', 1), isFalse);
    });

    test('unlocking one character does not affect another', () {
      CollectiblesState.unlock('rhenne', 1);
      expect(CollectiblesState.isUnlocked('galleta', 1), isFalse);
    });
  });
}
