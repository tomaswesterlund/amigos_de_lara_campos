import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../shared/lara_game.dart';
import '../../shared/lara_theme.dart';
import 'components/letter_card.dart';
import 'components/nav_arrow.dart';
import 'components/speaking_rhenne.dart';

/// Letters of the Mexican Spanish alphabet (27 letters — Ñ included, the
/// digraphs Ch/Ll/Rr collapsed into C/L/R per the RAE update Mexico follows).
const List<String> mexicanAlphabet = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  'L', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
  'V', 'W', 'X', 'Y', 'Z',
];

/// Phonetic spelling shown in the speech bubble. Kept simple/childlike so
/// kids can read along while Rhenné says it aloud.
const Map<String, String> _phonetic = {
  'A': 'aaa', 'B': 'be', 'C': 'ce', 'D': 'de', 'E': 'eee', 'F': 'efe',
  'G': 'ge', 'H': 'hache', 'I': 'iii', 'J': 'jota', 'K': 'ka', 'L': 'ele',
  'M': 'eme', 'N': 'ene', 'Ñ': 'eñe', 'O': 'ooo', 'P': 'pe', 'Q': 'cu',
  'R': 'erre', 'S': 'ese', 'T': 'te', 'U': 'uuu', 'V': 've', 'W': 'doble u',
  'X': 'equis', 'Y': 'ye', 'Z': 'zeta',
};

/// Tappable alphabet game. Rhenné speaks each letter (real TTS in es-MX,
/// where available) while a big sticker-style card displays it. Tap the
/// card or Rhenné to repeat the sound; arrows below to navigate.
class AlphabetGame extends LaraGame {
  AlphabetGame() : super(gradient: LaraGradients.party);

  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  int _index = 0;
  LetterCard? _card;
  SpeakingRhenne? _rhenne;
  NavArrow? _prevArrow;
  NavArrow? _nextArrow;
  TextComponent? _phoneticText;
  TextComponent? _progressText;
  TextComponent? _hintText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final rhenneSprite = await loadSprite('rhenne.png');
    await _setupTts();
    _layout(rhenneSprite);
    // Speak the very first letter shortly after load so it feels alive.
    Future<void>.delayed(const Duration(milliseconds: 350), _speakCurrent);
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setLanguage('es-MX');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.15);
      await _tts.setVolume(1.0);
      _ttsReady = true;
    } catch (_) {
      // TTS unavailable (e.g. unsupported web browser) — game still plays
      // silently with the visual phonetic bubble.
      _ttsReady = false;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_card != null) _placeAll();
  }

  @override
  void onRemove() {
    _tts.stop();
    super.onRemove();
  }

  void _layout(Sprite rhenneSprite) {
    final card = LetterCard(letter: mexicanAlphabet[_index]);
    _card = card;
    add(card);

    final rhenne = SpeakingRhenne(rhenneSprite);
    _rhenne = rhenne;
    add(rhenne);

    final phoneticText = TextComponent(
      text: _phonetic[mexicanAlphabet[_index]] ?? '',
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: LaraColors.magenta,
          letterSpacing: 1.4,
        ),
      ),
    );
    _phoneticText = phoneticText;
    add(phoneticText);

    final progressText = TextComponent(
      text: _progressLabel(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: [
            Shadow(offset: Offset(0, 2), blurRadius: 0, color: LaraColors.magenta),
          ],
        ),
      ),
    );
    _progressText = progressText;
    add(progressText);

    final hintText = TextComponent(
      text: 'Toca la letra para escuchar de nuevo',
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
    _hintText = hintText;
    add(hintText);

    final prevArrow = NavArrow(forward: false, onTap: previous);
    _prevArrow = prevArrow;
    add(prevArrow);
    final nextArrow = NavArrow(forward: true, onTap: next);
    _nextArrow = nextArrow;
    add(nextArrow);

    _placeAll();
  }

  double get _shortestSide => size.x < size.y ? size.x : size.y;

  void _placeAll() {
    final card = _card;
    final rhenne = _rhenne;
    if (card == null || rhenne == null) return;

    final cardSize = (_shortestSide * 0.6).clamp(180.0, 320.0);
    card.size = Vector2.all(cardSize);
    card.position = Vector2(size.x / 2, size.y * 0.36);

    final rhenneSize = (_shortestSide * 0.28).clamp(80.0, 160.0);
    rhenne.size = Vector2.all(rhenneSize);
    rhenne.position = Vector2(size.x / 2, size.y * 0.66 + rhenneSize / 2);

    _phoneticText?.position =
        Vector2(size.x / 2, size.y * 0.66 - 24);
    _progressText?.position = Vector2(size.x / 2, 64);
    _hintText?.position = Vector2(size.x / 2, size.y - 28);

    final arrowY = size.y * 0.36;
    final cardHalf = (_card?.size.x ?? 0) / 2;
    final inset = 32.0;
    _prevArrow?.position = Vector2(size.x / 2 - cardHalf - inset, arrowY);
    _nextArrow?.position = Vector2(size.x / 2 + cardHalf + inset, arrowY);
  }

  void onLetterTapped() => _speakCurrent();
  void onRhenneTapped() => _speakCurrent();

  void next() => _goto(_index + 1);
  void previous() => _goto(_index - 1);

  void _goto(int newIndex) {
    final clamped = newIndex % mexicanAlphabet.length;
    final wrapped = clamped < 0 ? clamped + mexicanAlphabet.length : clamped;
    if (wrapped == _index) return;
    _index = wrapped;
    final letter = mexicanAlphabet[_index];
    _card?.setLetter(letter);
    _phoneticText?.text = _phonetic[letter] ?? '';
    _progressText?.text = _progressLabel();
    _phoneticText?.add(
      ScaleEffect.by(
        Vector2.all(1.15),
        EffectController(
          duration: 0.18,
          alternate: true,
          reverseDuration: 0.18,
        ),
      ),
    );
    _speakCurrent();
  }

  String _progressLabel() => '${_index + 1} / ${mexicanAlphabet.length}';

  Future<void> _speakCurrent() async {
    final letter = mexicanAlphabet[_index];
    _rhenne?.croak();
    if (!_ttsReady) return;
    try {
      await _tts.stop();
      await _tts.speak(letter);
    } catch (_) {
      // Ignore — visual feedback still works.
    }
  }
}
