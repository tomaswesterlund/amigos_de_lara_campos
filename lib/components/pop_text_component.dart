import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:lara_demo/components/coin_component.dart';

class PopTextComponent extends PositionComponent {
  final bool showCoin;
  final String label;

  PopTextComponent({required this.showCoin, required this.label, required Vector2 startPosition})
    : super(
        position: startPosition,
        anchor: Anchor.center,
        // Increased width to 180 to comfortably fit a 60px coin + text padding
        size: Vector2(180, 60),
      );

  // Define our text painter at class level so we don't recreate it every frame
  late final TextPaint _textPaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFFD640),
        shadows: [Shadow(offset: Offset(0, 2), color: Color(0xFF8B5E3C))],
      ),
    );

    // 1. Safe Layout Arrangement
    if (showCoin) {
      final coin = CoinComponent(size: Vector2(44, 44));
      // Anchor the coin to its left center so it stays on the left edge
      coin.anchor = Anchor.centerLeft;
      coin.position = Vector2(0, size.y / 2);
      await add(coin);
    }

    // 2. Add Animations safely here
    add(
      SequenceEffect([
        MoveByEffect(Vector2(0, -65), EffectController(duration: 0.55, curve: Curves.easeOut)),
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.15, curve: Curves.easeIn)),
      ], onComplete: removeFromParent),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Keeps the component engine rendering chain healthy

    // Dynamic horizontal offset depending on whether the coin is taking up space
    double textXOffset = showCoin ? 54.0 : 10.0;

    // Centers the text vertically inside the 60px height container
    double textYOffset = (size.y - _textPaint.style.fontSize!) / 2;

    _textPaint.render(canvas, label, Vector2(textXOffset, textYOffset));
  }
}
