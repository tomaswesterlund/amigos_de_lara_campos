import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../../shared/lara_theme.dart';

/// Floating "+N" text that rises and fades after a pickup is collected.
/// Colour and size scale with the point value so golden hearts have an
/// obviously bigger pop than regular ones.
///
/// Implements [OpacityProvider] manually because [TextComponent] does not
/// expose one in Flame 1.37, so [OpacityEffect] would throw at runtime.
class ScorePopup extends PositionComponent implements OpacityProvider {
  ScorePopup({required int points, required Vector2 spawnPosition})
      : _points = points,
        super(anchor: Anchor.center, position: spawnPosition, priority: 20);

  final int _points;
  double _opacity = 1.0;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) => _opacity = value.clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(MoveEffect.by(
      Vector2(0, -72),
      EffectController(duration: 0.85, curve: Curves.easeOut),
    ));
    add(OpacityEffect.fadeOut(
      EffectController(startDelay: 0.30, duration: 0.55),
      onComplete: removeFromParent,
    ));
  }

  @override
  void render(ui.Canvas canvas) {
    final style = TextStyle(
      fontSize: _fontSize(_points),
      fontWeight: FontWeight.w900,
      color: _color(_points).withValues(alpha: _opacity),
      shadows: [
        Shadow(
          offset: const Offset(1, 2),
          blurRadius: 3,
          color: LaraColors.ink.withValues(alpha: _opacity),
        ),
      ],
    );
    final tp = TextPainter(
      text: TextSpan(text: '+$_points', style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  static double _fontSize(int pts) => switch (pts) {
        1 => 22,
        2 => 25,
        3 => 29,
        _ => 36,
      };

  static Color _color(int pts) => switch (pts) {
        1 => LaraColors.corazonRed,
        2 => LaraColors.cream,
        3 => LaraColors.pink,
        _ => LaraColors.yellow,
      };
}
