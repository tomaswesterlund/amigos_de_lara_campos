import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_theme.dart';
import 'package:lara_demo/widgets/buttons/mute_button.dart';
import 'package:lara_demo/widgets/coin_shop.dart';
import 'package:lara_demo/widgets/coin_wallet.dart';

class CoinDisplay extends StatelessWidget {
  const CoinDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => showCoinShop(context),
            child: ValueListenableBuilder<int>(
              valueListenable: CoinWallet.balance,
              builder: (context, balance, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: LaraColors.yellow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: LaraColors.galletaBrown, width: 2),
                  boxShadow: const [BoxShadow(offset: Offset(0, 3), blurRadius: 0, color: LaraColors.galletaBrown)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Icon(Icons.monetization_on_rounded, color: LaraColors.galletaBrown, size: 22),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: LaraColors.cream.withValues(alpha: 0.9), blurRadius: 6, spreadRadius: 1),
                          const BoxShadow(offset: Offset(0, 1), blurRadius: 0, color: LaraColors.galletaBrown),
                        ],
                      ),
                      child: Image.asset('assets/images/coin_asset.png'),
                    ),

                    const SizedBox(width: 6),
                    Text(
                      '$balance',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: LaraColors.galletaBrown),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.add_circle_rounded, color: LaraColors.galletaBrown, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const MuteButton(),
        ],
      ),
    );
  }
}
