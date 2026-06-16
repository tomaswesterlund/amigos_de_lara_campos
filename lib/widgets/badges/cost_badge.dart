import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_theme.dart';

class CostBadge extends StatelessWidget {
  const CostBadge({super.key, required this.cost});

  final int cost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: LaraColors.yellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LaraColors.galletaBrown, width: 1.5),
        boxShadow: const [BoxShadow(offset: Offset(0, 2), blurRadius: 0, color: LaraColors.galletaBrown)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: LaraColors.cream.withValues(alpha: 0.9),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 0,
                  color: LaraColors.galletaBrown,
                ),
              ],
            ),
            child: Image.asset('assets/images/coin_asset.png'),
          ),
          const SizedBox(width: 6),
          Text(
            '$cost',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: LaraColors.galletaBrown),
          ),
        ],
      ),
    );
  }
}