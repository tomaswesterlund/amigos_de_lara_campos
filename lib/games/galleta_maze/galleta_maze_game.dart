import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';

import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/maze_enemy.dart';
import 'components/maze_galleta.dart';
import 'components/pellet.dart';
import 'components/wall_tile.dart';
import 'maze_dir.dart';

/// Very simplified Pac-Man with Galleta. Tap the direction you want
/// Galleta to head — she walks tile-by-tile until a wall stops her or
/// you tap again. Eat every treat to win; let a rock catch you and the
/// round ends.
class GalletaMazeGame extends LaraGame with TapCallbacks {
  GalletaMazeGame() : super(gradient: LaraGradients.party);

  // Maze layout. 9 cols × 11 rows.
  // W = wall, . = path with treat, P = player spawn, B = enemy spawn.
  static const _maze = <String>[
    'WWWWWWWWW',
    'W.......W',
    'W.WW.WW.W',
    'W.......W',
    'W.W.W.W.W',
    'W...B...W',
    'W.W.W.W.W',
    'W.......W',
    'W. WW.WW.W',
    'W...P...W',
    'WWWWWWWWW',
  ];
  static const _cols = 9;
  static const _rows = 11;
  static const _stepDuration = 0.22;
  static const _enemyStepDuration = 0.65;

  // Mutable grid: each cell is true while a pellet still lives there.
  late List<List<bool>> _hasPellet;
  // Pellet component lookup so we can remove on eat.
  final _pelletAt = <String, Pellet>{};

  double _cellSize = 0;
  Vector2 _origin = Vector2.zero();

  Sprite? _galletaSprite;
  Sprite? _pelletSprite;
  Sprite? _enemySprite;

  MazeGalleta? _player;
  int _playerCol = 0;
  int _playerRow = 0;
  MazeDir _playerDir = MazeDir.none;
  MazeDir _queuedDir = MazeDir.none;
  bool _playerStepping = false;

  int _enemyCol = 0;
  int _enemyRow = 0;
  MazeEnemy? _enemy;
  final _rng = Random();

  int _pelletsLeft = 0;
  bool _running = true;
  bool _built = false;

  /// Bumped each time the maze is (re)built. Async step loops read this at
  /// start and bail if it changes — that way stale chains die instead of
  /// piling up after a rebuild.
  int _session = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _galletaSprite = await loadSprite('galleta.png');
    _pelletSprite = await loadSprite('treat_bone.png');
    _enemySprite = await loadSprite('obstacle_rock.png');
    _build();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // The single _build() lives in onLoad. Resizes only reflow existing
    // components — never tear the world down and respawn Galleta back to
    // her starting square. Bailing while _built is false avoids racing
    // onLoad's sprite-load awaits.
    if (!_built) return;
    _reflow();
  }

  /// One-shot creation of walls, pellets, player and enemy. Bumps the
  /// session id so any in-flight step loops from a prior build die.
  void _build() {
    _session++;
    children.whereType<WallTile>().toList().forEach((c) => c.removeFromParent());
    children.whereType<Pellet>().toList().forEach((c) => c.removeFromParent());
    _pelletAt.clear();
    _player?.removeFromParent();
    _enemy?.removeFromParent();

    _computeMetrics();

    _hasPellet = List.generate(
      _rows,
      (r) => List<bool>.filled(_cols, false),
    );
    _pelletsLeft = 0;

    int? playerCol, playerRow, enemyCol, enemyRow;

    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        final ch = _maze[r][c];
        if (ch == 'W') {
          add(
            WallTile(
              cellPosition: _cellOrigin(c, r),
              cellSize: _cellSize,
            ),
          );
        } else if (ch == '.') {
          _hasPellet[r][c] = true;
          _pelletsLeft++;
          final pellet = Pellet(sprite: _pelletSprite!, col: c, row: r)
            ..size = Vector2.all(_cellSize * 0.42)
            ..anchor = Anchor.center
            ..position = _cellCenter(c, r);
          _pelletAt[_key(c, r)] = pellet;
          add(pellet);
        } else if (ch == 'P') {
          playerCol = c;
          playerRow = r;
        } else if (ch == 'B') {
          enemyCol = c;
          enemyRow = r;
        }
      }
    }

    final player = MazeGalleta(sprite: _galletaSprite!)
      ..size = Vector2.all(_cellSize * 0.78)
      ..position = _cellCenter(playerCol!, playerRow!);
    _player = player;
    _playerCol = playerCol;
    _playerRow = playerRow;
    _playerDir = MazeDir.none;
    _queuedDir = MazeDir.none;
    _playerStepping = false;
    add(player);

    final enemy = MazeEnemy(sprite: _enemySprite!)
      ..size = Vector2.all(_cellSize * 0.72)
      ..position = _cellCenter(enemyCol!, enemyRow!)
      ..gridCol = enemyCol
      ..gridRow = enemyRow;
    _enemy = enemy;
    _enemyCol = enemyCol;
    _enemyRow = enemyRow;
    add(enemy);

    // Tiny scale pulse so the rock feels alive while it idles. ScaleEffect
    // doesn't touch position, so it stays compatible with grid-snapped
    // moveTo.
    enemy.add(
      ScaleEffect.by(
        Vector2.all(1.08),
        EffectController(
          duration: 0.55,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _built = true;

    // Kick off enemy movement after a brief grace period. The captured
    // session id keeps this chain pinned to the current build.
    final session = _session;
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (_session == session) _stepEnemy(session);
    });
  }

  /// Recompute cellSize / origin from the current viewport, then nudge every
  /// component to its new screen-space position. Player + enemy are snapped
  /// back to their *current* grid cell (not their spawn cell) so a resize
  /// during play doesn't reset progress.
  void _reflow() {
    _computeMetrics();
    for (final w in children.whereType<WallTile>()) {
      // WallTile stores its cell coordinates by position; the simplest
      // robust path is to rebuild walls. They have no state.
      w.removeFromParent();
    }
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        if (_maze[r][c] == 'W') {
          add(
            WallTile(cellPosition: _cellOrigin(c, r), cellSize: _cellSize),
          );
        }
      }
    }
    for (final entry in _pelletAt.entries) {
      final parts = entry.key.split(',');
      final c = int.parse(parts[0]);
      final r = int.parse(parts[1]);
      entry.value
        ..size = Vector2.all(_cellSize * 0.42)
        ..position = _cellCenter(c, r);
    }
    final p = _player;
    if (p != null) {
      // Cancel any in-flight step and snap to current grid cell.
      p.children.whereType<MoveEffect>().toList().forEach((e) => e.removeFromParent());
      p
        ..size = Vector2.all(_cellSize * 0.78)
        ..position = _cellCenter(_playerCol, _playerRow);
      _playerStepping = false;
    }
    final e = _enemy;
    if (e != null) {
      e.children.whereType<MoveEffect>().toList().forEach((ef) => ef.removeFromParent());
      e
        ..size = Vector2.all(_cellSize * 0.72)
        ..position = _cellCenter(_enemyCol, _enemyRow);
    }
  }

  void _computeMetrics() {
    const margin = 16.0;
    const topPad = 80.0;
    final available = Vector2(size.x - margin * 2, size.y - topPad - margin);
    _cellSize = min(available.x / _cols, available.y / _rows);
    final boardW = _cellSize * _cols;
    final boardH = _cellSize * _rows;
    _origin = Vector2(
      (size.x - boardW) / 2,
      topPad + (available.y - boardH) / 2,
    );
  }

  Vector2 _cellOrigin(int c, int r) =>
      Vector2(_origin.x + c * _cellSize, _origin.y + r * _cellSize);

  Vector2 _cellCenter(int c, int r) =>
      _cellOrigin(c, r) + Vector2.all(_cellSize / 2);

  String _key(int c, int r) => '$c,$r';

  bool _isOpen(int c, int r) {
    if (c < 0 || c >= _cols || r < 0 || r >= _rows) return false;
    return _maze[r][c] != 'W';
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_running) return;
    final p = _player?.position;
    if (p == null) return;
    final dx = event.localPosition.x - p.x;
    final dy = event.localPosition.y - p.y;
    if (dx.abs() > dy.abs()) {
      _queuedDir = dx > 0 ? MazeDir.right : MazeDir.left;
    } else {
      _queuedDir = dy > 0 ? MazeDir.down : MazeDir.up;
    }
    if (!_playerStepping) _stepPlayer(_session);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;
    final p = _player;
    final e = _enemy;
    if (p == null || e == null) return;
    // Distance-based collision so the rock catches Galleta mid-step too.
    if ((p.position - e.position).length < _cellSize * 0.55) {
      _onCaught();
    }
  }

  Future<void> _stepPlayer(int session) async {
    if (!_running || session != _session) return;
    final candidates = <MazeDir>[_queuedDir, _playerDir];
    for (final d in candidates) {
      if (d == MazeDir.none) continue;
      final v = mazeDirVector(d);
      final nc = _playerCol + v.x.toInt();
      final nr = _playerRow + v.y.toInt();
      if (_isOpen(nc, nr)) {
        _playerDir = d;
        _playerCol = nc;
        _playerRow = nr;
        _playerStepping = true;
        _player!.waddle();
        await _player!.moveTo(
          _cellCenter(nc, nr),
          duration: _stepDuration,
        );
        if (session != _session) return;
        _onPlayerArrived(session);
        return;
      }
    }
    _playerDir = MazeDir.none;
    _playerStepping = false;
  }

  void _onPlayerArrived(int session) {
    if (!_running || session != _session) return;
    _eatPelletAt(_playerCol, _playerRow);
    _playerStepping = false;
    if (_pelletsLeft == 0) {
      _running = false;
      showGameOver(
        '¡Galleta encontró todas las galletas!\nPuntos: $score',
        () {},
      );
      return;
    }
    _stepPlayer(session);
  }

  void _eatPelletAt(int c, int r) {
    if (!_hasPellet[r][c]) return;
    _hasPellet[r][c] = false;
    final pellet = _pelletAt.remove(_key(c, r));
    if (pellet != null) {
      pellet.add(
        ScaleEffect.by(
          Vector2.all(1.6),
          EffectController(duration: 0.18, curve: Curves.easeOut),
        ),
      );
      pellet.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.18),
          onComplete: pellet.removeFromParent,
        ),
      );
    }
    _pelletsLeft--;
    setScore(score + 1);
  }

  Future<void> _stepEnemy(int session) async {
    if (!_running || session != _session) return;
    final e = _enemy;
    if (e == null) return;
    // Pick a direction: prefer not reversing, prefer paths that don't
    // dead-end immediately. Random tiebreak keeps the rock unpredictable.
    final options = <MazeDir>[];
    for (final d in const [MazeDir.up, MazeDir.down, MazeDir.left, MazeDir.right]) {
      if (isOpposite(d, e.currentDir) && e.currentDir != MazeDir.none) continue;
      final v = mazeDirVector(d);
      final nc = _enemyCol + v.x.toInt();
      final nr = _enemyRow + v.y.toInt();
      if (_isOpen(nc, nr)) options.add(d);
    }
    if (options.isEmpty) {
      // Dead end — turn around.
      final back = _opposite(e.currentDir);
      if (back != MazeDir.none) options.add(back);
    }
    if (options.isEmpty) return;
    options.shuffle(_rng);
    final chosen = options.first;
    final v = mazeDirVector(chosen);
    e.currentDir = chosen;
    _enemyCol += v.x.toInt();
    _enemyRow += v.y.toInt();
    await e.moveTo(
      _cellCenter(_enemyCol, _enemyRow),
      duration: _enemyStepDuration,
    );
    if (session != _session) return;
    _stepEnemy(session);
  }

  MazeDir _opposite(MazeDir d) {
    switch (d) {
      case MazeDir.up:
        return MazeDir.down;
      case MazeDir.down:
        return MazeDir.up;
      case MazeDir.left:
        return MazeDir.right;
      case MazeDir.right:
        return MazeDir.left;
      case MazeDir.none:
        return MazeDir.none;
    }
  }

  void _onCaught() {
    if (!_running) return;
    _running = false;
    final p = _player;
    if (p != null) {
      p.add(
        ScaleEffect.to(
          Vector2.all(0.6),
          EffectController(duration: 0.25, curve: Curves.easeIn),
        ),
      );
      p.add(OpacityEffect.fadeOut(EffectController(duration: 0.25)));
    }
    showGameOver('¡Casi! Una roca atrapó a Galleta.\nPuntos: $score', () {});
  }
}
