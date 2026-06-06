import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_theme.dart';

class PointsOverlay extends StatelessWidget {
  const PointsOverlay({super.key, required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: LaraColors.magenta.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$label: ', style: LaraTextStyles.hudScore),
                Text('$score', style: LaraTextStyles.hudScore),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
