// import 'dart:async';

// import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
// import 'package:flame/events.dart';
// import 'package:flutter/material.dart';

// import '../../../shared/lara_theme.dart';
// import '../memory_match_game.dart';

// class MemoryCard extends SpriteComponent
//     with TapCallbacks, HasGameReference<MemoryMatchGame> {
//   MemoryCard({
//     required this.back,
//     required this.face,
//     required this.faceId,
//     required this.col,
//     required this.row,
//   }) : super(sprite: back);

//   final Sprite back;
//   final Sprite face;
//   final String faceId;
//   final int col;
//   final int row;

//   bool faceUp = false;
//   bool matched = false;
//   bool _animating = false;

//   Future<void> flipUp() async {
//     if (faceUp || _animating) return;
//     faceUp = true;
//     await _flipTo(face);
//   }

//   Future<void> flipDown() async {
//     if (!faceUp || _animating) return;
//     faceUp = false;
//     await _flipTo(back);
//   }

//   void markMatched() {
//     matched = true;
//     add(
//       ScaleEffect.by(
//         Vector2.all(1.18),
//         EffectController(
//           duration: 0.22,
//           alternate: true,
//           reverseDuration: 0.22,
//           curve: Curves.easeOutBack,
//         ),
//       ),
//     );
//     add(
//       ScaleEffect.by(
//         Vector2.all(1.04),
//         EffectController(
//           duration: 0.9,
//           alternate: true,
//           infinite: true,
//           curve: Curves.easeInOut,
//         ),
//       ),
//     );
//   }

//   // Horizontal shake used to signal a wrong pair — four-step left-right-left
//   // motion that returns to the original position in ~0.28s.
//   Future<void> shakeWrong() async {
//     final done = Completer<void>();
//     add(
//       SequenceEffect(
//         [
//           MoveEffect.by(Vector2(8, 0), EffectController(duration: 0.07)),
//           MoveEffect.by(Vector2(-16, 0), EffectController(duration: 0.07)),
//           MoveEffect.by(Vector2(16, 0), EffectController(duration: 0.07)),
//           MoveEffect.by(Vector2(-8, 0), EffectController(duration: 0.07)),
//         ],
//         onComplete: done.complete,
//       ),
//     );
//     await done.future;
//   }

//   /// Two-stage horizontal flip. Each phase uses a [Completer] tied to the
//   /// effect's `onComplete`, so the future only resolves once the new face
//   /// is fully visible. This guarantees the game's tap handler can await
//   /// the flip before deciding whether to mark a match or flip back down.
//   Future<void> _flipTo(Sprite target) async {
//     _animating = true;
//     final first = Completer<void>();
//     add(
//       ScaleEffect.to(
//         Vector2(0.01, 1),
//         EffectController(duration: 0.18, curve: Curves.easeInCubic),
//         onComplete: first.complete,
//       ),
//     );
//     await first.future;
//     sprite = target;
//     final second = Completer<void>();
//     add(
//       ScaleEffect.to(
//         Vector2(1, 1),
//         EffectController(duration: 0.18, curve: Curves.easeOutBack),
//         onComplete: second.complete,
//       ),
//     );
//     await second.future;
//     _animating = false;
//   }

//   @override
//   void render(Canvas canvas) {
//     if (!faceUp) {
//       super.render(canvas);
//       return;
//     }

//     const radius = Radius.circular(8);
//     const borderWidth = 2.5;
//     const padding = 6.0;

//     final rect = RRect.fromRectAndRadius(
//       Rect.fromLTWH(0, 0, size.x, size.y),
//       radius,
//     );

//     canvas.drawRRect(rect, Paint()..color = Colors.white);
//     canvas.drawRRect(
//       rect,
//       Paint()
//         ..color = matched ? LaraColors.yellow : LaraColors.mint
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = borderWidth,
//     );

//     const p = padding;
//     sprite?.render(
//       canvas,
//       position: Vector2.all(p),
//       size: Vector2(size.x - p * 2, size.y - p * 2),
//     );
//   }

//   @override
//   void onTapDown(TapDownEvent event) {
//     game.onCardTapped(this);
//   }
// }
