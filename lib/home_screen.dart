import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import 'collectibles_screen.dart';
import 'concert_screen.dart';
import 'matilda_screen.dart';
import 'games/alphabet/alphabet_game.dart';
import 'shared/coin_wallet.dart';
import 'shared/daily_bonus_dialog.dart';
import 'shared/game_unlock_state.dart';
import 'games/galleta_catch/galleta_catch_game.dart';
import 'games/galleta_maze/galleta_maze_game.dart';
import 'games/galleta_run/galleta_run_game.dart';
import 'games/galleta_run/leaderboard_overlay.dart';
import 'games/memory_match/memory_match_game.dart';
import 'games/memory_match/memory_match_leaderboard_overlay.dart';
import 'games/rhenne_fly/rhenne_fly_game.dart';
import 'games/rhenne_jump/rhenne_jump_game.dart';
import 'games/rhenne_run/leaderboard_overlay.dart';
import 'games/rhenne_run/rhenne_run_game.dart';
import 'games/rhythm_tap/rhythm_tap_game.dart';
import 'games/tap_the_heart/tap_heart_game.dart';
import 'games/tap_the_heart/tap_heart_leaderboard_overlay.dart';
import 'shared/coin_shop.dart';
import 'shared/game_scaffold.dart';
import 'shared/lara_audio.dart';
import 'shared/lara_game.dart';
import 'shared/lara_theme.dart';

Color _darken(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _headerTaps = 0;
  bool _allVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) DailyBonusDialog.showIfNeeded(context);
    });
  }

  void _onHeaderTap() {
    setState(() => _headerTaps++);
    if (_headerTaps == 10) {
      setState(() => _allVisible = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modo desarrollador activado'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  List<_GameTile> get _visibleTiles {
    final always = [
      _GameTile(
        title: 'Rhenné Corre',
        tagline: '¡Ayúdale a Rhenné llegar a Lara!',
        spriteAsset: 'rhenne.png',
        color: LaraColors.rhenneGreenDark,
        builder: RhenneRunGame.new,
        coinReward: (g) => 1 + (g.score > 200 ? 1 : 0) + (g.score > 500 ? 1 : 0),
        gameOverBuilder: (context, game, restart, home) {
          final run = game as RhenneRunGame;
          return LeaderboardOverlay(
            finalScore: run.score,
            justPlayed: run.lastEntry,
            onRestart: restart,
            onHome: home,
          );
        },
      ),
      _GameTile(
        title: 'Galleta Corre',
        tagline: '¡Galleta se perdió — ayúdala llegar al concierto de Lara!',
        spriteAsset: 'galleta.png',
        color: LaraColors.galletaBrown,
        builder: GalletaRunGame.new,
        coinReward: (g) => 1 + (g.score > 300 ? 1 : 0),
        gameOverBuilder: (context, game, restart, home) {
          final run = game as GalletaRunGame;
          return GalletaRunLeaderboardOverlay(
            finalScore: run.score,
            justPlayed: run.lastEntry,
            onRestart: restart,
            onHome: home,
          );
        },
      ),
      _GameTile(
        title: 'Atrapa Corazones',
        tagline: '¡Lara lanzó sus corazones al público — no dejes caer ninguno!',
        spriteAsset: 'corazon.png',
        color: LaraColors.corazonRed,
        builder: TapHeartGame.new,
        coinReward: (g) => 1,
        gameOverBuilder: (context, game, restart, home) {
          final tap = game as TapHeartGame;
          return TapHeartLeaderboardOverlay(
            finalScore: tap.lastEntry?.score ?? 0,
            justPlayed: tap.lastEntry,
            onRestart: restart,
            onHome: home,
          );
        },
      ),
      _GameTile(
        title: 'Memoria Amigos',
        tagline: '¡Lara escondió fotos de sus amigos — encuéntralas en parejas!',
        spriteAsset: 'card_back.png',
        color: LaraColors.pink,
        unlockKey: 'memory_match',
        scoreLabel: 'Movimientos',
        builder: MemoryMatchGame.new,
        coinReward: (g) => 2 + (g.score <= 12 ? 1 : 0),
        gameOverBuilder: (context, game, restart, home) {
          final mem = game as MemoryMatchGame;
          return MemoryMatchLeaderboardOverlay(
            finalMoves: mem.lastEntry?.moves ?? 0,
            justPlayed: mem.lastEntry,
            onRestart: restart,
            onHome: home,
          );
        },
      ),
    ];

    if (!_allVisible) return always;

    return [
      _GameTile(
        title: 'Rhenné Salta',
        tagline: '¡Rhenné quiere ver a Reina — ayúdale a cruzar los lirios!',
        spriteAsset: 'rhenne.png',
        color: LaraColors.rhenneGreen,
        builder: RhenneJumpGame.new,
        coinReward: (g) => 1 + (g.score > 10 ? 1 : 0),
      ),
      ...always,
      _GameTile(
        title: 'Ritmo Lara',
        tagline: '¡Lara está cantando — sigue su ritmo sin perder el beat!',
        spriteAsset: 'music_note.png',
        color: LaraColors.magenta,
        builder: RhythmTapGame.new,
        coinReward: (g) => 1 + (g.score > 50 ? 1 : 0),
      ),
      _GameTile(
        title: 'Galleta Atrapa',
        tagline: '¡Lara le tiró snacks a Galleta — ayúdale a atraparlos todos!',
        spriteAsset: 'treat_bone.png',
        color: LaraColors.yellow,
        builder: GalletaCatchGame.new,
        coinReward: (g) => 1,
      ),
      _GameTile(
        title: 'Rhenné Vuela',
        tagline: '¡Rhenné aprendió a volar para llegar antes al show de Lara!',
        spriteAsset: 'rhenne.png',
        color: LaraColors.mint,
        builder: RhenneFlyGame.new,
      ),
      _GameTile(
        title: 'Galleta Laberinto',
        tagline: '¡Galleta escondió sus huesos en el laberinto — recóbralos antes que llegue la roca!',
        spriteAsset: 'galleta.png',
        color: LaraColors.galletaBrown,
        builder: GalletaMazeGame.new,
      ),
      _GameTile(
        title: 'Abecedario con Rhenné',
        tagline: '¡Rhenné y Lara te enseñan el abecedario — repite con ellos!',
        spriteAsset: 'rhenne.png',
        color: LaraColors.yellow,
        builder: AlphabetGame.new,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _visibleTiles;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LaraGradients.party),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverToBoxAdapter(child: _CoinDisplay()),
              SliverToBoxAdapter(child: _Header(onTap: _onHeaderTap)),
              const SliverToBoxAdapter(child: _MatildaBanner()),
              const SliverToBoxAdapter(child: _AdBanner()),
              const SliverToBoxAdapter(child: _CollectiblesBanner()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverList.separated(
                  itemCount: tiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _GameTileCard(tile: tiles[i]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: defaultTargetPlatform == TargetPlatform.android ? 48 : 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('¡Hola Amiguitos!', style: LaraTextStyles.titleHuge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Mini-juegos con Rhenné, Galleta y Corazón',
              style: LaraTextStyles.tagline.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTile {
  const _GameTile({
    required this.title,
    required this.tagline,
    required this.spriteAsset,
    required this.color,
    required this.builder,
    this.gameOverBuilder,
    this.unlockKey,
    this.scoreLabel = 'Puntos',
    this.coinReward,
  });

  final String title;
  final String tagline;
  final String spriteAsset;
  final Color color;
  final LaraGame Function() builder;
  final GameOverOverlayBuilder? gameOverBuilder;
  /// Non-null means the game must be purchased before playing.
  final String? unlockKey;
  final String scoreLabel;
  /// If set, coins are awarded via [CoinRewardOverlay] before the game-over card.
  final int Function(LaraGame)? coinReward;
}

class _GameTileCard extends StatefulWidget {
  const _GameTileCard({required this.tile});

  final _GameTile tile;

  @override
  State<_GameTileCard> createState() => _GameTileCardState();
}

class _GameTileCardState extends State<_GameTileCard> {
  bool _pressed = false;
  bool _unlocked = false;
  static const _depth = 5.0;

  bool get _isLocked => !_unlocked;

  @override
  void initState() {
    super.initState();
    final key = widget.tile.unlockKey;
    _unlocked = key == null || GameUnlockState.isUnlocked(key);
  }

  Future<void> _handleTap(BuildContext context) async {
    if (!_isLocked) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameScaffold(
            title: widget.tile.title,
            builder: widget.tile.builder,
            gameOverBuilder: widget.tile.gameOverBuilder,
            scoreLabel: widget.tile.scoreLabel,
            coinReward: widget.tile.coinReward,
          ),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    final purchased = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GamePurchaseSheet(tile: widget.tile),
    );
    if (purchased == true && mounted) {
      setState(() => _unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        LaraAudio.playSfx(LaraSfx.button);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _handleTap(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
        decoration: BoxDecoration(
          color: widget.tile.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, _pressed ? 0 : _depth),
              blurRadius: 0,
              color: _darken(widget.tile.color),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: _isLocked ? 0.12 : 0.28),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Opacity(
                      opacity: _isLocked ? 0.45 : 1.0,
                      child: Image.asset(
                        'assets/images/${widget.tile.spriteAsset}',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (_isLocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.tile.title,
                      style: LaraTextStyles.titleCard,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tile.tagline,
                      style: LaraTextStyles.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_isLocked) ...[
                      const SizedBox(height: 6),
                      _CostBadge(cost: GameUnlockState.costs[widget.tile.unlockKey]!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                _isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Locked-game cost badge ───────────────────────────────────────────────────

class _CostBadge extends StatelessWidget {
  const _CostBadge({required this.cost});

  final int cost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: LaraColors.yellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LaraColors.galletaBrown, width: 1.5),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 2), blurRadius: 0, color: LaraColors.galletaBrown),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: LaraColors.galletaBrown, size: 14),
          const SizedBox(width: 3),
          Text(
            '$cost',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: LaraColors.galletaBrown,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Purchase bottom sheet ────────────────────────────────────────────────────

class _GamePurchaseSheet extends StatelessWidget {
  const _GamePurchaseSheet({required this.tile});

  final _GameTile tile;

  @override
  Widget build(BuildContext context) {
    final cost = GameUnlockState.costs[tile.unlockKey]!;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      child: ValueListenableBuilder<int>(
        valueListenable: CoinWallet.balance,
        builder: (context, balance, _) {
          final canAfford = balance >= cost;
          final shortfall = cost - balance;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LaraColors.cream,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Game header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: tile.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/${tile.spriteAsset}',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tile.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: LaraColors.magenta,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¡Desbloquea este juego!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: LaraColors.galletaBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Cost badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: LaraColors.yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LaraColors.yellow, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: LaraColors.galletaBrown, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$cost monedas',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: LaraColors.galletaBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu saldo: $balance monedas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: canAfford ? LaraColors.rhenneGreenDark : LaraColors.corazonRed,
                ),
              ),
              const SizedBox(height: 20),
              // Coin shop section — shown when the player can't afford it yet
              if (!canAfford) ...[
                Text(
                  'Te faltan $shortfall monedas — compra un paquete:',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LaraColors.galletaBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _InlineCoinButton(
                  amount: 100,
                  color: LaraColors.rhenneGreen,
                  shadowColor: LaraColors.rhenneGreenDark,
                ),
                const SizedBox(height: 10),
                _InlineCoinButton(
                  amount: 500,
                  color: LaraColors.magenta,
                  shadowColor: LaraColors.magentaDark,
                ),
                const SizedBox(height: 20),
              ],
              // Unlock button — shown only when player can afford
              if (canAfford) ...[
                _UnlockButton(
                  color: tile.color,
                  onTap: () {
                    LaraAudio.playSfx(LaraSfx.unlock);
                    final success = GameUnlockState.unlock(tile.unlockKey!);
                    Navigator.of(context).pop(success);
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: LaraColors.galletaBrown,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Inline coin purchase button (used inside _GamePurchaseSheet) ─────────────

class _InlineCoinButton extends StatefulWidget {
  const _InlineCoinButton({
    required this.amount,
    required this.color,
    required this.shadowColor,
  });

  final int amount;
  final Color color;
  final Color shadowColor;

  @override
  State<_InlineCoinButton> createState() => _InlineCoinButtonState();
}

class _InlineCoinButtonState extends State<_InlineCoinButton> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        LaraAudio.playSfx(LaraSfx.button);
        CoinWallet.add(widget.amount);
        LaraAudio.playSfx(LaraSfx.coin);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.shadowColor, width: 3),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, _pressed ? 0 : _depth),
              blurRadius: 0,
              color: widget.shadowColor,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.amount} monedas',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.amount == 500 ? '¡Mejor valor!' : 'Paquete básico',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.star_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Unlock button ────────────────────────────────────────────────────────────

class _UnlockButton extends StatefulWidget {
  const _UnlockButton({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  State<_UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<_UnlockButton> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    final shadowColor = _darken(widget.color);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: shadowColor, width: 3),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, _pressed ? 0 : _depth),
              blurRadius: 0,
              color: shadowColor,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_rounded, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              '¡Desbloquear!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coin display + mute toggle row ──────────────────────────────────────────

class _CoinDisplay extends StatelessWidget {
  const _CoinDisplay();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => showCoinShop(context),
            child: ValueListenableBuilder<int>(
              valueListenable: CoinWallet.balance,
              builder: (context, balance, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: LaraColors.yellow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: LaraColors.galletaBrown, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 3),
                      blurRadius: 0,
                      color: LaraColors.galletaBrown,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: LaraColors.galletaBrown,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: LaraColors.galletaBrown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.add_circle_rounded,
                      color: LaraColors.galletaBrown,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const _MuteButton(),
        ],
      ),
    );
  }
}

// ─── Mute toggle button ───────────────────────────────────────────────────────

class _MuteButton extends StatefulWidget {
  const _MuteButton();

  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton> {
  static IconData _icon(AudioMode m) => switch (m) {
        AudioMode.on     => Icons.volume_up_rounded,
        AudioMode.bgmOff => Icons.music_off_rounded,
        AudioMode.off    => Icons.volume_off_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LaraAudio.cycleMode();
        setState(() {});
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Icon(
          _icon(LaraAudio.mode),
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ─── Ad banner ────────────────────────────────────────────────────────────────

class _AdBanner extends StatelessWidget {
  const _AdBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ConcertScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LaraGradients.sunny,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LaraColors.yellow, width: 3),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 0,
              color: LaraColors.galletaBrown,
            ),
          ],
        ),
        child: const Row(
          children: [
            Text('🎤', style: TextStyle(fontSize: 26)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Lara Campos cantará en Pachuca este fin de semana!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}

// ─── Matilda banner ───────────────────────────────────────────────────────────

class _MatildaBanner extends StatelessWidget {
  const _MatildaBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MatildaScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A0DAD), Color(0xFF9B59B6)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4A0FF), width: 3),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 0,
              color: Color(0xFF4A0080),
            ),
          ],
        ),
        child: const Row(
          children: [
            Text('🎭', style: TextStyle(fontSize: 26)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Matilda El Musical llega a México!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}

// ─── Section divider ──────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: Colors.white54, thickness: 1.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: LaraColors.cream,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🎮 Mini-juegos',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: LaraColors.magenta,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: Colors.white54, thickness: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Collectibles banner ──────────────────────────────────────────────────────

class _CollectiblesBanner extends StatefulWidget {
  const _CollectiblesBanner();

  @override
  State<_CollectiblesBanner> createState() => _CollectiblesBannerState();
}

class _CollectiblesBannerState extends State<_CollectiblesBanner> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CollectiblesScreen(),
            ),
          );
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
          decoration: BoxDecoration(
            gradient: LaraGradients.pond,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, _pressed ? 0 : _depth),
                blurRadius: 0,
                color: _darken(LaraColors.mint),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Coleccionables', style: LaraTextStyles.titleCard),
                    SizedBox(height: 4),
                    Text(
                      'Desbloquea figuras de Rhenné, Galleta y Corazón',
                      style: LaraTextStyles.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
