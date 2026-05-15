import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../shared/lara_theme.dart';
import '../galleta_run_game.dart';
import 'galleta.dart';

/// A danger bird that flies at jump height — Galleta must stay on the ground.
///
/// Visual design: vivid red body (reads as "danger"), bright yellow wings
/// (high contrast against the sky background), angry eyebrow, and a pulsing
/// red halo so the player can identify the threat from across the screen.
class BirdObstacle extends PositionComponent
    with CollisionCallbacks, HasGameReference<GalletaRunGame> {
  BirdObstacle({required this.speed, required double centerY})
      : super(
          size: Vector2(84, 54),
          anchor: Anchor.center,
          priority: 0,
        ) {
    position.y = centerY;
  }

  final double speed;

  double _flapTimer = 0;
  double _flapAngle = 0;
  double _bobTimer = 0;
  late final double _baseY;

  @override
  Future<void> onLoad() async {
    _baseY = position.y;
    // Hitbox covers only the body core for fair play.
    add(RectangleHitbox.relative(Vector2(0.45, 0.52), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    if (position.x < -size.x) {
      removeFromParent();
      return;
    }
    _bobTimer += dt;
    position.y = _baseY + math.sin(_bobTimer * 3.0) * 7;
    _flapTimer += dt;
    if (_flapTimer >= 0.12) {
      _flapTimer = 0;
      _flapAngle = _flapAngle == 0 ? -0.60 : 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y * 0.60;

    // ── Pulsing danger halo ──────────────────────────────────────────────
    final pulse = math.sin(_bobTimer * 7.0) * 0.5 + 0.5; // 0…1
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.x * (0.68 + pulse * 0.18),
        height: size.y * (0.72 + pulse * 0.18),
      ),
      Paint()
        ..color = LaraColors.corazonRed.withValues(alpha: 0.12 + pulse * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // ── Wing (yellow, drawn behind body) ─────────────────────────────────
    final wingPath = Path()
      ..moveTo(size.x * 0.10, cy + 2)
      ..quadraticBezierTo(
        cx + math.cos(_flapAngle) * size.x * 0.46,
        cy + math.sin(_flapAngle) * size.y * 0.95,
        size.x * 0.92,
        cy + 2,
      )
      ..close();
    canvas.drawPath(wingPath, Paint()..color = LaraColors.yellow);

    // Wing leading-edge shadow for depth
    final wingEdge = Paint()
      ..color = LaraColors.galletaBrown.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(wingPath, wingEdge);

    // ── Body (red) ────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.x * 0.56,
        height: size.y * 0.54,
      ),
      Paint()..color = LaraColors.corazonRed,
    );

    // Chest highlight — slightly right of centre (body faces left)
    canvas.drawCircle(
      Offset(cx + 5, cy + 4),
      size.x * 0.095,
      Paint()..color = LaraColors.pink.withValues(alpha: 0.55),
    );

    // ── Beak (yellow, pointing LEFT — bird flies left) ────────────────────
    final beakPath = Path()
      ..moveTo(size.x * 0.17, cy - 4)
      ..lineTo(-size.x * 0.04, cy + 3)
      ..lineTo(size.x * 0.17, cy + 10)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = LaraColors.yellow);

    // ── Eye (left side of body) ───────────────────────────────────────────
    canvas.drawCircle(
      Offset(size.x * 0.27, cy - 6),
      4.5,
      Paint()..color = LaraColors.ink,
    );
    canvas.drawCircle(
      Offset(size.x * 0.27 - 1.5, cy - 7.5),
      1.8,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // ── Angry eyebrow (slopes down toward beak on the left) ───────────────
    canvas.drawLine(
      Offset(size.x * 0.36, cy - 12),
      Offset(size.x * 0.20, cy - 9),
      Paint()
        ..color = LaraColors.ink
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Galleta) game.onCrash();
  }
}
