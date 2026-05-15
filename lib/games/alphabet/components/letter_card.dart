import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../../shared/lara_theme.dart';
import '../alphabet_game.dart';

/// Big sticker-style card that shows a single letter. Tapping it asks the
/// game to re-speak the current sound.
class LetterCard extends PositionComponent
    with TapCallbacks, HasGameReference<AlphabetGame> {
  LetterCard({required String letter})
      : _letter = letter,
        super(anchor: Anchor.center);

  String _letter;
  late final TextComponent _label;

  @override
  Future<void> onLoad() async {
    _label = TextComponent(
      text: _letter,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 160,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(offset: Offset(0, 6), blurRadius: 0, color: LaraColors.magenta),
          ],
        ),
      ),
    );
    add(_label);
  }

  void setLetter(String letter) {
    if (letter == _letter) return;
    _letter = letter;
    _label.text = letter;
    add(
      ScaleEffect.by(
        Vector2.all(1.08),
        EffectController(
          duration: 0.16,
          alternate: true,
          reverseDuration: 0.16,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _label.position = this.size / 2;
  }

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = LaraColors.pink;
    final rim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(36));
    canvas.drawRRect(rrect, body);
    canvas.drawRRect(rrect.deflate(8), rim);
  }

  @override
  void onTapDown(TapDownEvent event) {
    add(
      ScaleEffect.by(
        Vector2.all(0.94),
        EffectController(
          duration: 0.08,
          alternate: true,
          reverseDuration: 0.08,
        ),
      ),
    );
    game.onLetterTapped();
  }
}
