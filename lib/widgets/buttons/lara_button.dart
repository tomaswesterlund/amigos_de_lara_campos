import 'package:flutter/material.dart';

import '../../core/lara_audio.dart';
import '../../core/lara_theme.dart';

/// Sticker-style button with a flat hard shadow that gives a 3-D "pressed
/// into the page" depth effect — identical to the home-screen card style.
///
/// On press the button translates down by the shadow offset and the shadow
/// shrinks to zero, giving a satisfying "click-in" feel without a ripple.
class LaraButton extends StatefulWidget {
  const LaraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = LaraColors.pink,
    this.shadowColor = LaraColors.magenta,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  /// The colour used for both the border and the hard flat shadow.
  final Color shadowColor;

  final IconData? icon;

  /// When true the button stretches to fill its parent's available width.
  final bool fullWidth;

  @override
  State<LaraButton> createState() => _LaraButtonState();
}

class _LaraButtonState extends State<LaraButton> {
  bool _pressed = false;

  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      // Translate down by _depth when pressed so the button sits on the shadow.
      transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: widget.shadowColor, width: 3),
        boxShadow: [
          BoxShadow(
            // Offset shrinks to zero on press — button moving down covers it.
            offset: Offset(0, _pressed ? 0 : _depth),
            blurRadius: 0,
            color: widget.shadowColor,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(widget.label, style: LaraTextStyles.button),
        ],
      ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        LaraAudio.playSfx(LaraSfx.button);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: button,
    );
  }
}
