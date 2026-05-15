import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'lara_button.dart';
import 'lara_game.dart';
import 'lara_theme.dart';

/// Signature for a custom game-over overlay. Receives the just-finished
/// game plus callbacks to restart or return to the menu.
typedef GameOverOverlayBuilder = Widget Function(
  BuildContext context,
  LaraGame game,
  VoidCallback onRestart,
  VoidCallback onHome,
);

/// Scaffold that hosts a [LaraGame] inside a [GameWidget], with the
/// shared HUD, pause, and game-over overlays already wired up.
class GameScaffold extends StatefulWidget {
  const GameScaffold({
    super.key,
    required this.title,
    required this.builder,
    this.scoreLabel = 'Puntos',
    this.gameOverBuilder,
  });

  final String title;
  final LaraGame Function() builder;
  final String scoreLabel;

  /// Optional override for the game-over overlay. When null, the default
  /// "¡Bien hecho!" card with restart + menu buttons is used.
  final GameOverOverlayBuilder? gameOverBuilder;

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  late LaraGame _game = widget.builder();

  void _restart() {
    setState(() {
      _game = widget.builder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Reiniciar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _restart,
          ),
        ],
      ),
      body: GameWidget<LaraGame>(
        key: ValueKey(_game),
        game: _game,
        overlayBuilderMap: {
          'hud': (context, game) => _HudOverlay(
                label: widget.scoreLabel,
                score: game.score,
              ),
          'gameOver': (context, game) {
            void restart() {
              game.clearGameOver();
              _restart();
            }
            void home() => Navigator.of(context).pop();
            final custom = widget.gameOverBuilder;
            if (custom != null) {
              return custom(context, game, restart, home);
            }
            return _GameOverOverlay(
              message: game.gameOverMessage ?? '¡Bien hecho!',
              onRestart: restart,
              onHome: home,
            );
          },
        },
      ),
    );
  }
}

class _HudOverlay extends StatelessWidget {
  const _HudOverlay({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: LaraColors.magenta.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$label: ', style: LaraTextStyles.hudScore),
              Text('$score', style: LaraTextStyles.hudScore),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.message,
    required this.onRestart,
    required this.onHome,
  });

  final String message;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          decoration: BoxDecoration(
            color: LaraColors.cream,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: LaraColors.magenta, width: 4),
            boxShadow: const [
              BoxShadow(offset: Offset(0, 6), blurRadius: 0, color: LaraColors.magenta),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: LaraColors.magenta,
                ),
              ),
              const SizedBox(height: 18),
              LaraButton(
                label: 'Jugar otra vez',
                icon: Icons.replay_rounded,
                onPressed: onRestart,
                fullWidth: true,
              ),
              const SizedBox(height: 14),
              LaraButton(
                label: 'Menú',
                color: LaraColors.mint,
                shadowColor: LaraColors.rhenneGreenDark,
                icon: Icons.home_rounded,
                onPressed: onHome,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
