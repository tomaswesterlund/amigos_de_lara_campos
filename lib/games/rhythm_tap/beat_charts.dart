/// Beat chart data for the rhythm tap game.
///
/// A [BeatEvent] records the exact audio time (in seconds from song start)
/// at which the player should tap a given lane. This mirrors the MIDI-style
/// "note-on at tick T" format — tiny data that drives the visual gameplay.
///
/// Charts are generated from the BPM + a repeating lane pattern so the data
/// stays readable and editable without touching individual frame numbers.
class BeatEvent {
  const BeatEvent(this.time, this.lane);

  /// Seconds from the start of the BGM track.
  final double time;

  /// 0 = left lane … 3 = right lane.
  final int lane;
}

/// 128 BPM chart matching `bgm/corazon_theme.m4a`.
///
/// 8th-note pattern repeated over the 30-second loop.
/// Lane sequence alternates across 4 lanes for variety.
final List<BeatEvent> corazonChart = _buildChart(
  bpm: 128,
  gameDuration: 35.0,
  // 16th-note positions within a 2-bar block (0-based, out of 32 slots)
  positions: const [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
  lanes:     const [0, 2, 1, 3, 0, 2,  1,  3,  2,  0,  3,  1,  2,  0,  3,  1],
);

List<BeatEvent> _buildChart({
  required double bpm,
  required double gameDuration,
  required List<int> positions,
  required List<int> lanes,
}) {
  final sixteenth = 60.0 / bpm / 4;
  final blockLen  = sixteenth * 32; // 2 bars of 16th notes

  final events = <BeatEvent>[];
  var rep = 0;
  while (true) {
    final offset = rep * blockLen;
    for (var i = 0; i < positions.length; i++) {
      final t = offset + positions[i] * sixteenth;
      if (t > gameDuration) return events;
      events.add(BeatEvent(t, lanes[i]));
    }
    rep++;
  }
}
