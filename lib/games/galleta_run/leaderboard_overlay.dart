import 'package:flutter/material.dart';

import '../../widgets/lara_button.dart';
import '../../core/lara_theme.dart';
import 'leaderboard.dart';

/// Game-over overlay for Galleta Corre. Shows the in-memory leaderboard
/// (top 5) and highlights the just-played run.
class GalletaRunLeaderboardOverlay extends StatelessWidget {
  const GalletaRunLeaderboardOverlay({
    super.key,
    required this.finalScore,
    required this.justPlayed,
    required this.onRestart,
    required this.onHome,
  });

  final int finalScore;
  final GalletaRunEntry? justPlayed;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final entries = GalletaRunLeaderboard.topEntries.take(5).toList();
    final myRank =
        justPlayed == null ? null : GalletaRunLeaderboard.rankOf(justPlayed!);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: LaraColors.cream,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: LaraColors.galletaBrown, width: 4),
            boxShadow: const [
              BoxShadow(offset: Offset(0, 6), blurRadius: 0, color: LaraColors.galletaBrown),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tabla de Galletas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: LaraColors.galletaBrown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '¡Lupita consiguió $finalScore puntos!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LaraColors.ink,
                ),
              ),
              if (myRank != null) ...[
                const SizedBox(height: 2),
                Text(
                  myRank <= entries.length
                      ? 'Lugar #$myRank en la tabla'
                      : 'Sigue corriendo — lugar #$myRank',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LaraColors.galletaBrown,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ...entries.asMap().entries.map((e) {
                final rank = e.key + 1;
                final entry = e.value;
                return _LeaderboardRow(
                  rank: rank,
                  entry: entry,
                  highlight: identical(entry, justPlayed),
                );
              }),
              if (myRank != null && myRank > entries.length) ...[
                const _DividerDots(),
                _LeaderboardRow(
                  rank: myRank,
                  entry: justPlayed!,
                  highlight: true,
                ),
              ],
              const SizedBox(height: 16),
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

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.highlight,
  });

  final int rank;
  final GalletaRunEntry entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? LaraColors.yellow : LaraColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? LaraColors.galletaBrown : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              medal,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: LaraColors.ink,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    highlight ? FontWeight.w900 : FontWeight.w700,
                color: LaraColors.ink,
              ),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: LaraColors.galletaBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerDots extends StatelessWidget {
  const _DividerDots();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '· · ·',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: LaraColors.galletaBrown,
        ),
      ),
    );
  }
}
