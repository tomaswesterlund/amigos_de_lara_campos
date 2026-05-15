import 'package:flutter/material.dart';

import 'collectibles_screen.dart';
import 'games/alphabet/alphabet_game.dart';
import 'shared/coin_wallet.dart';
import 'shared/daily_bonus_dialog.dart';
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
import 'shared/game_scaffold.dart';
import 'shared/lara_game.dart';
import 'shared/lara_theme.dart';

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
        builder: MemoryMatchGame.new,
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
      ),
      ...always,
      _GameTile(
        title: 'Ritmo Lara',
        tagline: '¡Lara está cantando — sigue su ritmo sin perder el beat!',
        spriteAsset: 'music_note.png',
        color: LaraColors.magenta,
        builder: RhythmTapGame.new,
      ),
      _GameTile(
        title: 'Galleta Atrapa',
        tagline: '¡Lara le tiró snacks a Galleta — ayúdale a atraparlos todos!',
        spriteAsset: 'treat_bone.png',
        color: LaraColors.yellow,
        builder: GalletaCatchGame.new,
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
              const SliverToBoxAdapter(child: _AdBanner()),
              const SliverToBoxAdapter(child: _CollectiblesBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.separated(
                  itemCount: tiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _GameTileCard(tile: tiles[i]),
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
  });

  final String title;
  final String tagline;
  final String spriteAsset;
  final Color color;
  final LaraGame Function() builder;

  final GameOverOverlayBuilder? gameOverBuilder;
}

class _GameTileCard extends StatefulWidget {
  const _GameTileCard({required this.tile});

  final _GameTile tile;

  @override
  State<_GameTileCard> createState() => _GameTileCardState();
}

class _GameTileCardState extends State<_GameTileCard> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GameScaffold(
              title: widget.tile.title,
              builder: widget.tile.builder,
              gameOverBuilder: widget.tile.gameOverBuilder,
            ),
          ),
        );
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
              color: LaraColors.ink,
            ),
          ],
        ),
        child: Padding(
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
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/${widget.tile.spriteAsset}',
                  fit: BoxFit.contain,
                ),
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
                      maxLines: 3,
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

// ─── Coin display (scrolls with page, left-aligned, tappable) ────────────────

class _CoinDisplay extends StatelessWidget {
  const _CoinDisplay();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => _showCoinShop(context),
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
      ),
    );
  }
}

Future<void> _showCoinShop(BuildContext context) async {
  final amount = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _CoinShopSheet(),
  );
  if (amount == null) return;
  CoinWallet.add(amount);
  if (context.mounted) _showCoinAnimation(context, amount);
}

void _showCoinAnimation(BuildContext context, int amount) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CoinGainAnimation(
      amount: amount,
      onComplete: entry.remove,
    ),
  );
  overlay.insert(entry);
}

// ─── Coin shop bottom sheet ───────────────────────────────────────────────────

class _CoinShopSheet extends StatelessWidget {
  const _CoinShopSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LaraColors.cream,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on_rounded,
                  color: LaraColors.yellow, size: 30),
              SizedBox(width: 8),
              Text(
                'Comprar Monedas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: LaraColors.magenta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige tu paquete',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: LaraColors.galletaBrown,
            ),
          ),
          const SizedBox(height: 20),
          _CoinPackageButton(
            amount: 100,
            color: LaraColors.rhenneGreen,
            onTap: () => Navigator.of(context).pop(100),
          ),
          const SizedBox(height: 12),
          _CoinPackageButton(
            amount: 500,
            color: LaraColors.magenta,
            onTap: () => Navigator.of(context).pop(500),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
      ),
    );
  }
}

class _CoinPackageButton extends StatelessWidget {
  const _CoinPackageButton({
    required this.amount,
    required this.color,
    required this.onTap,
  });

  final int amount;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 0,
                color: LaraColors.ink,
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
                      '$amount monedas',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      amount == 500 ? '¡Mejor valor!' : 'Paquete básico',
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
      ),
    );
  }
}

// ─── Coin gain animation overlay ──────────────────────────────────────────────

class _CoinGainAnimation extends StatefulWidget {
  const _CoinGainAnimation({required this.amount, required this.onComplete});

  final int amount;
  final VoidCallback onComplete;

  @override
  State<_CoinGainAnimation> createState() => _CoinGainAnimationState();
}

class _CoinGainAnimationState extends State<_CoinGainAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _translateY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pop up (0→0.3s), hold (0.3→0.6s), float up + fade (0.6→1.0s)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.4, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.8), weight: 40),
    ]).animate(_ctrl);

    _translateY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -80.0), weight: 40),
    ]).animate(_ctrl);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.3),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: child,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: LaraColors.yellow,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: LaraColors.galletaBrown, width: 3),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 5),
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
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  '+${widget.amount}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: LaraColors.galletaBrown,
                  ),
                ),
              ],
            ),
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Próximamente más info!'),
            duration: Duration(seconds: 2),
          ),
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
                color: LaraColors.ink,
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
