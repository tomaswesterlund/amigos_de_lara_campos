import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/falling_treat.dart';

/// Galleta sits at the bottom; drag horizontally to catch hearts and bones,
/// dodge rocks. Catching = points; hitting a rock = game over.
class GalletaCatchGame extends LaraGame
    with HasCollisionDetection, DragCallbacks, TapCallbacks {
  GalletaCatchGame() : super(gradient: LaraGradients.sunny);

  Sprite? _heartSprite;
  Sprite? _bonePinkSprite;
  Sprite? _rockSprite;
  _GalletaCatcher? _galleta;
  
  final _rng = Random();
  double _spawnTimer = 0;
  double _spawnInterval = 0.85;
  int _score = 0;
  bool _running = true;

  double get groundY => size.y * 0.86;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _heartSprite = await loadSprite('corazon.png');
    _bonePinkSprite = await loadSprite('treat_bone.png');
    _rockSprite = await loadSprite('obstacle_rock.png');
    final g = _GalletaCatcher(await loadSprite('galleta.png'));
    _galleta = g;
    add(g);
    _placeGalleta();
  }

  void _placeGalleta() {
    final g = _galleta;
    if (g == null) return;
    g.position = Vector2(size.x / 2, groundY - g.size.y / 2);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final g = _galleta;
    if (g != null) {
      g.position.y = groundY - g.size.y / 2;
      g.position.x = g.position.x.clamp(g.size.x / 2, size.x - g.size.x / 2);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    _spawnTimer += dt;
    _spawnInterval = (0.85 - _score * 0.005).clamp(0.35, 0.85);
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnFalling();
    }
  }

  void _spawnFalling() {
    final heart = _heartSprite;
    final bone = _bonePinkSprite;
    final rock = _rockSprite;
    if (heart == null || bone == null || rock == null) return;
    final roll = _rng.nextDouble();
    final TreatKind kind;
    if (roll < 0.55) {
      kind = TreatKind.heart;
    } else if (roll < 0.8) {
      kind = TreatKind.bone;
    } else {
      kind = TreatKind.rock;
    }
    final sprite = switch (kind) {
      TreatKind.heart => heart,
      TreatKind.bone => bone,
      TreatKind.rock => rock,
    };
    final treat = FallingTreat(
      sprite: sprite,
      kind: kind,
      fallSpeed: 200 + _rng.nextDouble() * 140 + _score * 1.2,
    )..position = Vector2(40 + _rng.nextDouble() * (size.x - 80), -40);
    add(treat);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _moveTo(event.canvasPosition.x);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final g = _galleta;
    if (g == null) return;
    _moveTo(g.position.x + event.localDelta.x);
  }

  void _moveTo(double targetX) {
    final g = _galleta;
    if (g == null) return;
    final clamped = targetX.clamp(g.size.x / 2, size.x - g.size.x / 2);
    g.position.x = clamped;
  }

  void onTreatCaught(FallingTreat t) {
    if (!_running) return;
    t.removeFromParent();
    switch (t.kind) {
      case TreatKind.heart:
        _score += 2;
        break;
      case TreatKind.bone:
        _score += 1;
        break;
      case TreatKind.rock:
        _running = false;
        showGameOver('¡Ay! Galleta tropezó con una roca.\nPuntos: $_score', () {});
        return;
    }
    setScore(_score);
  }
}

class _GalletaCatcher extends SpriteComponent with CollisionCallbacks {
  _GalletaCatcher(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2.all(110),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(Vector2(0.75, 0.6), parentSize: size)
      ..position = Vector2(size.x * 0.125, size.y * 0.3));
  }
}
