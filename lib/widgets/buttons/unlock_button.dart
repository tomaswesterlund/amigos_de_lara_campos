import 'package:flutter/material.dart';
import 'package:lara_demo/shared/color_util.dart';

class UnlockButton extends StatefulWidget {
  const UnlockButton({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  State<UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<UnlockButton> {
  bool _pressed = false;
  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    final shadowColor = ColorUtil.darken(widget.color);
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
          boxShadow: [BoxShadow(offset: Offset(0, _pressed ? 0 : _depth), blurRadius: 0, color: shadowColor)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_rounded, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              '¡Desbloquear!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
