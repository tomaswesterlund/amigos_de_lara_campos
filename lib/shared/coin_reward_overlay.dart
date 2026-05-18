import 'dart:math';

import 'package:flutter/material.dart';

import 'coin_wallet.dart';
import 'collectibles_state.dart';
import 'lara_audio.dart';
import 'lara_button.dart';
import 'lara_theme.dart';

/// Shown immediately after a game ends (before the game-over card / leaderboard).
/// Awards [coins] to the wallet, plays a coin SFX, then displays a scrollable
/// collectible showcase before the player taps "¡Continuar!".
class CoinRewardOverlay extends StatefulWidget {
  const CoinRewardOverlay({
    super.key,
    required this.coins,
    required this.onContinue,
  });

  final int coins;
  final VoidCallback onContinue;

  @override
  State<CoinRewardOverlay> createState() => _CoinRewardOverlayState();
}

class _CoinRewardOverlayState extends State<CoinRewardOverlay> {
  static const _chars = ['rhenne', 'galleta', 'heart'];

  List<({String char, int index})> _upcoming = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate with the pre-coins balance so the first frame isn't empty.
    _upcoming = _buildUpcoming();
    // Defer the wallet update: CoinWallet.add fires notifyListeners() synchronously,
    // which calls setState on ValueListenableBuilder widgets still in the tree.
    // Doing this inside initState (which is called during GameWidget's build pass)
    // triggers the "setState during build" assertion crash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.coins > 0) {
        CoinWallet.add(widget.coins);
        LaraAudio.playSfx(LaraSfx.coin);
      }
      setState(() => _upcoming = _buildUpcoming());
    });
  }

  List<({String char, int index})> _buildUpcoming() {
    final balance = CoinWallet.balance.value;
    final all = [
      for (final c in _chars)
        for (var i = 0; i < CollectiblesState.count; i++)
          if (!CollectiblesState.isUnlocked(c, i) &&
              CollectiblesState.costs[i] > balance)
            (char: c, index: i)
    ]..shuffle(Random());
    return all.take(2).toList();
  }

  List<({String char, int index})> _unlockedItems() {
    final result = <({String char, int index})>[];
    for (final c in _chars) {
      for (var i = CollectiblesState.count - 1; i >= 0; i--) {
        if (CollectiblesState.isUnlocked(c, i)) {
          result.add((char: c, index: i));
          break;
        }
      }
    }
    result.sort((a, b) => b.index.compareTo(a.index));
    return result.take(2).toList();
  }

  List<({String char, int index})> _affordableItems() {
    final balance = CoinWallet.balance.value;
    return [
      for (final c in _chars)
        for (var i = 0; i < CollectiblesState.count; i++)
          if (!CollectiblesState.isUnlocked(c, i) &&
              CollectiblesState.costs[i] <= balance)
            (char: c, index: i)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _unlockedItems();
    final affordable = _affordableItems();
    final upcoming = _upcoming
        .where((e) => !CollectiblesState.isUnlocked(e.char, e.index))
        .toList();
    final hasSections =
        unlocked.isNotEmpty || affordable.isNotEmpty || upcoming.isNotEmpty;

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
              boxShadow: const [
                BoxShadow(
                    offset: Offset(0, 6), blurRadius: 0, color: LaraColors.magenta),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated coin count
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
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: LaraColors.yellow,
                          size: 38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '¡+${value.round()} moneda${widget.coins == 1 ? '' : 's'}!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: LaraColors.magenta,
                        ),
                      ),
                    ],
                  ),
                ),

                if (hasSections) ...[
                  const SizedBox(height: 16),
                  const Divider(color: LaraColors.magenta, thickness: 1.5),
                ],

                if (unlocked.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Tus amigos:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LaraColors.magenta),
                  ),
                  const SizedBox(height: 8),
                  _CollectibleRow(items: unlocked, state: _CardState.unlocked),
                ],

                if (affordable.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    '¡Puedes desbloquear!',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LaraColors.rhenneGreenDark),
                  ),
                  const SizedBox(height: 8),
                  _CollectibleRow(
                    items: affordable,
                    state: _CardState.affordable,
                    onUnlock: () => setState(() {}),
                  ),
                ],

                if (upcoming.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Próximamente:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LaraColors.galletaBrown),
                  ),
                  const SizedBox(height: 8),
                  _CollectibleRow(items: upcoming, state: _CardState.locked),
                ],

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

// ─── Horizontal collectible row ───────────────────────────────────────────────

class _CollectibleRow extends StatelessWidget {
  const _CollectibleRow({
    required this.items,
    required this.state,
    this.onUnlock,
  });

  final List<({String char, int index})> items;
  final _CardState state;
  final VoidCallback? onUnlock;

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
                char: item.char,
                index: item.index,
                state: state,
                onUnlock: onUnlock,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Individual collectible card ──────────────────────────────────────────────

class _CollectibleCard extends StatelessWidget {
  const _CollectibleCard({
    required this.char,
    required this.index,
    required this.state,
    this.onUnlock,
  });

  // Maps CollectiblesState charKey → asset filename prefix (they differ for 'heart').
  static const _assetPrefix = {
    'rhenne': 'rhenne',
    'galleta': 'galleta',
    'heart': 'corazon',
  };

  final String char;
  final int index;
  final _CardState state;
  final VoidCallback? onUnlock;

  String get _label => switch (char) {
        'rhenne' => 'Rhenné',
        'galleta' => 'Galleta',
        _ => 'Corazón',
      };

  @override
  Widget build(BuildContext context) {
    final cost = CollectiblesState.costs[index];
    final asset = 'assets/images/${_assetPrefix[char]}_l${index + 1}.png';
    final isUnlocked = state == _CardState.unlocked;
    final isAffordable = state == _CardState.affordable;

    Widget card = Container(
      width: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isUnlocked
            ? LaraColors.magenta.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? LaraColors.magenta
              : isAffordable
                  ? LaraColors.rhenneGreenDark
                  : LaraColors.galletaBrown.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: (isUnlocked || isAffordable)
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
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
                        isAffordable
                            ? Icons.lock_open_rounded
                            : Icons.lock_rounded,
                        size: 11,
                        color: isAffordable
                            ? LaraColors.rhenneGreenDark
                            : LaraColors.galletaBrown,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUnlocked ? _label : '$cost 🪙',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? LaraColors.magenta
                  : isAffordable
                      ? LaraColors.rhenneGreenDark
                      : LaraColors.galletaBrown,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (isAffordable && onUnlock != null) {
      card = GestureDetector(
        onTap: () {
          if (CollectiblesState.unlock(char, index)) {
            LaraAudio.playSfx(LaraSfx.unlock);
            onUnlock!();
          }
        },
        child: card,
      );
    }

    return card;
  }
}
