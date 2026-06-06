import 'package:flutter/foundation.dart';

class CoinWallet {
  CoinWallet._();

  static final ValueNotifier<int> balance = ValueNotifier<int>(100);

  static void add(int amount) => balance.value += amount;

  static bool spend(int amount) {
    if (balance.value < amount) return false;
    balance.value -= amount;
    return true;
  }
}
