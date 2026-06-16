import 'package:flutter/material.dart';

class CountdownBadge extends StatelessWidget {
  const CountdownBadge({super.key, required this.countdown});

  final String countdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white38, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            countdown,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
