import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/shared/qr_unlock_state.dart';

void main() {
  setUp(() => QrUnlockState.resetForTest());

  test('all indices start locked', () {
    for (var i = 0; i < QrUnlockState.count; i++) {
      expect(QrUnlockState.isUnlocked(i), isFalse, reason: 'index $i should start locked');
    }
  });

  test('count is 3', () {
    expect(QrUnlockState.count, 3);
  });

  test('unlock(i) marks only that index as unlocked', () {
    QrUnlockState.unlock(1);
    expect(QrUnlockState.isUnlocked(0), isFalse);
    expect(QrUnlockState.isUnlocked(1), isTrue);
    expect(QrUnlockState.isUnlocked(2), isFalse);
  });

  test('unlock same index twice is idempotent', () {
    QrUnlockState.unlock(0);
    QrUnlockState.unlock(0);
    expect(QrUnlockState.isUnlocked(0), isTrue);
  });

  test('can unlock all indices independently', () {
    for (var i = 0; i < QrUnlockState.count; i++) {
      QrUnlockState.unlock(i);
    }
    for (var i = 0; i < QrUnlockState.count; i++) {
      expect(QrUnlockState.isUnlocked(i), isTrue);
    }
  });

  test('out-of-range index is not unlocked', () {
    expect(QrUnlockState.isUnlocked(99), isFalse);
  });
}
