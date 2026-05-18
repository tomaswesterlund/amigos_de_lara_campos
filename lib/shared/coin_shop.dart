import 'package:flutter/material.dart';

import 'coin_wallet.dart';
import 'lara_audio.dart';
import 'lara_theme.dart';

Future<void> showCoinShop(BuildContext context) async {
  final amount = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _CoinShopSheet(),
  );
  if (amount == null) return;
  CoinWallet.add(amount);
  LaraAudio.playSfx(LaraSfx.coin);
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
            shadowColor: LaraColors.rhenneGreenDark,
            onTap: () => Navigator.of(context).pop(100),
          ),
          const SizedBox(height: 12),
          _CoinPackageButton(
            amount: 500,
            color: LaraColors.magenta,
            shadowColor: LaraColors.magentaDark,
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

// ─── Coin package button ──────────────────────────────────────────────────────

class _CoinPackageButton extends StatefulWidget {
  const _CoinPackageButton({
    required this.amount,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  final int amount;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  State<_CoinPackageButton> createState() => _CoinPackageButtonState();
}

class _CoinPackageButtonState extends State<_CoinPackageButton> {
  bool _pressed = false;

  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        LaraAudio.playSfx(LaraSfx.button);
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

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.4, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
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
