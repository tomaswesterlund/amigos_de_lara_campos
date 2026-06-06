// import 'package:flame/components.dart';
// import 'package:flame/text.dart';
// import 'package:flutter/material.dart';

// import '../../shared/lara_audio.dart';
// import '../../shared/lara_base_game.dart';
// import '../../shared/lara_theme.dart';
// import 'beat_charts.dart';
// import 'components/beat_note.dart';
// import 'components/hit_zone.dart';

// /// 4-lane rhythm mini-game. Notes fall toward a hit zone in sync with the
// /// corazón BGM track (128 BPM). Hit windows are time-based (±50 / ±100 ms),
// /// matching the MIDI-style beat chart in [corazonChart].
// class RhythmTapGame extends LaraBaseGame {
//   RhythmTapGame()
//       : super(gradient: LaraGradients.party, bgm: LaraBgm.corazon);

//   static const _lanes = 4;
//   static const _noteSpeed = 320.0;
//   static const _gameDuration = 35.0;

//   // Hit windows in seconds (±)
//   static const _windowPerfect = 0.050;
//   static const _windowGood    = 0.100;
//   static const _windowOk      = 0.150;

//   late final List<Sprite> _noteSprites;
//   double _elapsed  = 0;
//   int    _nextNote = 0; // index into corazonChart
//   int    _score    = 0;
//   bool   _running  = true;
//   final  _hitZones = <HitZone>[];
//   TextComponent? _feedback;

//   static const _laneColors = [
//     LaraColors.pink,
//     LaraColors.mint,
//     LaraColors.yellow,
//     LaraColors.rhenneGreen,
//   ];

//   double get _laneWidth  => size.x / _lanes;
//   double get _hitZoneY   => size.y * 0.78;

//   // Seconds for a note to travel from spawn (y = -30) to hit zone.
//   double get _travelTime => (_hitZoneY + 30) / _noteSpeed;

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     _noteSprites = await Future.wait([
//       loadSprite('corazon.png'),
//       loadSprite('corazon_pink.png'),
//       loadSprite('corazon_yellow.png'),
//       loadSprite('music_note.png'),
//     ]);
//     _buildHitZones();
//   }

//   void _buildHitZones() {
//     for (final z in _hitZones) {
//       z.removeFromParent();
//     }
//     _hitZones.clear();
//     for (var i = 0; i < _lanes; i++) {
//       final z = HitZone(
//         lane: i,
//         color: _laneColors[i],
//         onTap: () => _evaluateTap(i),
//       )
//         ..size     = Vector2(_laneWidth - 8, 70)
//         ..anchor   = Anchor.center
//         ..position = Vector2(_laneWidth * (i + 0.5), _hitZoneY);
//       _hitZones.add(z);
//       add(z);
//     }
//   }

//   @override
//   void onGameResize(Vector2 size) {
//     super.onGameResize(size);
//     if (_hitZones.isNotEmpty) _buildHitZones();
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     if (!_running) return;
//     _elapsed += dt;

//     if (_elapsed >= _gameDuration) {
//       _running = false;
//       showGameOver('¡Bien hecho!\nPuntos: $_score', () {});
//       return;
//     }

//     // Spawn notes from the beat chart when their arrival time minus travel
//     // time matches the current elapsed position.
//     while (_nextNote < corazonChart.length &&
//            corazonChart[_nextNote].time - _travelTime <= _elapsed) {
//       _spawnNote(corazonChart[_nextNote]);
//       _nextNote++;
//     }
//   }

//   void _spawnNote(BeatEvent event) {
//     final sprite = _noteSprites[event.lane % _noteSprites.length];
//     add(BeatNote(
//       lane:      event.lane,
//       chartTime: event.time,
//       sprite:    sprite,
//       speed:     _noteSpeed,
//     )
//       ..size     = Vector2.all(58)
//       ..anchor   = Anchor.center
//       ..position = Vector2(_laneWidth * (event.lane + 0.5), -30));
//   }

//   void _evaluateTap(int lane) {
//     if (!_running) return;

//     // Find the chart-closest unconsumed note in this lane.
//     BeatNote? closest;
//     double bestDiff = double.infinity;
//     for (final n in children.whereType<BeatNote>()) {
//       if (n.lane != lane || n.consumed) continue;
//       final diff = (_elapsed - n.chartTime).abs();
//       if (diff < bestDiff) {
//         bestDiff = diff;
//         closest  = n;
//       }
//     }

//     if (closest == null || bestDiff > _windowOk) {
//       _flashFeedback('¡Ay!', LaraColors.magenta);
//       LaraAudio.playSfx(LaraSfx.miss);
//       return;
//     }

//     closest.consumed = true;
//     closest.removeFromParent();

//     if (bestDiff <= _windowPerfect) {
//       _score += 100;
//       _flashFeedback('¡Perfecto!', LaraColors.rhenneGreen);
//       LaraAudio.playSfx(LaraSfx.hitPerfect);
//     } else if (bestDiff <= _windowGood) {
//       _score += 50;
//       _flashFeedback('¡Bien!', LaraColors.yellow);
//       LaraAudio.playSfx(LaraSfx.hitGood);
//     } else {
//       _score += 20;
//       _flashFeedback('Ok', LaraColors.mint);
//       LaraAudio.playSfx(LaraSfx.hitGood);
//     }
//     setScore(_score);
//   }

//   void onNoteMissed(BeatNote note) {
//     if (!_running) return;
//     _flashFeedback('Falló', LaraColors.magenta);
//   }

//   void _flashFeedback(String text, Color color) {
//     _feedback?.removeFromParent();
//     final fb = TextComponent(
//       text: text,
//       anchor: Anchor.center,
//       position: Vector2(size.x / 2, size.y * 0.4),
//       textRenderer: TextPaint(
//         style: TextStyle(
//           fontSize: 36,
//           fontWeight: FontWeight.w900,
//           color: color,
//           shadows: const [
//             Shadow(offset: Offset(0, 2), blurRadius: 0, color: Colors.white),
//           ],
//         ),
//       ),
//     );
//     _feedback = fb;
//     add(fb);
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (fb.isMounted) fb.removeFromParent();
//     });
//   }
// }
