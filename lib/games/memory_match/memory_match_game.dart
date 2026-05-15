import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/memory_card.dart';
import 'memory_match_leaderboard.dart';

/// 4×3 grid memory game using Lara's companions as the face values.
class MemoryMatchGame extends LaraGame {
  MemoryMatchGame() : super(gradient: LaraGradients.party);

  static const _cols = 4;
  static const _rows = 3;

  final _faceNames = const [
    'rhenne.png',
    'reina.png',
    'galleta.png',
    'corazon.png',
    'music_note.png',
    'lara.png',
  ];

  late final Sprite _back;
  final _faces = <String, Sprite>{};
  MemoryCard? _firstPick;
  bool _busy = false;
  int _matches = 0;
  int _moves = 0;
  bool _built = false;
  MemoryMatchEntry? lastEntry;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _back = await loadSprite('card_back.png');
    for (final n in _faceNames) {
      _faces[n] = await loadSprite(n);
    }
    _buildBoard();
  }

  void _buildBoard() {
    children.whereType<MemoryCard>().toList().forEach((c) => c.removeFromParent());
    _matches = 0;
    _moves = 0;
    setScore(0);

    final deck = <String>[for (final n in _faceNames) ...[n, n]]..shuffle(Random());
    final cardSize = _cardSize();
    final (startX, startY) = _origin(cardSize);

    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        final face = deck[r * _cols + c];
        final card = MemoryCard(
          back: _back,
          face: _faces[face]!,
          faceId: face,
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
      await card.flipUp();
      return;
    }

    // Second pick — lock the board immediately so a third tap can't sneak
    // in while the flip is still animating, then wait for the card to be
    // fully visible before judging the match.
    _busy = true;
    final first = _firstPick!;
    _firstPick = null;
    await card.flipUp();

    _moves += 1;

    if (first.faceId == card.faceId) {
      first.markMatched();
      card.markMatched();
      _matches += 1;
      setScore(_matches);

      // Float a "+1" between the two matched cards.
      final mid = Vector2(
        (first.position.x + card.position.x) / 2,
        (first.position.y + card.position.y) / 2,
      );
      add(_ScorePopup(mid));

      if (_matches == _faceNames.length) {
        lastEntry = MemoryMatchLeaderboard.submit(_moves);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        showGameOver('¡Encontraste a todos los amigos!\nMovimientos: $_moves', () {});
      }
    } else {
      // Shake both cards simultaneously as immediate wrong feedback, while
      // the 1200ms hold timer runs in parallel.
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
