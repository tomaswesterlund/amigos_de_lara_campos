import 'package:flutter/material.dart';
import 'package:lara_demo/core/lara_audio.dart';

class AudioModeButton extends StatefulWidget {
  const AudioModeButton({super.key});

  @override
  State<AudioModeButton> createState() => _AudioModeButtonState();
}

class _AudioModeButtonState extends State<AudioModeButton> {
  static IconData _icon(AudioMode m) => switch (m) {
    AudioMode.on => Icons.volume_up_rounded,
    AudioMode.bgmOff => Icons.music_off_rounded,
    AudioMode.off => Icons.volume_off_rounded,
  };

  static String _tooltip(AudioMode m) => switch (m) {
    AudioMode.on => 'Todo encendido',
    AudioMode.bgmOff => 'Música apagada',
    AudioMode.off => 'Todo silenciado',
  };

  @override
  Widget build(BuildContext context) {
    final mode = LaraAudio.mode;
    return IconButton(
      tooltip: _tooltip(mode),
      icon: Icon(_icon(mode)),
      onPressed: () {
        LaraAudio.cycleMode();
        setState(() {});
      },
    );
  }
}
