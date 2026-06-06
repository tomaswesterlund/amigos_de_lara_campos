// import 'dart:math' as math;

// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
// import 'package:flutter/material.dart';

// import '../../../shared/lara_theme.dart';
// import '../galleta_run_game.dart';

// /// Galleta — player character for the endless runner.
// ///
// /// Split into two layers to keep collision detection stable:
// ///   • [Galleta] (PositionComponent) owns the [RectangleHitbox] and the
// ///     physics state (airborne, velocityY). Its size/position are never
// ///     touched by visual animations so the hitbox is always authoritative.
// ///   • [_GalletaVisual] (SpriteComponent child) receives every transient
// ///     effect — idle bounce, jump lean, landing squash/stretch, pickup burst,
// ///     crash flash/spin — so none of those scale the parent hitbox.
// class Galleta extends PositionComponent
//     with CollisionCallbacks, HasGameReference<GalletaRunGame> {
//   Galleta(this._sprite)
//       : super(
//           size: Vector2.all(110),
//           anchor: Anchor.center,
//         );

//   final Sprite _sprite;
//   bool airborne = false;
//   double velocityY = 0;

//   bool _isHit = false;
//   late _GalletaVisual _visual;

//   @override
//   Future<void> onLoad() async {
//     add(RectangleHitbox.relative(Vector2(0.7, 0.7), parentSize: size));
//     _visual = _GalletaVisual(_sprite, size);
//     add(_visual);
//   }

//   // ── Jump ──────────────────────────────────────────────────────────────────

//   /// Called by the game when a tap is accepted. Starts the lean effect.
//   void startJump() {
//     if (_isHit) return;
//     _visual.startJumpLean();
//   }

//   /// Called by the game when Galleta touches the ground after a jump.
//   void land() {
//     if (_isHit) return;
//     _visual.playLanding();
//   }

//   // ── Pickup burst ──────────────────────────────────────────────────────────

//   void playPickupBurst() {
//     if (_isHit) return;
//     _visual.add(ScaleEffect.to(
//       Vector2.all(1.45),
//       EffectController(duration: 0.07, curve: Curves.easeOut),
//     ));
//     _visual.add(ScaleEffect.to(
//       Vector2.all(1.0),
//       EffectController(duration: 0.11, startDelay: 0.07, curve: Curves.easeIn),
//     ));
//     for (var i = 0; i < 6; i++) {
//       _spawnSparkle();
//     }
//   }

//   void _spawnSparkle() {
//     final rng = math.Random();
//     final offset = Vector2(
//       (rng.nextDouble() - 0.5) * 72,
//       (rng.nextDouble() - 0.5) * 72,
//     );
//     const colors = [
//       LaraColors.galletaBrown,
//       LaraColors.yellow,
//       LaraColors.pink,
//       LaraColors.corazonRed,
//     ];
//     final color = colors[rng.nextInt(colors.length)];
//     final sparkle = CircleComponent(
//       radius: 4,
//       anchor: Anchor.center,
//       position: position + offset,
//       paint: Paint()..color = color,
//     );
//     sparkle.add(ScaleEffect.to(
//       Vector2.all(2.6),
//       EffectController(duration: 0.36, curve: Curves.easeOut),
//     ));
//     sparkle.add(OpacityEffect.fadeOut(EffectController(duration: 0.36)));
//     sparkle.add(RemoveEffect(delay: 0.38));
//     game.add(sparkle);
//   }

//   // ── Crash ─────────────────────────────────────────────────────────────────

//   Future<void> crash() async {
//     _isHit = true;
//     _visual.stopBounce();
//     for (var i = 0; i < 3; i++) {
//       _visual.add(OpacityEffect.to(0.2, EffectController(duration: 0.07)));
//       await Future<void>.delayed(const Duration(milliseconds: 75));
//       _visual.add(OpacityEffect.to(1.0, EffectController(duration: 0.07)));
//       await Future<void>.delayed(const Duration(milliseconds: 75));
//     }
//     _visual.add(RotateEffect.by(
//       math.pi * 2,
//       EffectController(duration: 0.45, curve: Curves.easeIn),
//     ));
//     _visual.add(ScaleEffect.to(
//       Vector2.zero(),
//       EffectController(duration: 0.45, curve: Curves.easeIn),
//     ));
//     await Future<void>.delayed(const Duration(milliseconds: 450));
//   }
// }

// // ── Visual-only child ─────────────────────────────────────────────────────────

// /// Sprite + idle animation for Galleta. Receives every transient effect
// /// (scale, lean, flash) so that [Galleta]'s hitbox stays unaffected.
// class _GalletaVisual extends SpriteComponent {
//   _GalletaVisual(Sprite sprite, Vector2 parentSize)
//       : super(
//           sprite: sprite,
//           size: parentSize,
//           anchor: Anchor.center,
//           position: parentSize / 2,
//         );

//   Effect? _bounce;
//   RotateEffect? _leanEffect;

//   @override
//   Future<void> onLoad() async {
//     _bounce = MoveByEffect(
//       Vector2(0, -4),
//       EffectController(
//         duration: 0.50,
//         alternate: true,
//         infinite: true,
//         curve: Curves.easeInOut,
//       ),
//     );
//     add(_bounce!);
//   }

//   void stopBounce() => _bounce?.removeFromParent();

//   // Forward lean during airborne, straighten on land.
//   void startJumpLean() {
//     _leanEffect?.removeFromParent();
//     final lean = RotateEffect.to(
//       0.20,
//       EffectController(
//         duration: 0.08,
//         curve: Curves.easeOut,
//         alternate: true,
//         reverseDuration: 0.12,
//       ),
//     );
//     _leanEffect = lean;
//     add(lean);
//   }

//   void playLanding() {
//     // Squash
//     add(ScaleEffect.to(
//       Vector2(1.40, 0.58),
//       EffectController(duration: 0.04, curve: Curves.easeOut),
//     ));
//     // Elastic rebound
//     add(ScaleEffect.to(
//       Vector2.all(1.0),
//       EffectController(
//         duration: 0.20,
//         startDelay: 0.04,
//         curve: Curves.elasticOut,
//       ),
//     ));
//   }
// }
