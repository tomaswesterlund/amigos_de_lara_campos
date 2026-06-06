import 'package:flutter/material.dart';

import '../widgets/coin_wallet.dart';
import '../shared/collectibles_state.dart';
import '../core/lara_audio.dart';
import '../widgets/lara_button.dart';
import '../core/lara_theme.dart';

/// Shown immediately after a game ends (before the game-over card / leaderboard).
/// Awards [coins] to the wallet, plays a coin SFX, then displays a scrollable
/// collectible showcase before the player taps "¡Continuar!".
class CoinRewardOverlay extends StatefulWidget {
  const CoinRewardOverlay({super.key, required this.coins, required this.onContinue});

  final int coins;
  final VoidCallback onContinue;

  @override
  State<CoinRewardOverlay> createState() => _CoinRewardOverlayState();
}

class _CoinRewardOverlayState extends State<CoinRewardOverlay> {
  static const _chars = ['rhenne', 'galleta', 'heart'];

  // Tracks the most recently unlocked item so its card can animate.
  ({String char, int index})? _justUnlocked;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.coins > 0) {
        CoinWallet.add(widget.coins);
        LaraAudio.playSfx(LaraSfx.coin);
      }
      setState(() {});
    });
  }

  List<({String char, int index})> _unlockedItems() => CollectiblesState.unlockedInOrder().reversed.toList();

  List<({String char, int index})> _affordableItems() {
    final balance = CoinWallet.balance.value;
    return [
      for (final c in _chars)
        for (var i = 0; i < CollectiblesState.count; i++)
          if (!CollectiblesState.isUnlocked(c, i) && CollectiblesState.costs[i] <= balance) (char: c, index: i),
    ];
  }

  List<({String char, int index})> _unaffordableItems() {
    final balance = CoinWallet.balance.value;
    return [
      for (final c in _chars)
        for (var i = 0; i < CollectiblesState.count; i++)
          if (!CollectiblesState.isUnlocked(c, i) && CollectiblesState.costs[i] > balance) (char: c, index: i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _unlockedItems();
    final affordable = _affordableItems();
    final unaffordable = _unaffordableItems();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
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
                if (widget.coins == 0)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.6, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¡Ooops!',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: LaraColors.magenta),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '¡Inténtalo otra vez!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LaraColors.ink),
                        ),
                      ],
                    ),
                  )
                else
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: widget.coins.toDouble()),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (_, value, _) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.4, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                          child: const Icon(Icons.monetization_on_rounded, color: LaraColors.yellow, size: 38),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '¡+${value.round()} moneda${widget.coins == 1 ? '' : 's'}!',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: LaraColors.magenta),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                const Divider(color: LaraColors.magenta, thickness: 1.5),

                const SizedBox(height: 14),
                const Text(
                  'Tus amigos:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LaraColors.magenta),
                ),
                const SizedBox(height: 8),
                _SectionArea(
                  empty: unlocked.isEmpty,
                  emptyMessage: '¡Juega para ganar amigos!',
                  emptyColor: LaraColors.magenta,
                  child: _CollectibleRow(items: unlocked, state: _CardState.unlocked, justUnlocked: _justUnlocked),
                ),

                const SizedBox(height: 14),
                const Text(
                  '¡Desbloquea a todos los amigos!',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LaraColors.rhenneGreenDark),
                ),
                const SizedBox(height: 8),
                if (affordable.isEmpty && unaffordable.isEmpty)
                  _SectionArea(
                    empty: true,
                    emptyMessage: '¡Ya tienes todos los amigos!',
                    emptyColor: LaraColors.rhenneGreenDark,
                    child: const SizedBox.shrink(),
                  )
                else
                  _LockedGrid(
                    affordable: affordable,
                    unaffordable: unaffordable,
                    onUnlock: (char, index) => setState(() => _justUnlocked = (char: char, index: index)),
                  ),

                const SizedBox(height: 20),
                LaraButton(
                  label: '¡Continuar!',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: widget.onContinue,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card state enum ──────────────────────────────────────────────────────────

enum _CardState { unlocked, affordable, locked }

// ─── Fixed-height section area ────────────────────────────────────────────────

class _SectionArea extends StatelessWidget {
  const _SectionArea({required this.empty, required this.emptyMessage, required this.emptyColor, required this.child});

  final bool empty;
  final String emptyMessage;
  final Color emptyColor;
  final Widget child;

  static const height = 88.0;

  @override
  Widget build(BuildContext context) {
    if (empty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            emptyMessage,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: emptyColor.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return SizedBox(height: height, child: child);
  }
}

// ─── Locked collectibles grid (affordable first, then locked) ─────────────────

class _LockedGrid extends StatelessWidget {
  const _LockedGrid({required this.affordable, required this.unaffordable, required this.onUnlock});

  final List<({String char, int index})> affordable;
  final List<({String char, int index})> unaffordable;
  final void Function(String char, int index) onUnlock;

  @override
  Widget build(BuildContext context) {
    final all = [
      for (final item in affordable) (char: item.char, index: item.index, state: _CardState.affordable),
      for (final item in unaffordable) (char: item.char, index: item.index, state: _CardState.locked),
    ];

    // Split into rows of 3
    final rows = <List<({String char, int index, _CardState state})>>[];
    for (int i = 0; i < all.length; i += 3) {
      rows.add(all.sublist(i, (i + 3).clamp(0, all.length)));
    }

    // card ~76px tall, gap 10px → 2 visible rows = 162px
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 162),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int r = 0; r < rows.length; r++) ...[
              if (r > 0) const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < rows[r].length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    _CollectibleCard(
                      key: ValueKey('${rows[r][i].state.name}_${rows[r][i].char}_${rows[r][i].index}'),
                      char: rows[r][i].char,
                      index: rows[r][i].index,
                      state: rows[r][i].state,
                      onUnlock: rows[r][i].state == _CardState.affordable ? onUnlock : null,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Horizontal collectible row ───────────────────────────────────────────────

class _CollectibleRow extends StatelessWidget {
  const _CollectibleRow({required this.items, required this.state, this.justUnlocked});

  final List<({String char, int index})> items;
  final _CardState state;
  final ({String char, int index})? justUnlocked;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _CollectibleCard(
                // Key includes the section so Flutter recreates the widget
                // (and fires initState) when an item moves into the unlocked row.
                key: ValueKey('${state.name}_${item.char}_${item.index}'),
                char: item.char,
                index: item.index,
                state: state,
                isNew: justUnlocked?.char == item.char && justUnlocked?.index == item.index,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Individual collectible card ──────────────────────────────────────────────

class _CollectibleCard extends StatefulWidget {
  const _CollectibleCard({
    super.key,
    required this.char,
    required this.index,
    required this.state,
    this.onUnlock,
    this.isNew = false,
  });

  static const _assetPrefix = {'rhenne': 'rhenne', 'galleta': 'galleta', 'heart': 'corazon'};

  final String char;
  final int index;
  final _CardState state;
  final void Function(String char, int index)? onUnlock;
  final bool isNew;

  String get _label => switch (char) {
    'rhenne' => 'Rhenné',
    'galleta' => 'Galleta',
    _ => 'Corazón',
  };

  @override
  State<_CollectibleCard> createState() => _CollectibleCardState();
}

class _CollectibleCardState extends State<_CollectibleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glowAlpha;
  late final Animation<double> _sparkleAlpha;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 1100), vsync: this);
    // Scale: elastic pop from 0 → 1 within the first 55% of the animation.
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );
    // Golden glow that fades out over the full duration.
    _glowAlpha = Tween<double>(begin: 0.75, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    // Sparkle badge: visible at start, fades between 35–70% of the animation.
    _sparkleAlpha = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );
    if (widget.isNew) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cost = CollectiblesState.costs[widget.index];
    final asset = 'assets/images/${_CollectibleCard._assetPrefix[widget.char]}_l${widget.index + 1}.png';
    final isUnlocked = widget.state == _CardState.unlocked;
    final isAffordable = widget.state == _CardState.affordable;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;

        // Border animates from yellow → magenta as the glow fades.
        final borderColor = isUnlocked && widget.isNew
            ? Color.lerp(LaraColors.yellow, LaraColors.magenta, t)!
            : isUnlocked
            ? LaraColors.magenta
            : isAffordable
            ? LaraColors.rhenneGreenDark
            : LaraColors.galletaBrown.withValues(alpha: 0.4);

        final borderWidth = isUnlocked && widget.isNew ? 2.0 + (1.0 - t) * 2.0 : 2.0;

        Widget card = Container(
          width: 72,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isUnlocked ? LaraColors.magenta.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isUnlocked && widget.isNew
                ? [
                    BoxShadow(
                      color: LaraColors.yellow.withValues(alpha: _glowAlpha.value),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: (isUnlocked || isAffordable)
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.matrix([
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                        child: Opacity(
                          opacity: isUnlocked ? 1.0 : 0.55,
                          child: Image.asset(asset, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: LaraColors.galletaBrown, width: 1),
                          ),
                          child: Icon(
                            isAffordable ? Icons.lock_open_rounded : Icons.lock_rounded,
                            size: 11,
                            color: isAffordable ? LaraColors.rhenneGreenDark : LaraColors.galletaBrown,
                          ),
                        ),
                      ),
                    // Sparkle badge for newly unlocked cards.
                    if (isUnlocked && widget.isNew && _sparkleAlpha.value > 0.01)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Opacity(
                          opacity: _sparkleAlpha.value,
                          child: const Text('✨', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (isUnlocked)
                Text(
                  widget._label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LaraColors.magenta),
                  textAlign: TextAlign.center,
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      size: 11,
                      color: isAffordable ? LaraColors.rhenneGreenDark : LaraColors.galletaBrown,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$cost',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isAffordable ? LaraColors.rhenneGreenDark : LaraColors.galletaBrown,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );

        // Apply the elastic pop-in scale for newly unlocked cards.
        card = Transform.scale(scale: widget.isNew ? _scale.value : 1.0, child: card);

        if (isAffordable && widget.onUnlock != null) {
          return GestureDetector(
            onTap: () {
              if (CollectiblesState.unlock(widget.char, widget.index)) {
                LaraAudio.playSfx(LaraSfx.unlock);
                widget.onUnlock!(widget.char, widget.index);
              }
            },
            child: card,
          );
        }

        return card;
      },
    );
  }
}
