import 'package:flutter/material.dart';

import '../widgets/coin_shop.dart';
import '../widgets/coin_wallet.dart';
import '../core/lara_audio.dart';
import '../shared/collectibles_state.dart';
import '../widgets/lara_button.dart';
import '../core/lara_theme.dart';
import '../shared/qr_unlock_state.dart';

Color _darken(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
}

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
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoinStrip(),
                _LaraSection(onUnlockAttempt: () => setState(() {})),
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
      ),
    );
  }
}

// ─── Shared detail dialog ─────────────────────────────────────────────────────

void _showCollectibleDetail(
  BuildContext context,
  String assetPath,
  String label,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(offset: Offset(0, 8), blurRadius: 0, color: LaraColors.ink),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LaraColors.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: LaraColors.galletaBrown, width: 1.5),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: LaraColors.ink),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              assetPath,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: LaraColors.magenta,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share_rounded),
                label: const Text(
                  'Compartir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LaraColors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Coin balance strip ───────────────────────────────────────────────────────

class _CoinStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => showCoinShop(context),
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
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.add_circle_rounded,
                    color: LaraColors.galletaBrown,
                    size: 16,
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

// ─── Lara Campos section (QR unlock) ─────────────────────────────────────────

class _LaraSection extends StatelessWidget {
  const _LaraSection({required this.onUnlockAttempt});

  final VoidCallback onUnlockAttempt;

  static const _dolls = [
    (label: 'Muñeca Original', asset: 'lara_d1'),
    (label: 'Lara Concierto', asset: 'lara_d2'),
    (label: 'Lara Corazón', asset: 'lara_d3'),
  ];

  static const _borderGradient = LinearGradient(
    colors: [LaraColors.pink, LaraColors.magenta, LaraColors.yellow, LaraColors.pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: _borderGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 0,
            color: _darken(LaraColors.magenta),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient pink→magenta header with stars
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [LaraColors.pink, LaraColors.magenta],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
                      'assets/images/lara_d1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.star_rounded, color: LaraColors.yellow, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Lara Campos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 0,
                          color: LaraColors.ink,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star_rounded, color: LaraColors.yellow, size: 18),
                ],
              ),
            ),
            // QR hint banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: LaraColors.pink.withValues(alpha: 0.10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2_rounded,
                      size: 18, color: LaraColors.magenta),
                  SizedBox(width: 6),
                  Text(
                    'Desbloquea con el código QR de tu muñeca',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: LaraColors.magenta,
                    ),
                  ),
                ],
              ),
            ),
            // Card row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 0, 16),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 52),
                      child: Row(
                        children: [
                          for (int i = 0; i < _dolls.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                right: i < _dolls.length - 1 ? 12 : 0,
                                top: 8,
                              ),
                              child: _LaraCard(
                                index: i,
                                dollLabel: _dolls[i].label,
                                assetBase: _dolls[i].asset,
                                onUnlockAttempt: onUnlockAttempt,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
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
                        child: const Center(
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: LaraColors.magenta,
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
      ),
    );
  }
}

// ─── Lara card (QR unlock) ────────────────────────────────────────────────────

class _LaraCard extends StatefulWidget {
  const _LaraCard({
    required this.index,
    required this.dollLabel,
    required this.assetBase,
    required this.onUnlockAttempt,
  });

  final int index;
  final String dollLabel;
  final String assetBase;
  final VoidCallback onUnlockAttempt;

  @override
  State<_LaraCard> createState() => _LaraCardState();
}

class _LaraCardState extends State<_LaraCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScale;

  static const _gradients = [
    [LaraColors.pink, LaraColors.magenta],
    [LaraColors.magenta, LaraColors.yellow],
    [LaraColors.yellow, LaraColors.pink],
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
    if (QrUnlockState.isUnlocked(widget.index)) {
      _showCollectibleDetail(
        context,
        'assets/images/${widget.assetBase}.png',
        widget.dollLabel,
      );
    } else {
      _showQrDialog();
    }
  }

  void _showQrDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LaraColors.pink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: LaraColors.magenta,
                size: 52,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Escanea tu muñeca!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: LaraColors.magenta,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Apunta la cámara al código QR de tu muñeca de Lara Campos para desbloquear este coleccionable.',
          style: TextStyle(
            fontSize: 14,
            color: LaraColors.ink,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: LaraColors.galletaBrown,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          LaraButton(
            label: 'Escanear',
            color: LaraColors.pink,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    ).then((ok) {
      if (ok != true) return;
      QrUnlockState.unlock(widget.index);
      LaraAudio.playSfx(LaraSfx.unlock);
      widget.onUnlockAttempt();
      _bounceCtrl.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = QrUnlockState.isUnlocked(widget.index);
    final gradColors = _gradients[widget.index % _gradients.length];

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bounceScale,
        builder: (context, child) =>
            Transform.scale(scale: _bounceScale.value, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                    Container(
                      color: LaraColors.cream,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/${widget.assetBase}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (!unlocked)
                      Container(
                        color: LaraColors.ink.withValues(alpha: 0.65),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded,
                                color: Colors.white, size: 34),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: LaraColors.pink,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '¡Escanear!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Number badge — top-left
            Positioned(
              top: -8,
              left: -8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [LaraColors.pink, LaraColors.magenta],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                    '${widget.index + 1}',
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

  String get _baseAsset => charKey == 'heart' ? 'corazon' : charKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor, width: 3),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 0,
            color: _darken(accentColor),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    'assets/images/${_baseAsset}_l1.png',
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
                      Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 0,
                          color: LaraColors.ink),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 0, 16),
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 52),
                    child: Row(
                      children: [
                        for (int i = 0; i < CollectiblesState.count; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              right: i < CollectiblesState.count - 1 ? 12 : 0,
                              top: 8,
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
    if (CollectiblesState.isUnlocked(widget.charKey, widget.index)) {
      _showCollectibleDetail(
        context,
        'assets/images/$_assetName.png',
        _detailLabel,
      );
    } else if (CoinWallet.balance.value >= CollectiblesState.costs[widget.index]) {
      _showUnlockDialog();
    } else {
      showCoinShop(context);
    }
  }

  String get _charLabel {
    switch (widget.charKey) {
      case 'rhenne':
        return 'Rhenné';
      case 'galleta':
        return 'Galleta';
      default:
        return 'Corazón';
    }
  }

  String get _detailLabel => '$_charLabel — Nivel ${widget.index + 1}';

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
            const Icon(Icons.monetization_on_rounded,
                color: LaraColors.galletaBrown),
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
        LaraAudio.playSfx(LaraSfx.unlock);
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

  String get _assetName {
    final base = widget.charKey == 'heart' ? 'corazon' : widget.charKey;
    return '${base}_l${widget.index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final gradColors = _borderGradients[widget.index];
    final level = widget.index + 1;

    return ValueListenableBuilder<int>(
      valueListenable: CoinWallet.balance,
      builder: (context, balance, _) {
        final unlocked = CollectiblesState.isUnlocked(widget.charKey, widget.index);
        final cost = CollectiblesState.costs[widget.index];
        final canAfford = balance >= cost;

        return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bounceScale,
        builder: (context, child) =>
            Transform.scale(scale: _bounceScale.value, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                    Container(
                      color: LaraColors.cream,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/$_assetName.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (!unlocked)
                      Container(
                        color: LaraColors.ink.withValues(alpha: 0.65),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 34),
                            if (canAfford) ...[
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
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
      },
    );
  }
}
