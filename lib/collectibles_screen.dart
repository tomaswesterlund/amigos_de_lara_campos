import 'package:flutter/material.dart';

import 'shared/coin_wallet.dart';
import 'shared/collectibles_state.dart';
import 'shared/lara_button.dart';
import 'shared/lara_theme.dart';

class CollectiblesScreen extends StatefulWidget {
  const CollectiblesScreen({super.key});

  @override
  State<CollectiblesScreen> createState() => _CollectiblesScreenState();
}

class _CollectiblesScreenState extends State<CollectiblesScreen> {
  static const _characters = [
    (key: 'rhenne', label: 'Rhenné', color: LaraColors.rhenneGreen),
    (key: 'galleta', label: 'Galleta', color: LaraColors.galletaBrown),
    (key: 'heart', label: 'Corazón', color: LaraColors.corazonRed),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coleccionables')),
      body: Container(
        decoration: const BoxDecoration(gradient: LaraGradients.party),
        child: Column(
          children: [
            _CoinStrip(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in _characters)
                      _CharacterSection(
                        charKey: c.key,
                        label: c.label,
                        accentColor: c.color,
                        onUnlockAttempt: () => setState(() {}),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coin balance strip ───────────────────────────────────────────────────────

class _CoinStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ValueListenableBuilder<int>(
            valueListenable: CoinWallet.balance,
            builder: (context, balance, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: LaraColors.yellow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LaraColors.galletaBrown, width: 2),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 2),
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
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$balance',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: LaraColors.galletaBrown,
                    ),
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

// ─── Character section ────────────────────────────────────────────────────────

class _CharacterSection extends StatelessWidget {
  const _CharacterSection({
    required this.charKey,
    required this.label,
    required this.accentColor,
    required this.onUnlockAttempt,
  });

  final String charKey;
  final String label;
  final Color accentColor;
  final VoidCallback onUnlockAttempt;

  String get _assetName => charKey == 'heart' ? 'corazon' : charKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor, width: 3),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 5), blurRadius: 0, color: LaraColors.ink),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header strip
          Container(
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    'assets/images/$_assetName.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(0, 2), blurRadius: 0, color: LaraColors.ink),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Card row with scroll-hint fade on the right
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 0, 16),
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    // Left padding gives the top-left badge its 8 px overflow room.
                    // Right padding keeps last card clear of the fade when fully scrolled.
                    padding: const EdgeInsets.only(left: 8, right: 52),
                    child: Row(
                      children: [
                        for (int i = 0; i < CollectiblesState.count; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              right: i < CollectiblesState.count - 1 ? 12 : 0,
                              top: 8, // room for the level badge that overflows upward
                            ),
                            child: _CollectibleCard(
                              charKey: charKey,
                              index: i,
                              onUnlockAttempt: onUnlockAttempt,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Fade + chevron — signals horizontal scroll affordance.
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.97),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: accentColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Collectible card ─────────────────────────────────────────────────────────

class _CollectibleCard extends StatefulWidget {
  const _CollectibleCard({
    required this.charKey,
    required this.index,
    required this.onUnlockAttempt,
  });

  final String charKey;
  final int index;
  final VoidCallback onUnlockAttempt;

  @override
  State<_CollectibleCard> createState() => _CollectibleCardState();
}

class _CollectibleCardState extends State<_CollectibleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScale;

  static const _borderGradients = [
    [LaraColors.cream, LaraColors.cream],
    [Color(0xFFCD7F32), Color(0xFFE8A96C)],
    [Color(0xFFC0C0C0), Color(0xFFE8E8E8)],
    [LaraColors.yellow, Color(0xFFFFB800)],
    [LaraColors.pink, LaraColors.mint],
  ];


  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (CollectiblesState.isUnlocked(widget.charKey, widget.index)) return;
    _showUnlockDialog();
  }

  void _showUnlockDialog() {
    final cost = CollectiblesState.costs[widget.index];
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '¿Desbloquear?',
          style: TextStyle(fontWeight: FontWeight.w900, color: LaraColors.magenta),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded, color: LaraColors.galletaBrown),
            const SizedBox(width: 6),
            Text(
              '$cost monedas',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: LaraColors.ink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: LaraColors.galletaBrown)),
          ),
          LaraButton(
            label: 'Desbloquear',
            color: LaraColors.rhenneGreen,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true) return;
      final success = CollectiblesState.unlock(widget.charKey, widget.index);
      if (success) {
        widget.onUnlockAttempt();
        _bounceCtrl.forward(from: 0);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡No tienes suficientes monedas!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  String get _assetName => widget.charKey == 'heart' ? 'corazon' : widget.charKey;

  @override
  Widget build(BuildContext context) {
    final unlocked = CollectiblesState.isUnlocked(widget.charKey, widget.index);
    final cost = CollectiblesState.costs[widget.index];
    final gradColors = _borderGradients[widget.index];
    final level = widget.index + 1;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bounceScale,
        builder: (context, child) =>
            Transform.scale(scale: _bounceScale.value, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card body
            Container(
              width: 110,
              height: 145,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradColors,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Character sprite
                    Container(
                      color: LaraColors.cream,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/$_assetName.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Lock overlay
                    if (!unlocked)
                      Container(
                        color: LaraColors.ink.withValues(alpha: 0.65),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 34),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: LaraColors.yellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.monetization_on_rounded,
                                      color: LaraColors.galletaBrown, size: 14),
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
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Level badge — top-left, sits outside the card border
            Positioned(
              top: -8,
              left: -8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LaraColors.magenta,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 0,
                      color: LaraColors.ink,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
