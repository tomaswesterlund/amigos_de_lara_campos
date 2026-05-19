import 'dart:math';

import 'package:flutter/material.dart';

/// Draws a gold coin matching the daily-bonus modal style onto [canvas].
/// [w] and [h] are the bounding box dimensions; the coin is centred within them.
void drawCoin(Canvas canvas, double w, double h) {
  final r = min(w, h) / 2 * 0.88;
  final cx = w / 2;
  final cy = h / 2;
  // Drop shadow
  canvas.drawCircle(
    Offset(cx + 1, cy + 3),
    r,
    Paint()..color = const Color(0xFF8B5E3C).withValues(alpha: 0.35),
  );
  // Outer golden ring
  canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFFFD640));
  // Middle ring (darker gold)
  canvas.drawCircle(Offset(cx, cy), r * 0.76, Paint()..color = const Color(0xFFE9A800));
  // Inner bright circle
  canvas.drawCircle(Offset(cx, cy), r * 0.56, Paint()..color = const Color(0xFFFFD640));
  // Shine highlight arc (top-left)
  canvas.drawArc(
    Rect.fromCircle(center: Offset(cx - r * 0.16, cy - r * 0.2), radius: r * 0.3),
    -2.3,
    1.9,
    false,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke,
  );
}
