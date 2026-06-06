import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AudioMode { on, bgmOff, off }

/// Singleton audio manager for all BGM loops and SFX in the app.
///
/// Audio mode is session-only (no persistence).
class LaraAudio {
  LaraAudio._();

  static AudioMode _mode = AudioMode.on;
  static AudioMode get mode => _mode;

  static String? _activeBgm;
  static AudioPlayer? _bgmPlayer;

  static const _poolSize = 4;
  static final _sfxPool = <AudioPlayer>[];
  static int _poolIndex = 0;

  /// Call once from main() before runApp. Pre-warms the SFX player pool and
  /// configures the platform audio session to allow BGM + SFX to coexist.
  static Future<void> init() async {
    await AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        isSpeakerphoneOn: false,
        stayAwake: false,
      ),
    ));
    for (var i = 0; i < _poolSize; i++) {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.release);
      _sfxPool.add(p);
    }
  }

  /// Cycles: on → bgmOff → off → on
  static void cycleMode() {
    switch (_mode) {
      case AudioMode.on:
        _mode = AudioMode.bgmOff;
        _bgmPlayer?.pause();
      case AudioMode.bgmOff:
        _mode = AudioMode.off;
      case AudioMode.off:
        _mode = AudioMode.on;
        if (_activeBgm != null) _bgmPlayer?.resume();
    }
  }

  static Future<void> startBgm(String asset) async {
    _activeBgm = asset;
    if (_mode != AudioMode.on) return;
    try {
      await _bgmPlayer?.stop();
      await _bgmPlayer?.dispose();
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.play(AssetSource(asset), volume: 0.50);
    } catch (e) {
      debugPrint('LaraAudio.startBgm($asset): $e');
    }
  }

  static Future<void> stopBgm() async {
    _activeBgm = null;
    try {
      await _bgmPlayer?.stop();
      await _bgmPlayer?.dispose();
      _bgmPlayer = null;
    } catch (e) {
      debugPrint('LaraAudio.stopBgm: $e');
    }
  }

  static Future<void> playSfx(String asset) async {
    if (_mode == AudioMode.off) return;
    try {
      final player = _sfxPool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _poolSize;
      await player.stop();
      await player.play(AssetSource(asset), volume: 0.85);
    } catch (e) {
      debugPrint('LaraAudio.playSfx($asset): $e');
    }
  }
}

// ── BGM asset path constants ─────────────────────────────────────────────────

abstract final class LaraBgm {
  static const rhenne  = 'audio/bgm/rhenne_theme.m4a';
  static const galleta = 'audio/bgm/galleta_theme.m4a';
  static const corazon = 'audio/bgm/corazon_theme.m4a';
  static const memory  = 'audio/bgm/memory_theme.m4a';
  static const concert = 'audio/bgm/concert_preview.m4a';
}

// ── SFX asset path constants ─────────────────────────────────────────────────

abstract final class LaraSfx {
  static const hitPerfect = 'audio/sfx/hit_perfect.m4a';
  static const hitGood    = 'audio/sfx/hit_good.m4a';
  static const miss       = 'audio/sfx/miss.m4a';
  static const coin       = 'audio/sfx/coin.m4a';
  static const unlock     = 'audio/sfx/unlock.m4a';
  static const button     = 'audio/sfx/button.m4a';
}
