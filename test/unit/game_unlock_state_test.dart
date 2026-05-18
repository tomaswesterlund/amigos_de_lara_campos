import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/shared/coin_wallet.dart';
import 'package:lara_demo/shared/game_unlock_state.dart';

void main() {
  setUp(() {
    CoinWallet.balance.value = 1000;
    GameUnlockState.resetForTest();
  });

  test('unknown game key is always locked', () {
    expect(GameUnlockState.isUnlocked('nonexistent_game'), isFalse);
  });

  test('memory_match starts locked', () {
    expect(GameUnlockState.isUnlocked('memory_match'), isFalse);
  });

  test('unlock memory_match deducts 500 coins and returns true', () {
    final result = GameUnlockState.unlock('memory_match');
    expect(result, isTrue);
    expect(CoinWallet.balance.value, 500);
  });

  test('after unlock, isUnlocked returns true', () {
    GameUnlockState.unlock('memory_match');
    expect(GameUnlockState.isUnlocked('memory_match'), isTrue);
  });

  test('unlock with unknown key returns false, no coins spent', () {
    final before = CoinWallet.balance.value;
    final result = GameUnlockState.unlock('ghost_game');
    expect(result, isFalse);
    expect(CoinWallet.balance.value, before);
  });

  test('unlock fails when wallet has insufficient coins', () {
    CoinWallet.balance.value = 100;
    final result = GameUnlockState.unlock('memory_match');
    expect(result, isFalse);
    expect(GameUnlockState.isUnlocked('memory_match'), isFalse);
    expect(CoinWallet.balance.value, 100);
  });

  test('unlock already-unlocked game returns false and does not re-charge', () {
    GameUnlockState.unlock('memory_match');
    final balanceAfterFirst = CoinWallet.balance.value;
    final result = GameUnlockState.unlock('memory_match');
    expect(result, isFalse);
    expect(CoinWallet.balance.value, balanceAfterFirst);
  });
}
