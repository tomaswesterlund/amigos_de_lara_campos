import 'package:flutter/material.dart';
import '../widgets/lara_button.dart';
import '../core/lara_theme.dart';

class LeaderboardEntry {
  final String name;
  final int score;

  LeaderboardEntry({required this.name, required this.score});
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rankMessageBuilder,
    required this.topEntries,
    required this.justPlayedEntry,
    required this.justPlayedRank,
    required this.onRestart,
    required this.onHome,
    // Labels & Rules Configurations
    this.restartButtonLabel = 'Jugar otra vez',
    this.homeButtonLabel = 'Menú',
    this.restartButtonIcon = Icons.replay_rounded,
    this.homeButtonIcon = Icons.home_rounded,
    this.maxWidth = 360,
    this.maxTopEntriesToShow = 5,
  });

  final String title;
  final String subtitle;

  /// Callback to build the ranking text dynamically based on the current rank.
  final String Function(int rank, bool isTopFive) rankMessageBuilder;

  final List<LeaderboardEntry> topEntries;
  final LeaderboardEntry? justPlayedEntry;
  final int? justPlayedRank;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  // Layout Properties
  final String restartButtonLabel;
  final String homeButtonLabel;
  final IconData restartButtonIcon;
  final IconData homeButtonIcon;
  final double maxWidth;
  final int maxTopEntriesToShow;

  // Explicit, static brand parameters baked in as compile-time constants
  static const Color backgroundColor = LaraColors.cream;
  static const Color borderColor = LaraColors.magenta;
  static const Color textColor = LaraColors.ink;
  static const Color highlightColor = LaraColors.yellow;
  static const Color accentColor = LaraColors.magenta;
  static const Color secondaryAccentColor = LaraColors.galletaBrown;

  @override
  Widget build(BuildContext context) {
    final entries = topEntries.take(maxTopEntriesToShow).toList();
    final myRank = justPlayedRank;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 4),
            boxShadow: const [BoxShadow(offset: Offset(0, 6), blurRadius: 0, color: borderColor)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: accentColor),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
              ),
              if (myRank != null) ...[
                const SizedBox(height: 2),
                Text(
                  rankMessageBuilder(myRank, myRank <= entries.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryAccentColor),
                ),
              ],
              const SizedBox(height: 14),
              ...entries.asMap().entries.map((e) {
                final rank = e.key + 1;
                final entry = e.value;
                return _LeaderboardRow(
                  rank: rank,
                  entry: entry,
                  highlight: justPlayedEntry != null && identical(entry, justPlayedEntry),
                );
              }),
              if (myRank != null && myRank > entries.length && justPlayedEntry != null) ...[
                const _DividerDots(color: secondaryAccentColor),
                _LeaderboardRow(rank: myRank, entry: justPlayedEntry!, highlight: true),
              ],
              const SizedBox(height: 16),
              LaraButton(label: restartButtonLabel, icon: restartButtonIcon, onPressed: onRestart, fullWidth: true),
              const SizedBox(height: 14),
              LaraButton(
                label: homeButtonLabel,
                color: LaraColors.mint,
                shadowColor: LaraColors.rhenneGreenDark,
                icon: homeButtonIcon,
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
  const _LeaderboardRow({required this.rank, required this.entry, required this.highlight});

  final int rank;
  final LeaderboardEntry entry;
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
        color: highlight ? GameOverOverlay.highlightColor : GameOverOverlay.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? GameOverOverlay.borderColor : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              medal,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GameOverOverlay.textColor),
            ),
          ),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
                color: GameOverOverlay.textColor,
              ),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GameOverOverlay.accentColor),
          ),
        ],
      ),
    );
  }
}

class _DividerDots extends StatelessWidget {
  const _DividerDots({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '· · ·',
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}
