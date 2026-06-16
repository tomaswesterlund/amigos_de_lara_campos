import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_audio.dart';
import 'package:lara_demo/widgets/coin_wallet.dart';

class InlineCoinButton extends StatefulWidget {
  const InlineCoinButton({required this.amount, required this.color, required this.shadowColor});

  final int amount;
  final Color color;
  final Color shadowColor;

  @override
  State<InlineCoinButton> createState() => _InlineCoinButtonState();
}

class _InlineCoinButtonState extends State<InlineCoinButton> {
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
          boxShadow: [BoxShadow(offset: Offset(0, _pressed ? 0 : _depth), blurRadius: 0, color: widget.shadowColor)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
              child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.amount} monedas',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
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
