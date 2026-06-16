import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lara_demo/overlays/game_over_overlay.dart';
import 'package:lara_demo/overlays/points_overlay.dart';
import 'package:lara_demo/widgets/audio_mode_button.dart';
import '../overlays/coin_reward_overlay.dart';
import 'lara_audio.dart';
import 'lara_base_game.dart';

typedef GameOverOverlayBuilder =
    Widget Function(BuildContext context, LaraBaseGame game, VoidCallback onRestart, VoidCallback onHome);

class GameScaffold extends StatefulWidget {
  const GameScaffold({
    super.key,
    required this.title,
    required this.builder,
    this.scoreLabel = 'Puntos',
    this.gameOverBuilder,

    this.additionalOverlays,
  });

  final String title;
  final LaraBaseGame Function() builder;
  final String scoreLabel;
  final GameOverOverlayBuilder? gameOverBuilder;
  final Map<String, Widget Function(BuildContext, LaraBaseGame)>? additionalOverlays;

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  late LaraBaseGame _game = widget.builder();
  bool _coinPhaseComplete = false;

  @override
  void dispose() {
    LaraAudio.stopBgm();
    super.dispose();
  }

  void _restart() {
    setState(() {
      _coinPhaseComplete = false;
      _game = widget.builder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [const AudioModeButton()]),
      body: GameWidget<LaraBaseGame>(
        key: ValueKey(_game),
        game: _game,
        overlayBuilderMap: {
          'hud': (context, game) => PointsOverlay(label: widget.scoreLabel, score: game.points),
          ...?widget.additionalOverlays,
          'gameOver': (context, game) {
            // Phase A: show coin reward before game-over if configured.

            if (!_coinPhaseComplete) {
              return CoinRewardOverlay(coins: game.coins, onContinue: () => setState(() => _coinPhaseComplete = true));
            }
            
            void restart() {
              game.clearGameOver();
              _restart();
            }

            void home() => Navigator.of(context).pop();
            final custom = widget.gameOverBuilder;
            if (custom != null) {
              return custom(context, game, restart, home);
            }

            final topEntries = [
              LeaderboardEntry(name: 'Lara', score: 1200),
              LeaderboardEntry(name: 'Mateo', score: 950),
              LeaderboardEntry(name: 'Sofía', score: 800),
              LeaderboardEntry(name: 'Lucas', score: 650),
              LeaderboardEntry(name: 'Elena', score: 500),
            ];

            final justPlayedRank = topEntries.where((entry) => entry.score > game.points).length + 1;

            return GameOverOverlay(
              title: game.gameOverMessage ?? '¡Bien hecho!',
              subtitle: 'Puntuación: ${game.points}',
              rankMessageBuilder: (rank, isTopFive) {
                return isTopFive ? '¡Entraste al Top 5! 🎉' : '¡Tu posición es la #$rank!';
              },
              topEntries: topEntries,
              justPlayedEntry: LeaderboardEntry(name: 'Jugador', score: game.points),
              justPlayedRank: justPlayedRank,
              onRestart: restart,
              onHome: home,
            );
          },
        },
      ),
    );
  }
}
