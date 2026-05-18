import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/shared/coin_wallet.dart';

void main() {
  setUp(() => CoinWallet.balance.value = 100);

  test('initial balance is 100', () {
    expect(CoinWallet.balance.value, 100);
  });

  test('add increases balance by the given amount', () {
    CoinWallet.add(50);
    expect(CoinWallet.balance.value, 150);
  });

  test('spend returns true and deducts when balance is sufficient', () {
    final result = CoinWallet.spend(40);
    expect(result, isTrue);
    expect(CoinWallet.balance.value, 60);
  });

  test('spend returns false and leaves balance unchanged when insufficient', () {
    final result = CoinWallet.spend(200);
    expect(result, isFalse);
    expect(CoinWallet.balance.value, 100);
  });

  test('spend exact balance succeeds and leaves 0', () {
    final result = CoinWallet.spend(100);
    expect(result, isTrue);
    expect(CoinWallet.balance.value, 0);
  });

  test('sequential add then spend preserves correct total', () {
    CoinWallet.add(400);
    CoinWallet.spend(250);
    expect(CoinWallet.balance.value, 250);
  });

  test('spend(0) always succeeds without changing balance', () {
    final result = CoinWallet.spend(0);
    expect(result, isTrue);
    expect(CoinWallet.balance.value, 100);
  });

  test('balance notifier updates listeners on change', () {
    int notified = 0;
    CoinWallet.balance.addListener(() => notified++);
    CoinWallet.add(10);
    expect(notified, 1);
    CoinWallet.balance.removeListener(() {});
  });
}
