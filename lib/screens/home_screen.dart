import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:lara_demo/shared/color_util.dart';
import 'package:lara_demo/widgets/badges/countdown_badge.dart';
import 'package:lara_demo/widgets/buttons/inline_coin_button.dart';
import 'package:lara_demo/widgets/buttons/unlock_button.dart';
import 'package:lara_demo/widgets/coin_display.dart';
import 'package:lara_demo/widgets/badges/cost_badge.dart';

import 'collectibles_screen.dart';
import 'concert_screen.dart';
import '../matilda_screen.dart';
import '../widgets/coin_wallet.dart';
import '../widgets/daily_bonus_dialog.dart';
import '../widgets/game_unlock_state.dart';
import '../games/galleta_runs_game.dart';
import '../games/memory_match/memory_match_game.dart';
import '../games/memory_match/memory_match_leaderboard_overlay.dart';
import '../games/rhenne_jumps_game.dart';
import '../games/tap_the_heart/tap_heart_game.dart';
import '../games/tap_the_heart/tap_heart_leaderboard_overlay.dart';
import '../core/game_scaffold.dart';
import '../core/lara_audio.dart';
import '../widgets/lara_button.dart';
import '../core/lara_base_game.dart';
import '../core/lara_theme.dart';

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

  List<_GameTile> get _visibleTiles {
    final always = [
      _GameTile(
        title: 'Rhenné Brinca',
        tagline: '¡Rhenné brinca entre lirios — esquiva la lluvia y atrapa luciérnagas!',
        spriteAsset: 'assets/images/icons/icon_rhenne.png',
        color: LaraColors.rhenneGreen,
        builder: () => RhenneJumpsGame(), // RhenneJumpsGame.new,
        // coinReward: (g) => (g as RhenneJumpsGame).coinsCollected,
      ),
      _GameTile(
        title: 'Galleta Corre',
        tagline: '¡Galleta se perdió — ayúdala llegar al concierto de Lara!',
        spriteAsset: 'assets/images/icons/icon_galleta.png',
        color: LaraColors.galletaBrown,
        builder: () => GalletaRunsGame(),
        // coinReward: (g) => (g as GalletaRunsGame).coinsCollected,
        // gameOverBuilder: (context, game, restart, home) {
        //   final run = game as GalletaRunsGame;
        //   return GalletaRunLeaderboardOverlay(
        //     finalScore: run.score,
        //     justPlayed: run.lastEntry,
        //     onRestart: restart,
        //     onHome: home,
        //   );
        // },
      ),
      _GameTile(
        title: 'Memoria Amigos',
        tagline: '¡Lara escondió fotos de sus amigos — encuéntralas en parejas!',
        spriteAsset: 'assets/images/card_back.png',
        color: LaraColors.pink,
        unlockKey: 'memory_match',
        scoreLabel: 'Movimientos',
        builder: MemoryMatchGame.new,
        coinReward: (g) => 1,
        gameOverBuilder: (context, game, restart, home) {
          final mem = game as MemoryMatchGame;
          return MemoryMatchLeaderboardOverlay(
            finalMoves: mem.lastEntry?.moves ?? 0,
            justPlayed: mem.lastEntry,
            onRestart: restart,
            onHome: home,
          );
        },
        additionalOverlays: {
          'difficultyConfirm': (context, game) {
            final g = game as MemoryMatchGame;
            return _DifficultyConfirmOverlay(onConfirm: g.confirmDifficulty, onCancel: g.cancelDifficulty);
          },
        },
      ),
      _GameTile(
        title: 'Atrapa Corazones',
        tagline: '¡Lara lanzó sus corazones al público — no dejes caer ninguno!',
        // spriteAsset: 'corazon.png',
        spriteAsset: 'assets/images/collectibles/heart/heart_l3.png',
        color: LaraColors.corazonRed,
        timeLockUntil: DateTime.now().add(Duration(days: 7)),
        builder: TapHeartGame.new,
        coinReward: (g) => (g as TapHeartGame).coinsCollected,
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
    ];

    if (!_allVisible) return always;

    return [
      _GameTile(
        title: 'Rhenné Salta',
        tagline: '¡Rhenné quiere ver a Reina — ayúdale a cruzar los lirios!',
        // spriteAsset: 'rhenne.png',
        spriteAsset: '/images/collectibles/galleta/galleta_l1.png',
        color: LaraColors.rhenneGreen,
        builder: RhenneJumpsGame.new,
        coinReward: (g) => 1 + (g.points > 10 ? 1 : 0),
      ),
      ...always,
      // _GameTile(
      //   title: 'Ritmo Lara',
      //   tagline: '¡Lara está cantando — sigue su ritmo sin perder el beat!',
      //   spriteAsset: 'music_note.png',
      //   color: LaraColors.magenta,
      //   builder: RhythmTapGame.new,
      //   coinReward: (g) => 1 + (g.score > 50 ? 1 : 0),
      // ),
      // _GameTile(
      //   title: 'Galleta Atrapa',
      //   tagline: '¡Lara le tiró snacks a Galleta — ayúdale a atraparlos todos!',
      //   spriteAsset: 'treat_bone.png',
      //   color: LaraColors.yellow,
      //   builder: GalletaCatchGame.new,
      //   coinReward: (g) => 1,
      // ),
      // _GameTile(
      //   title: 'Rhenné Vuela',
      //   tagline: '¡Rhenné aprendió a volar para llegar antes al show de Lara!',
      //   spriteAsset: 'rhenne.png',
      //   color: LaraColors.mint,
      //   builder: RhenneFlyGame.new,
      // ),
      // _GameTile(
      //   title: 'Galleta Laberinto',
      //   tagline: '¡Galleta escondió sus huesos en el laberinto — recóbralos antes que llegue la roca!',
      //   spriteAsset: 'galleta.png',
      //   color: LaraColors.galletaBrown,
      //   builder: GalletaMazeGame.new,
      // ),
      // _GameTile(
      //   title: 'Abecedario con Rhenné',
      //   tagline: '¡Rhenné y Lara te enseñan el abecedario — repite con ellos!',
      //   spriteAsset: 'rhenne.png',
      //   color: LaraColors.yellow,
      //   builder: AlphabetGame.new,
      // ),
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
              const SliverToBoxAdapter(child: CoinDisplay()),
              const SliverToBoxAdapter(child: _MatildaBanner()),
              const SliverToBoxAdapter(child: _AdBanner()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              const SliverToBoxAdapter(child: _CollectiblesBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverList.separated(
                  itemCount: tiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _GameTileCard(tile: tiles[i]),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: defaultTargetPlatform == TargetPlatform.android ? 48 : 24)),
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
    this.timeLockUntil,
    this.scoreLabel = 'Puntos',
    this.coinReward,
    this.additionalOverlays,
  });

  final String title;
  final String tagline;
  final String spriteAsset;
  final Color color;
  final LaraBaseGame Function() builder;
  final GameOverOverlayBuilder? gameOverBuilder;

  /// Non-null means the game must be purchased before playing.
  final String? unlockKey;

  /// Non-null means the game is time-locked until this date.
  final DateTime? timeLockUntil;
  final String scoreLabel;

  /// If set, coins are awarded via [CoinRewardOverlay] before the game-over card.
  final int Function(LaraBaseGame)? coinReward;

  /// Extra overlays passed directly to [GameScaffold.additionalOverlays].
  final Map<String, Widget Function(BuildContext, LaraBaseGame)>? additionalOverlays;
}

class _GameTileCard extends StatefulWidget {
  const _GameTileCard({required this.tile});

  final _GameTile tile;

  @override
  State<_GameTileCard> createState() => _GameTileCardState();
}

class _GameTileCardState extends State<_GameTileCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _unlocked = false;
  static const _depth = 5.0;

  late final AnimationController _wiggleController;
  Timer? _countdownTimer;

  bool get _isTimeLocked {
    final until = widget.tile.timeLockUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  bool get _isCoinLocked => !_unlocked;

  bool get _isLocked => _isTimeLocked || _isCoinLocked;

  @override
  void initState() {
    super.initState();
    final key = widget.tile.unlockKey;
    _unlocked = key == null || GameUnlockState.isUnlocked(key);

    _wiggleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() => setState(() {}));

    if (widget.tile.timeLockUntil != null) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown() {
    final until = widget.tile.timeLockUntil!;
    final remaining = until.difference(DateTime.now());
    if (remaining.inSeconds <= 0) return '¡Ya disponible!';
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_isTimeLocked) {
      LaraAudio.playSfx(LaraSfx.miss);
      _wiggleController.forward(from: 0);
      return;
    }
    if (!_isCoinLocked) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameScaffold(
            title: widget.tile.title,
            builder: widget.tile.builder,
            gameOverBuilder: widget.tile.gameOverBuilder,
            scoreLabel: widget.tile.scoreLabel,
            additionalOverlays: widget.tile.additionalOverlays,
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
    final wiggleDx = math.sin(_wiggleController.value * math.pi * 6) * 10.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        if (!_isTimeLocked) LaraAudio.playSfx(LaraSfx.button);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _handleTap(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Transform.translate(
        offset: Offset(wiggleDx, 0),
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
                color: ColorUtil.darken(widget.tile.color),
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
                        child: Image.asset(widget.tile.spriteAsset, fit: BoxFit.contain),
                      ),
                    ),
                    if (_isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white, size: 30)),
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
                      if (_isTimeLocked) ...[
                        const SizedBox(height: 6),
                        CountdownBadge(countdown: _formatCountdown()),
                      ] else if (_isCoinLocked) ...[
                        const SizedBox(height: 6),
                        CostBadge(cost: GameUnlockState.costs[widget.tile.unlockKey]!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(_isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
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
                decoration: BoxDecoration(color: LaraColors.cream, borderRadius: BorderRadius.circular(2)),
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
                    child: Image.asset(tile.spriteAsset, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tile.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: LaraColors.magenta),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¡Desbloquea este juego!',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LaraColors.galletaBrown),
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
                    const Icon(Icons.monetization_on_rounded, color: LaraColors.galletaBrown, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$cost monedas',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: LaraColors.galletaBrown),
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LaraColors.galletaBrown),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                InlineCoinButton(amount: 100, color: LaraColors.rhenneGreen, shadowColor: LaraColors.rhenneGreenDark),
                const SizedBox(height: 10),
                InlineCoinButton(amount: 500, color: LaraColors.magenta, shadowColor: LaraColors.magentaDark),
                const SizedBox(height: 20),
              ],
              // Unlock button — shown only when player can afford
              if (canAfford) ...[
                UnlockButton(
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
                  style: TextStyle(color: LaraColors.galletaBrown, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Coin display + mute toggle row ──────────────────────────────────────────

// ─── Ad banner ────────────────────────────────────────────────────────────────

class _AdBanner extends StatefulWidget {
  const _AdBanner();

  @override
  State<_AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<_AdBanner> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ConcertScreen()));
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
          decoration: BoxDecoration(
            color: LaraColors.magenta,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, _pressed ? 0 : _depth),
                blurRadius: 0,
                color: ColorUtil.darken(LaraColors.magenta),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: const Row(
            children: [
              Text('🎤', style: TextStyle(fontSize: 26)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Lara Campos cantará en Pachuca este fin de semana!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Matilda banner ───────────────────────────────────────────────────────────

class _MatildaBanner extends StatefulWidget {
  const _MatildaBanner();

  @override
  State<_MatildaBanner> createState() => _MatildaBannerState();
}

class _MatildaBannerState extends State<_MatildaBanner> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MatildaScreen()));
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF6A0DAD),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(offset: Offset(0, _pressed ? 0 : _depth), blurRadius: 0, color: const Color(0xFF4A0080)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: const Row(
            children: [
              Text('🎭', style: TextStyle(fontSize: 26)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Matilda El Musical llega a México!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
            ],
          ),
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Divider(color: Colors.white54, thickness: 1.5),
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
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CollectiblesScreen()));
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
                color: ColorUtil.darken(LaraColors.mint),
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
                padding: const EdgeInsets.all(6),

                child: Image.asset('assets/images/icons/icon_collectibles.png', fit: BoxFit.contain),
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
                      '¡Desbloquea los amigos de Lara y aparecerán en los juegos!',
                      style: LaraTextStyles.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Difficulty-change confirmation overlay (Memoria Amigos) ──────────────────

class _DifficultyConfirmOverlay extends StatelessWidget {
  const _DifficultyConfirmOverlay({required this.onConfirm, required this.onCancel});

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          decoration: BoxDecoration(
            color: LaraColors.cream,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: LaraColors.magenta, width: 4),
            boxShadow: const [BoxShadow(offset: Offset(0, 6), blurRadius: 0, color: LaraColors.magenta)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Cambiar nivel?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: LaraColors.magenta),
              ),
              const SizedBox(height: 8),
              const Text(
                'Perderás el progreso del juego actual.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LaraColors.ink),
              ),
              const SizedBox(height: 20),
              LaraButton(label: 'Sí, cambiar', icon: Icons.check_rounded, onPressed: onConfirm, fullWidth: true),
              const SizedBox(height: 12),
              LaraButton(
                label: 'Cancelar',
                color: LaraColors.mint,
                shadowColor: LaraColors.rhenneGreenDark,
                icon: Icons.close_rounded,
                onPressed: onCancel,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
