import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../shared/collectibles_state.dart';
import '../../shared/lara_audio.dart';
import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import '../../shared/qr_unlock_state.dart';
import 'components/memory_card.dart';
import 'components/night_sky.dart';
import 'memory_match_leaderboard.dart';

/// 4×3 grid memory game using Lara's companions as the face values.
/// Difficulty can be changed in-game: easy (3×2), normal (4×3), hard (5×4).
class MemoryMatchGame extends LaraGame {
  MemoryMatchGame() : super(gradient: LaraGradients.night, bgm: LaraBgm.memory);

  // difficulty: 0=easy(3×2), 1=normal(4×3), 2=hard(5×4)
  static const _colsByDiff = [3, 4, 5];
  static const _rowsByDiff = [2, 3, 4];
  int _diffIdx = 1;
  int get _cols => _colsByDiff[_diffIdx];
  int get _rows => _rowsByDiff[_diffIdx];
  int get _pairsPerGame => (_cols * _rows) ~/ 2;

  /// Exposed so [_DifficultyPill] can read it without making [_diffIdx] public.
  int get difficultyIndex => _diffIdx;

  // Fallbacks ensure we always have enough pairs even if few collectibles are unlocked.
  static const _fallbacks = [
    'rhenne.png', 'reina.png', 'galleta.png',
    'corazon.png', 'music_note.png', 'lara.png',
  ];

  late final Sprite _back;
  final _faces = <String, Sprite>{};
  MemoryCard? _firstPick;
  bool _busy = false;
  int _matches = 0;
  int _moves = 0;
  int _coinsCollected = 0;
  int _pairsThisRound = 0;
  bool _built = false;
  int? _pendingDifficultyIdx;
  MemoryMatchEntry? lastEntry;

  int get coinsCollected => _coinsCollected;

  bool get _isGameInProgress => _moves > 0 || _firstPick != null || _matches > 0;

  /// Changes difficulty; shows a confirmation overlay if a game is in progress.
  void setDifficulty(int idx) {
    final next = idx.clamp(0, 2);
    if (next == _diffIdx) return;
    if (_built && _isGameInProgress) {
      _pendingDifficultyIdx = next;
      overlays.add('difficultyConfirm');
      return;
    }
    _diffIdx = next;
    if (_built) _buildBoard();
  }

  void confirmDifficulty() {
    overlays.remove('difficultyConfirm');
    final pending = _pendingDifficultyIdx;
    _pendingDifficultyIdx = null;
    if (pending != null) {
      _diffIdx = pending;
      _buildBoard();
    }
  }

  void cancelDifficulty() {
    overlays.remove('difficultyConfirm');
    _pendingDifficultyIdx = null;
  }

  /// Returns all collectible image names that are currently unlocked,
  /// plus fallback originals to pad up to at least [_pairsPerGame].
  ///
  /// When a collectible variant (e.g. rhenne_l1.png) is in the pool its base
  /// fallback (rhenne.png) is excluded — both sprites look identical in the
  /// placeholder art, which would produce two visually-indistinguishable pairs.
  List<String> _candidateNames() {
    final pool = <String>[];
    final excludeFallbacks = <String>{};
    for (var i = 0; i < CollectiblesState.count; i++) {
      if (CollectiblesState.isUnlocked('rhenne', i)) {
        pool.add('rhenne_l${i + 1}.png');
        excludeFallbacks.add('rhenne.png');
      }
      if (CollectiblesState.isUnlocked('galleta', i)) {
        pool.add('galleta_l${i + 1}.png');
        excludeFallbacks.add('galleta.png');
      }
      if (CollectiblesState.isUnlocked('heart', i)) {
        pool.add('corazon_l${i + 1}.png');
        excludeFallbacks.add('corazon.png');
      }
    }
    for (var i = 0; i < QrUnlockState.count; i++) {
      if (QrUnlockState.isUnlocked(i)) {
        pool.add('lara_d${i + 1}.png');
        excludeFallbacks.add('lara.png');
      }
    }
    for (final f in _fallbacks) {
      if (!excludeFallbacks.contains(f) && !pool.contains(f)) pool.add(f);
    }
    return pool;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(NightSkyLayer());
    _back = await loadSprite('card_back.png');
    for (final n in _candidateNames()) {
      _faces[n] = await loadSprite(n);
    }
    _buildBoard();
  }

  void _buildBoard() {
    children.whereType<MemoryCard>().toList().forEach((c) => c.removeFromParent());
    _matches = 0;
    _moves = 0;
    setScore(0);

    // Pick _pairsPerGame faces at random. Cycle the pool if fewer distinct faces
    // are available than pairs needed (e.g. hard mode with few collectibles unlocked).
    final rng = Random();
    final pool = _faces.keys.toList()..shuffle(rng);
    final selected = <String>[];
    while (selected.length < _pairsPerGame) {
      final remaining = _pairsPerGame - selected.length;
      selected.addAll(pool.take(remaining));
      if (selected.length < _pairsPerGame) pool.shuffle(rng);
    }

    _pairsThisRound = selected.length;

    final deck = <String>[for (final n in selected) ...[n, n]]..shuffle(rng);
    final cardSize = _cardSize();
    final (startX, startY) = _origin(cardSize);

    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        final faceId = deck[r * _cols + c];
        final card = MemoryCard(
          back: _back,
          face: _faces[faceId]!,
          faceId: faceId,
          col: c,
          row: r,
        )
          ..size = Vector2.all(cardSize)
          ..anchor = Anchor.center
          ..position = Vector2(
            startX + c * (cardSize + 12),
            startY + r * (cardSize + 12),
          );
        add(card);
      }
    }
    _built = true;
  }

  void _reflowBoard() {
    final cardSize = _cardSize();
    final (startX, startY) = _origin(cardSize);
    for (final card in children.whereType<MemoryCard>()) {
      card.size = Vector2.all(cardSize);
      card.position = Vector2(
        startX + card.col * (cardSize + 12),
        startY + card.row * (cardSize + 12),
      );
    }
  }

  double _cardSize() {
    final cardW = (size.x - 64 - 12 * (_cols - 1)) / _cols;
    final cardH = (size.y - 200 - 12 * (_rows - 1)) / _rows;
    return min(cardW, cardH).clamp(60.0, 160.0);
  }

  (double, double) _origin(double cardSize) {
    final boardW = cardSize * _cols + 12 * (_cols - 1);
    final boardH = cardSize * _rows + 12 * (_rows - 1);
    final startX = (size.x - boardW) / 2 + cardSize / 2;
    final startY = (size.y - boardH) / 2 + cardSize / 2 + 20;
    return (startX, startY);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_built) return;
    _reflowBoard();
  }

  Future<void> onCardTapped(MemoryCard card) async {
    if (_busy) return;
    if (card.matched || card.faceUp) return;

    // First pick — flip and remember; tapping any other card now is fine.
    if (_firstPick == null) {
      _firstPick = card;
      LaraAudio.playSfx(LaraSfx.hitGood);
      await card.flipUp();
      return;
    }

    // Second pick — lock the board immediately so a third tap can't sneak
    // in while the flip is still animating, then wait for the card to be
    // fully visible before judging the match.
    _busy = true;
    final first = _firstPick!;
    _firstPick = null;
    LaraAudio.playSfx(LaraSfx.hitGood);
    await card.flipUp();

    _moves += 1;

    if (first.faceId == card.faceId) {
      first.markMatched();
      card.markMatched();
      LaraAudio.playSfx(LaraSfx.hitPerfect);
      _matches += 1;
      setScore(_moves);

      final mid = Vector2(
        (first.position.x + card.position.x) / 2,
        (first.position.y + card.position.y) / 2,
      );
      add(_ScorePopup(mid));

      if (_matches == _pairsThisRound) {
        _coinsCollected = 1;
        lastEntry = MemoryMatchLeaderboard.submit(_moves);
        LaraAudio.playSfx(LaraSfx.unlock);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        showGameOver('¡Encontraste a todos los amigos!\nMovimientos: $_moves', () {});
      }
    } else {
      // Shake both cards simultaneously as immediate wrong feedback, while
      // the 1200ms hold timer runs in parallel.
      LaraAudio.playSfx(LaraSfx.miss);
      await Future.wait([
        first.shakeWrong(),
        card.shakeWrong(),
        Future<void>.delayed(const Duration(milliseconds: 1200)),
      ]);
      await Future.wait([first.flipDown(), card.flipDown()]);
    }
    _busy = false;
  }
}

// ─── Difficulty controls ──────────────────────────────────────────────────────

class _DifficultyControls extends PositionComponent
    with HasGameReference<MemoryMatchGame> {
  _DifficultyControls() : super(anchor: Anchor.center);

  static const _labels = ['Fácil', 'Normal', 'Difícil'];
  static const _pillW = 82.0;
  static const _pillH = 36.0;
  static const _gap = 10.0;

  @override
  Future<void> onLoad() async {
    size = Vector2(
      _labels.length * _pillW + (_labels.length - 1) * _gap,
      _pillH,
    );
    for (var i = 0; i < _labels.length; i++) {
      add(_DifficultyPill(label: _labels[i], index: i)
        ..position = Vector2(i * (_pillW + _gap) + _pillW / 2, _pillH / 2));
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = Vector2(gameSize.x / 2, gameSize.y - 30);
  }
}

class _DifficultyPill extends PositionComponent
    with HasGameReference<MemoryMatchGame>, TapCallbacks {
  _DifficultyPill({required this.label, required this.index})
      : super(
          size: Vector2(_DifficultyControls._pillW, _DifficultyControls._pillH),
          anchor: Anchor.center,
        );

  final String label;
  final int index;

  static final _activeText = TextPaint(
    style: const TextStyle(
        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
  );
  static final _inactiveText = TextPaint(
    style: const TextStyle(
        color: Color(0xFF1E1E28), fontSize: 13, fontWeight: FontWeight.w700),
  );

  @override
  void render(Canvas canvas) {
    final isActive = game.difficultyIndex == index;
    final bgPaint = Paint()
      ..color = isActive
          ? LaraColors.magenta
          : Colors.white.withValues(alpha: 0.65);
    final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(18));
    canvas.drawRRect(rr, bgPaint);
    if (isActive) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    (isActive ? _activeText : _inactiveText)
        .render(canvas, label, size / 2, anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) => game.setDifficulty(index);
}

// ─── Score popup ──────────────────────────────────────────────────────────────

class _ScorePopup extends TextComponent {
  _ScorePopup(Vector2 pos)
      : super(
          text: '+1',
          anchor: Anchor.center,
          position: pos,
          priority: 100,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: LaraColors.magenta, blurRadius: 8, offset: Offset(1, 2)),
              ],
            ),
          ),
        );

  @override
  void onMount() {
    super.onMount();
    add(MoveEffect.by(
      Vector2(0, -65),
      EffectController(duration: 0.7, curve: Curves.easeOut),
    ));
    add(ScaleEffect.to(
      Vector2.all(0.01),
      EffectController(duration: 0.3, startDelay: 0.4, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }
}

