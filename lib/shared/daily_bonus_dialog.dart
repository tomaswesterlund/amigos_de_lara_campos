import 'package:flutter/material.dart';

import 'coin_wallet.dart';
import 'lara_audio.dart';
import 'lara_button.dart';
import 'lara_theme.dart';

class DailyBonusDialog extends StatefulWidget {
  const DailyBonusDialog({super.key});

  static bool _shown = false;

  /// Prevents the dialog from appearing. Call in test setUp to keep tests clean.
  @visibleForTesting
  static void suppressForTest() => _shown = true;

  static void showIfNeeded(BuildContext context) {
    if (_shown) return;
    _shown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DailyBonusDialog(),
    );
  }

  @override
  State<DailyBonusDialog> createState() => _DailyBonusDialogState();
}

class _DailyBonusDialogState extends State<DailyBonusDialog>
    with TickerProviderStateMixin {
  // Single controller drives all 5 coins via staggered Interval curves.
  late final AnimationController _coinsController;
  final List<Animation<double>> _coinScales = [];
  final List<Animation<double>> _coinOpacities = [];

  // Counter steps in sync with each coin becoming visible.
  final ValueNotifier<int> _count = ValueNotifier<int>(0);

  late final AnimationController _buttonController;
  late final Animation<double> _buttonOpacity;

  bool _claimed = false;

  // Arc positions for the 5 coins, centered in the widget.
  static const _arcOffsets = [
    Offset(-88, 16),
    Offset(-44, -8),
    Offset(0, -18),
    Offset(44, -8),
    Offset(88, 16),
  ];

  @override
  void initState() {
    super.initState();

    // 900 ms total; coin i starts at i*16% of the timeline.
    _coinsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    for (int i = 0; i < 5; i++) {
      final start = i * 0.16;
      final end = (start + 0.45).clamp(0.0, 1.0);
      final fadeEnd = (start + 0.15).clamp(0.0, 1.0);

      _coinScales.add(
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.25), weight: 60),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 40),
        ]).animate(
          CurvedAnimation(
            parent: _coinsController,
            curve: Interval(start, end),
          ),
        ),
      );
      _coinOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _coinsController,
            curve: Interval(start, fadeEnd, curve: Curves.easeIn),
          ),
        ),
      );
    }

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    _coinsController.forward();
    // Each coin becomes fully opaque ~135 ms after the previous one.
    // Step the counter in lockstep: +1 per coin as it appears.
    await Future<void>.delayed(const Duration(milliseconds: 135));
    for (int i = 0; i < 5; i++) {
      if (!mounted) return;
      _count.value = i + 1;
      LaraAudio.playSfx(LaraSfx.coin);
      if (i < 4) {
        await Future<void>.delayed(const Duration(milliseconds: 144));
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _buttonController.forward();
  }

  void _claim() {
    if (_claimed) return;
    _claimed = true;
    CoinWallet.add(5);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _coinsController.dispose();
    _buttonController.dispose();
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: LaraColors.yellow, width: 4),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 6),
              blurRadius: 0,
              color: LaraColors.galletaBrown,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Bonus Diario!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: LaraColors.magenta,
              ),
            ),
            const SizedBox(height: 24),
            // Arc of 5 coins
            SizedBox(
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < 5; i++)
                    _ArcCoin(
                      scale: _coinScales[i],
                      opacity: _coinOpacities[i],
                      offset: _arcOffsets[i],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: _count,
              builder: (_, count, _) => Text(
                '+$count monedas',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: LaraColors.yellow,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 3),
                      blurRadius: 0,
                      color: LaraColors.galletaBrown,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _buttonOpacity,
              builder: (_, child) => Opacity(
                opacity: _buttonOpacity.value,
                child: IgnorePointer(
                  ignoring: _buttonOpacity.value < 0.5,
                  child: child,
                ),
              ),
              child: LaraButton(
                label: '¡Recibido!',
                color: LaraColors.yellow,
                icon: Icons.star_rounded,
                onPressed: _claim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcCoin extends StatelessWidget {
  const _ArcCoin({
    required this.scale,
    required this.opacity,
    required this.offset,
  });

  final Animation<double> scale;
  final Animation<double> opacity;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scale, opacity]),
      builder: (_, _) => Transform.translate(
        offset: offset,
        child: Transform.scale(
          scale: scale.value,
          child: Opacity(
            opacity: opacity.value,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LaraColors.yellow,
                border:
                    Border.all(color: LaraColors.galletaBrown, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: LaraColors.yellow.withValues(alpha: 0.7),
                    blurRadius: 14,
                    spreadRadius: 3,
                  ),
                  const BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 0,
                    color: LaraColors.galletaBrown,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '★',
                  style: TextStyle(
                    fontSize: 22,
                    color: LaraColors.galletaBrown,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
