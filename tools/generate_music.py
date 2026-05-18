"""
generate_music.py — synthesises all BGM loops and SFX for the Lara Campos app.

Uses only Python stdlib (struct, wave, math, array) — no external deps needed.
Outputs WAV files to assets/audio/bgm/ and assets/audio/sfx/.

Each BGM is a 30-second (or 10-second) loop built from layered sine-wave
oscillators: bass line, chord pad, lead melody, and a hi-hat click track.
The MIDI-like note data (pitch + time) lives as plain Python lists at the top
of each song function — edit those to change the arrangement.

To convert WAV → OGG (optional, reduces file size ~70%):
  brew install ffmpeg        # macOS
  for f in assets/audio/**/*.wav; do
      ffmpeg -y -i "$f" "${f%.wav}.ogg" && rm "$f"
  done
Then update pubspec.yaml to reference *.ogg and LaraAudio asset paths.
"""

import math
import os
import struct
import wave

# ── Output paths ──────────────────────────────────────────────────────────────
_ROOT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
_BGM  = os.path.join(_ROOT, 'bgm')
_SFX  = os.path.join(_ROOT, 'sfx')

SAMPLE_RATE = 44100

# ── MIDI note → frequency ─────────────────────────────────────────────────────
def midi_to_hz(note: int) -> float:
    return 440.0 * 2 ** ((note - 69) / 12)

# MIDI note constants (C4 = 60)
C3,D3,E3,F3,G3,A3,B3 = 48,50,52,53,55,57,59
C4,D4,E4,F4,G4,A4,B4 = 60,62,64,65,67,69,71
C5,D5,E5,F5,G5,A5,B5 = 72,74,76,77,79,81,83
Cs4,Fs4,Gs4,As4      = 61,66,68,70
Cs5,Ds5,Fs5,Gs5,As5  = 73,75,78,80,82
Bb3, Bb4             = 58, 70
Eb4, Ab4             = 63, 68
Eb5, Ab5             = 75, 80

# ── Low-level audio helpers ───────────────────────────────────────────────────

def _sine(freq: float, t: float, amp: float = 1.0) -> float:
    return amp * math.sin(2 * math.pi * freq * t)

def _saw(freq: float, t: float, amp: float = 1.0, harmonics: int = 6) -> float:
    v = 0.0
    for k in range(1, harmonics + 1):
        v += math.sin(2 * math.pi * freq * k * t) / k
    return amp * v * (2 / math.pi)

def _square(freq: float, t: float, amp: float = 1.0, harmonics: int = 8) -> float:
    v = 0.0
    for k in range(1, harmonics * 2, 2):
        v += math.sin(2 * math.pi * freq * k * t) / k
    return amp * v * (4 / math.pi)

def _adsr(t: float, dur: float, A=0.01, D=0.05, S=0.7, R=0.08) -> float:
    if t < A:
        return t / A
    elif t < A + D:
        return 1.0 - (1.0 - S) * (t - A) / D
    elif t < dur - R:
        return S
    elif t < dur:
        return S * (1.0 - (t - (dur - R)) / R)
    return 0.0

def _noise(seed: int, t: float) -> float:
    # Deterministic pseudo-noise for hi-hat
    x = math.sin(seed * 127.1 + t * 311.7) * 43758.5453
    return 2.0 * (x - math.floor(x)) - 1.0

def _clip(v: float) -> float:
    return max(-1.0, min(1.0, v))

def _to_pcm(samples: list[float]) -> bytes:
    return struct.pack(f'<{len(samples)}h',
                       *[int(_clip(s) * 32767) for s in samples])

def _write_wav(path: str, samples: list[float]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = _to_pcm(samples)
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(data)
    kb = len(data) // 1024
    print(f'  wrote {os.path.relpath(path)} ({kb} KB)')

def _mix(*layers: list[float]) -> list[float]:
    n = max(len(l) for l in layers)
    out = [0.0] * n
    for layer in layers:
        for i, v in enumerate(layer):
            out[i] += v
    return out

def _frames(seconds: float) -> int:
    return int(SAMPLE_RATE * seconds)

def _fade(samples: list[float], fade_in=0.05, fade_out=0.08) -> list[float]:
    n = len(samples)
    fi = int(SAMPLE_RATE * fade_in)
    fo = int(SAMPLE_RATE * fade_out)
    for i in range(fi):
        samples[i] *= i / fi
    for i in range(fo):
        samples[n - 1 - i] *= i / fo
    return samples

# ── BGM building blocks ───────────────────────────────────────────────────────

def _bass_layer(note_seq: list[tuple[float, int, float]], total: float,
                amp=0.35, waveform='sine') -> list[float]:
    """note_seq: list of (start_sec, midi_note, duration_sec)"""
    n = _frames(total)
    out = [0.0] * n
    for (start, note, dur) in note_seq:
        freq = midi_to_hz(note)
        for i in range(_frames(dur)):
            t_abs = start + i / SAMPLE_RATE
            t_rel = i / SAMPLE_RATE
            env = _adsr(t_rel, dur, A=0.02, D=0.04, S=0.8, R=0.12)
            v = _sine(freq, t_abs, amp) if waveform == 'sine' else _saw(freq, t_abs, amp)
            idx = _frames(start) + i
            if idx < n:
                out[idx] += v * env
    return out

def _lead_layer(note_seq: list[tuple[float, int, float]], total: float,
                amp=0.28, waveform='square') -> list[float]:
    n = _frames(total)
    out = [0.0] * n
    for (start, note, dur) in note_seq:
        if note is None:
            continue
        freq = midi_to_hz(note)
        for i in range(_frames(dur)):
            t_abs = start + i / SAMPLE_RATE
            t_rel = i / SAMPLE_RATE
            env = _adsr(t_rel, dur, A=0.01, D=0.04, S=0.75, R=0.06)
            if waveform == 'square':
                v = _square(freq, t_abs, amp, harmonics=5)
            else:
                v = _sine(freq, t_abs, amp)
            idx = _frames(start) + i
            if idx < n:
                out[idx] += v * env
    return out

def _pad_layer(chord_seq: list[tuple[float, list[int], float]], total: float,
               amp=0.18) -> list[float]:
    n = _frames(total)
    out = [0.0] * n
    for (start, notes, dur) in chord_seq:
        for note in notes:
            freq = midi_to_hz(note)
            for i in range(_frames(dur)):
                t_abs = start + i / SAMPLE_RATE
                t_rel = i / SAMPLE_RATE
                env = _adsr(t_rel, dur, A=0.08, D=0.1, S=0.65, R=0.2)
                v = _sine(freq, t_abs, amp / len(notes))
                idx = _frames(start) + i
                if idx < n:
                    out[idx] += v * env
    return out

def _hihat_layer(bpm: float, total: float, pattern: list[int],
                 amp=0.12) -> list[float]:
    """pattern: list of 16th-note positions (0-based) per bar that get a hit."""
    n = _frames(total)
    out = [0.0] * n
    sixteenth = 60.0 / bpm / 4
    t = 0.0
    step = 0
    while t < total:
        bar_step = step % len(pattern)
        if pattern[bar_step]:
            idx = _frames(t)
            dur_f = _frames(0.03)
            for i in range(dur_f):
                t_rel = i / SAMPLE_RATE
                env = math.exp(-t_rel * 80)
                v = _noise(step, t_rel * 8000) * amp * env
                if idx + i < n:
                    out[idx + i] += v
        t += sixteenth
        step += 1
    return out

def _kick_layer(bpm: float, total: float, beats: list[int],
                amp=0.5) -> list[float]:
    """beats: list of 16th-note positions per bar that get a kick."""
    n = _frames(total)
    out = [0.0] * n
    sixteenth = 60.0 / bpm / 4
    t = 0.0
    step = 0
    while t < total:
        bar_step = step % 16
        if bar_step in beats:
            idx = _frames(t)
            dur_f = _frames(0.15)
            for i in range(dur_f):
                t_rel = i / SAMPLE_RATE
                freq = 80 * math.exp(-t_rel * 30)
                env = math.exp(-t_rel * 20) * amp
                v = _sine(freq, t_rel) * env
                if idx + i < n:
                    out[idx + i] += v
        t += sixteenth
        step += 1
    return out

def _snare_layer(bpm: float, total: float, beats: list[int],
                 amp=0.25) -> list[float]:
    n = _frames(total)
    out = [0.0] * n
    sixteenth = 60.0 / bpm / 4
    t = 0.0
    step = 0
    seed = 99
    while t < total:
        bar_step = step % 16
        if bar_step in beats:
            idx = _frames(t)
            dur_f = _frames(0.12)
            for i in range(dur_f):
                t_rel = i / SAMPLE_RATE
                env = math.exp(-t_rel * 35) * amp
                tone = _sine(200, t_rel) * 0.4
                noise = _noise(seed + step, t_rel * 5000) * 0.6
                v = (tone + noise) * env
                if idx + i < n:
                    out[idx + i] += v
        t += sixteenth
        step += 1
    return out

# ── Song: Rhenné Theme (BPM 118, G major, playful/bouncy) ────────────────────
def _rhenne_theme() -> list[float]:
    bpm   = 118.0
    beat  = 60.0 / bpm
    bar   = beat * 4
    total = bar * 8  # 8 bars ≈ 16.3 s; looped twice = 32.6 s

    # Bass: root notes on beats 1 & 3
    bass = []
    prog = [G3, C4, D4, G3, E3, A3, D4, G3]
    for b, root in enumerate(prog):
        t = b * bar
        bass += [(t,          root,      beat * 1.8),
                 (t + beat*2, root - 12, beat * 1.8)]

    # Lead melody (light, staccato)
    lead_pattern = [
        G4, B4, D5, G5, Fs4, A4, D5, Fs5,
        G4, B4, E5, G5, D4, Fs4, A4, D5,
    ]
    lead = []
    for i, note in enumerate(lead_pattern):
        bar_i  = i // 2
        beat_i = (i % 2) * 2
        t = bar_i * bar + beat_i * beat
        lead.append((t, note, beat * 0.8))

    # Pad chords: I–IV–V–I in G
    chord_map = {G3: [G4, B4, D5], C3: [C4, E4, G4], D3: [D4, Fs4, A4], E3: [E4, G4, B4], A3: [A4, Cs5, E5]}
    chords = []
    for b, root in enumerate(prog):
        t = b * bar
        notes = chord_map.get(root, [root + 12, root + 16, root + 19])
        chords.append((t, notes, bar * 0.92))

    layers = [
        _bass_layer(bass,   total, amp=0.38, waveform='sine'),
        _lead_layer(lead,   total, amp=0.26, waveform='square'),
        _pad_layer(chords,  total, amp=0.15),
        _hihat_layer(bpm, total, [1,0,1,0, 1,0,1,0, 1,0,1,0, 1,0,1,0], amp=0.10),
        _kick_layer(bpm, total, [0, 8],  amp=0.42),
        _snare_layer(bpm, total, [4, 12], amp=0.22),
    ]
    samples = _mix(*layers)
    # Loop twice for ~32 s
    samples = samples + samples
    return _fade(samples)

# ── Song: Galleta Theme (BPM 105, C major, warm/caramel) ─────────────────────
def _galleta_theme() -> list[float]:
    bpm   = 105.0
    beat  = 60.0 / bpm
    bar   = beat * 4
    total = bar * 8

    prog = [C4, F3, G3, C4, A3, F3, G3, C4]
    bass = []
    for b, root in enumerate(prog):
        bass += [(b * bar, root, beat * 1.9),
                 (b * bar + beat * 2, root, beat * 1.5)]

    lead_notes = [E5, G5, A5, G5, F5, E5, D5, C5,
                  E5, F5, G5, A5, G5, F5, E5, D5]
    lead = []
    for i, note in enumerate(lead_notes):
        bar_i = i // 2
        beat_i = (i % 2) * 2
        lead.append((bar_i * bar + beat_i * beat, note, beat * 0.75))

    chord_map = {C4: [C4, E4, G4], F3: [F4, A4, C5], G3: [G4, B4, D5], A3: [A4, C5, E5]}
    chords = []
    for b, root in enumerate(prog):
        notes = chord_map.get(root, [root + 12, root + 16, root + 19])
        chords.append((b * bar, notes, bar * 0.88))

    layers = [
        _bass_layer(bass,  total, amp=0.36),
        _lead_layer(lead,  total, amp=0.24, waveform='sine'),
        _pad_layer(chords, total, amp=0.16),
        _hihat_layer(bpm, total, [1,0,0,1, 0,1,0,0, 1,0,0,1, 0,1,0,0], amp=0.09),
        _kick_layer(bpm, total, [0, 8],   amp=0.40),
        _snare_layer(bpm, total, [4, 12], amp=0.20),
    ]
    samples = _mix(*layers)
    samples = samples + samples
    return _fade(samples)

# ── Song: Corazón Amigos Theme (BPM 128, D major, energetic/upbeat) ──────────
def _corazon_theme() -> list[float]:
    bpm   = 128.0
    beat  = 60.0 / bpm
    bar   = beat * 4
    total = bar * 8

    prog = [D4, A3, B3, Fs4, G3, D4, A3, D4]
    bass = []
    for b, root in enumerate(prog):
        bass += [(b * bar,          root,      beat * 0.9),
                 (b * bar + beat,   root,      beat * 0.9),
                 (b * bar + beat*2, root - 12, beat * 0.9),
                 (b * bar + beat*3, root - 12, beat * 0.9)]

    chord_map = {D4:[D4,Fs4,A4], A3:[A4,Cs5,E5], B3:[B4,D5,Fs5], G3:[G4,B4,D5], Fs4:[Fs4,As4,Cs5]}
    chords = []
    for b, root in enumerate(prog):
        notes = chord_map.get(root, [root+12, root+16, root+19])
        chords.append((b * bar, notes, bar * 0.85))

    lead_notes = [D5, Fs5, A5, D5, A4, Cs5, E5, A4,
                  B4, D5, Fs5, B5, G4, B4, D5, G5]
    lead = []
    for i, note in enumerate(lead_notes):
        bar_i = i // 2
        beat_i = (i % 2) * 2
        lead.append((bar_i * bar + beat_i * beat, note, beat * 0.65))

    layers = [
        _bass_layer(bass,  total, amp=0.40, waveform='saw'),
        _lead_layer(lead,  total, amp=0.28, waveform='square'),
        _pad_layer(chords, total, amp=0.14),
        _hihat_layer(bpm, total, [1]*16, amp=0.08),
        _kick_layer(bpm, total, [0, 4, 8, 12], amp=0.45),
        _snare_layer(bpm, total, [4, 12],       amp=0.24),
    ]
    samples = _mix(*layers)
    samples = samples + samples
    return _fade(samples)

# ── Song: Memory / Night Theme (BPM 80, A minor, dreamy/gentle) ──────────────
def _memory_theme() -> list[float]:
    bpm   = 80.0
    beat  = 60.0 / bpm
    bar   = beat * 4
    total = bar * 8

    prog = [A3, C4, E4, A3, F3, C4, G3, A3]
    bass = []
    for b, root in enumerate(prog):
        bass += [(b * bar, root, beat * 3.6)]

    chord_map = {A3:[A4,C5,E5], C4:[C4,E4,G4], E4:[E4,G4,B4], F3:[F4,A4,C5], G3:[G4,B4,D5]}
    chords = []
    for b, root in enumerate(prog):
        notes = chord_map.get(root, [root+12, root+16, root+19])
        chords.append((b * bar, notes, bar * 0.95))

    lead_notes = [E5, A5, C5, E5, G5, E5, A4, C5,
                  F5, A5, C5, F5, D5, G4, B4, D5]
    lead = []
    for i, note in enumerate(lead_notes):
        bar_i = i // 2
        beat_i = (i % 2) * beat * 2
        lead.append((bar_i * bar + beat_i, note, beat * 1.6))

    layers = [
        _bass_layer(bass,  total, amp=0.32, waveform='sine'),
        _lead_layer(lead,  total, amp=0.22, waveform='sine'),
        _pad_layer(chords, total, amp=0.20),
        _hihat_layer(bpm, total, [0,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0], amp=0.06),
        _kick_layer(bpm, total, [0, 8],   amp=0.30),
        _snare_layer(bpm, total, [4, 12], amp=0.14),
    ]
    samples = _mix(*layers)
    samples = samples + samples
    return _fade(samples)

# ── Song: Concert Preview Sting (BPM 120, E major, bright/fanfare) ────────────
def _concert_preview() -> list[float]:
    bpm   = 120.0
    beat  = 60.0 / bpm
    bar   = beat * 4
    total = bar * 4  # 8 s, loops as short sting

    prog = [E3, A3, B3, E3]
    bass = []
    for b, root in enumerate(prog):
        bass += [(b * bar, root, beat * 1.9),
                 (b * bar + beat * 2, root, beat * 1.6)]

    chord_map = {E3:[E4,Gs4,B4], A3:[A4,Cs5,E5], B3:[B4,Ds5,Fs5]}
    chords = []
    for b, root in enumerate(prog):
        notes = chord_map.get(root, [root+12, root+16, root+19])
        chords.append((b * bar, notes, bar * 0.90))

    lead_notes = [Gs5, B5, E5, Gs5, Cs5, E5, A5, Cs5,
                  B4, Ds5, Fs5, B5, E5, Gs5, B5, E5]
    lead = []
    for i, note in enumerate(lead_notes[:8]):
        bar_i = i // 2
        beat_i = (i % 2) * 2
        lead.append((bar_i * bar + beat_i * beat, note, beat * 0.70))

    layers = [
        _bass_layer(bass,  total, amp=0.38),
        _lead_layer(lead,  total, amp=0.30, waveform='square'),
        _pad_layer(chords, total, amp=0.18),
        _hihat_layer(bpm, total, [1,0,1,0]*4, amp=0.10),
        _kick_layer(bpm, total, [0, 8],   amp=0.44),
        _snare_layer(bpm, total, [4, 12], amp=0.22),
    ]
    samples = _mix(*layers)
    return _fade(samples)

# ── SFX ───────────────────────────────────────────────────────────────────────

def _sfx_hit_perfect() -> list[float]:
    """Bright sparkle ding — two rising sine tones."""
    total = 0.22
    n = _frames(total)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 18)
        f1 = midi_to_hz(A5 + 12)  # high A
        f2 = midi_to_hz(E5 + 12)  # high E (perfect 5th)
        v = (_sine(f1, t, 0.5) + _sine(f2, t, 0.35)) * env
        out.append(v)
    return _fade(out, fade_in=0.002, fade_out=0.04)

def _sfx_hit_good() -> list[float]:
    """Soft marimba-like click."""
    total = 0.14
    n = _frames(total)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28)
        v = _sine(midi_to_hz(G4 + 12), t, 0.6) * env
        out.append(v)
    return _fade(out, fade_in=0.001, fade_out=0.02)

def _sfx_miss() -> list[float]:
    """Low thud / wrong-note buzz."""
    total = 0.18
    n = _frames(total)
    out = []
    seed = 7
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 22)
        tone  = _sine(midi_to_hz(C3), t, 0.4)
        noise = _noise(seed, t * 3000) * 0.2
        v = (tone + noise) * env
        out.append(v)
    return _fade(out, fade_in=0.002, fade_out=0.03)

def _sfx_coin() -> list[float]:
    """Rising coin jingle — three quick pings."""
    total = 0.35
    n = _frames(total)
    out = [0.0] * n
    pings = [(0.00, midi_to_hz(G5)),
             (0.10, midi_to_hz(B5)),
             (0.18, midi_to_hz(D5 + 12))]
    for (start, freq) in pings:
        idx = _frames(start)
        for i in range(_frames(0.18)):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 25)
            if idx + i < n:
                out[idx + i] += _sine(freq, t, 0.45) * env
    return _fade(out, fade_in=0.001, fade_out=0.05)

def _sfx_unlock() -> list[float]:
    """Magic sparkle — ascending arpeggio with shimmer."""
    total = 0.55
    n = _frames(total)
    out = [0.0] * n
    notes = [C5, E5, G5, C5 + 12, E5 + 12]
    seed = 42
    for j, note in enumerate(notes):
        start = j * 0.09
        idx = _frames(start)
        freq = midi_to_hz(note)
        for i in range(_frames(0.20)):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 15)
            shimmer = 1 + 0.003 * math.sin(2 * math.pi * 6 * t)
            v = _sine(freq * shimmer, t, 0.38) * env
            # add faint noise shimmer
            v += _noise(seed + j, t * 8000) * 0.04 * env
            if idx + i < n:
                out[idx + i] += v
    return _fade(out, fade_in=0.002, fade_out=0.08)

def _sfx_button() -> list[float]:
    """Clean two-tone blip — a musical chord tap."""
    total = 0.08
    n = _frames(total)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 35)
        v = (_sine(880, t, 0.5) + _sine(1320, t, 0.5)) * 0.5 * env
        out.append(v)
    return _fade(out, fade_in=0.002, fade_out=0.01)

# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    tasks = [
        # BGM
        (os.path.join(_BGM, 'rhenne_theme.wav'),    _rhenne_theme),
        (os.path.join(_BGM, 'galleta_theme.wav'),   _galleta_theme),
        (os.path.join(_BGM, 'corazon_theme.wav'),   _corazon_theme),
        (os.path.join(_BGM, 'memory_theme.wav'),    _memory_theme),
        (os.path.join(_BGM, 'concert_preview.wav'), _concert_preview),
        # SFX
        (os.path.join(_SFX, 'hit_perfect.wav'), _sfx_hit_perfect),
        (os.path.join(_SFX, 'hit_good.wav'),    _sfx_hit_good),
        (os.path.join(_SFX, 'miss.wav'),        _sfx_miss),
        (os.path.join(_SFX, 'coin.wav'),        _sfx_coin),
        (os.path.join(_SFX, 'unlock.wav'),      _sfx_unlock),
        (os.path.join(_SFX, 'button.wav'),      _sfx_button),
    ]

    print(f'Generating {len(tasks)} audio files...')
    for path, fn in tasks:
        samples = fn()
        # Normalise to 80% peak to avoid clipping
        peak = max(abs(s) for s in samples) or 1.0
        if peak > 0.8:
            samples = [s * 0.8 / peak for s in samples]
        _write_wav(path, samples)

    print(f'\nDone. {len(tasks)} files written.')
    print('\nOptional: convert WAV → OGG (70% smaller) with:')
    print('  brew install ffmpeg')
    print('  for f in assets/audio/**/*.wav; do')
    print('    ffmpeg -y -i "$f" "${f%.wav}.ogg" && rm "$f"')
    print('  done')
    print('Then update pubspec.yaml asset paths to *.ogg and')
    print('update LaraAudio asset path constants to use .ogg extension.')

if __name__ == '__main__':
    main()
