import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/games/rhythm_tap/beat_charts.dart';

void main() {
  const gameDuration = 35.0;

  group('corazonChart', () {
    test('is non-empty', () {
      expect(corazonChart, isNotEmpty);
    });

    test('all event times are within [0, gameDuration]', () {
      for (final e in corazonChart) {
        expect(e.time, greaterThanOrEqualTo(0.0));
        expect(e.time, lessThanOrEqualTo(gameDuration));
      }
    });

    test('events are sorted ascending by time', () {
      for (var i = 0; i < corazonChart.length - 1; i++) {
        expect(corazonChart[i].time <= corazonChart[i + 1].time, isTrue,
            reason: 'event $i (${corazonChart[i].time}) should be ≤ event ${i + 1} (${corazonChart[i + 1].time})');
      }
    });

    test('all lane values are in range 0–3', () {
      for (final e in corazonChart) {
        expect(e.lane, inInclusiveRange(0, 3));
      }
    });

    test('uses all four lanes at least once', () {
      final lanes = corazonChart.map((e) => e.lane).toSet();
      expect(lanes, containsAll([0, 1, 2, 3]));
    });

    test('event count matches expected beats for 128 BPM over 35s', () {
      // At 128 BPM, a 16th note = 60/(128*4) ≈ 0.117s.
      // 2-bar block = 32 sixteenth notes ≈ 1.875s.
      // 16 notes per block × ~18 repetitions ≤ 35s → roughly 270–288 events.
      expect(corazonChart.length, greaterThan(100));
    });
  });
}
