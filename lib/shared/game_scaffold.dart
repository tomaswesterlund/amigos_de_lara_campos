import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'coin_reward_overlay.dart';
import 'lara_audio.dart';
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
    this.coinReward,
  });

  final String title;
  final LaraGame Function() builder;
  final String scoreLabel;

  /// Optional override for the game-over overlay. When null, the default
  /// "¡Bien hecho!" card with restart + menu buttons is used.
  final GameOverOverlayBuilder? gameOverBuilder;

  /// If set, a coin reward modal is shown first (before the game-over overlay).
  /// The function receives the finished game and returns the number of coins earned.
  final int Function(LaraGame game)? coinReward;

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  late LaraGame _game = widget.builder();
  bool _coinPhaseComplete = false;

  void _restart() {
    setState(() {
      _coinPhaseComplete = false;
      _game = widget.builder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [const _AudioModeButton()],
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
            // Phase A: show coin reward before game-over if configured.
            if (widget.coinReward != null && !_coinPhaseComplete) {
              return CoinRewardOverlay(
                coins: widget.coinReward!(game),
                onContinue: () => setState(() => _coinPhaseComplete = true),
              );
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

// ─── 3-state audio mode button ────────────────────────────────────────────────

class _AudioModeButton extends StatefulWidget {
  const _AudioModeButton();

  @override
  State<_AudioModeButton> createState() => _AudioModeButtonState();
}

class _AudioModeButtonState extends State<_AudioModeButton> {
  static IconData _icon(AudioMode m) => switch (m) {
        AudioMode.on     => Icons.volume_up_rounded,
        AudioMode.bgmOff => Icons.music_off_rounded,
        AudioMode.off    => Icons.volume_off_rounded,
      };

  static String _tooltip(AudioMode m) => switch (m) {
        AudioMode.on     => 'Todo encendido',
        AudioMode.bgmOff => 'Música apagada',
        AudioMode.off    => 'Todo silenciado',
      };

  @override
  Widget build(BuildContext context) {
    final mode = LaraAudio.mode;
    return IconButton(
      tooltip: _tooltip(mode),
      icon: Icon(_icon(mode)),
      onPressed: () {
        LaraAudio.cycleMode();
        setState(() {});
      },
    );
  }
}

// ─── HUD overlay ─────────────────────────────────────────────────────────────

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

// ─── Game-over overlay ───────────────────────────────────────────────────────

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
