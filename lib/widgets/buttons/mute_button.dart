import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_audio.dart';

class MuteButton extends StatefulWidget {
  const MuteButton();

  @override
  State<MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<MuteButton> {
  static IconData _icon(AudioMode m) => switch (m) {
    AudioMode.on => Icons.volume_up_rounded,
    AudioMode.bgmOff => Icons.music_off_rounded,
    AudioMode.off => Icons.volume_off_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LaraAudio.cycleMode();
        setState(() {});
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
        ),
        child: Icon(_icon(LaraAudio.mode), color: Colors.white, size: 22),
      ),
    );
  }
}