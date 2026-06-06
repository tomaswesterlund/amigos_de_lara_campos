import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_theme.dart'; // Keeping your theme imports

class PointsComponent extends PositionComponent with HasGameReference {
  PointsComponent({required this.label, required this.score, super.position}) : super(anchor: Anchor.center);

  String label;
  int score;

  late TextComponent _textComponent;
  final _backgroundPaint = Paint()
    ..color = LaraColors.magenta.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;

  final _borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  Future<void> onLoad() async {
    // 1. Create the text component using your existing text style
    _textComponent = TextComponent(
      text: '$label: $score',
      textRenderer: TextPaint(style: LaraTextStyles.hudScore),
      anchor: Anchor.center,
    );

    // 2. Add it as a child so Flame handles its lifecycle
    add(_textComponent);

    // 3. Size this component based on the text + your original padding
    // Horizontal padding: 18 * 2 = 36. Vertical padding: 8 * 2 = 16.
    size = Vector2(_textComponent.width + 36, _textComponent.height + 16);

    // Position the text exactly in the center of this container
    _textComponent.position = size / 2;

    // Default alignment: topCenter with a 12px margin from the top
    // position = Vector2(gameRef.size.x / 2 - size.x / 2, 12);
  }

  // Reactive update method to change the score on the fly
  void updateScore(int newScore) {
    score = newScore;
    _textComponent.text = '$label: $score';

    // Recalculate size in case the digit count changes the width significantly
    size = Vector2(_textComponent.width + 36, _textComponent.height + 16);
    _textComponent.position = size / 2;
    // position.x = gameRef.size.x / 2 - size.x / 2;
  }

  @override
  void render(Canvas canvas) {
    // Replicating BoxDecoration(borderRadius: BorderRadius.circular(24))
    final rrect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(24));

    // Draw background and border
    canvas.drawRRect(rrect, _backgroundPaint);
    canvas.drawRRect(rrect, _borderPaint);

    super.render(canvas);
  }
}
