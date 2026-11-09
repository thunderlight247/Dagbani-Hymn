import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/hymn.dart';

enum InstrumentType {
  churchOrgan,
  piano,
  soloLead,
}

class HymnChord {
  final double melodyFreq;
  final List<double> harmonyFreqs;
  final double durationSeconds;
  final String noteName;

  const HymnChord({
    required this.melodyFreq,
    this.harmonyFreqs = const [],
    required this.durationSeconds,
    this.noteName = '',
  });
}

class TuneAudioService {
  static final TuneAudioService instance = TuneAudioService._();
  TuneAudioService._();

  AudioPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Hymn? _currentHymn;
  double _tempoBpm = 92.0;
  InstrumentType _instrument = InstrumentType.churchOrgan;

  AudioPlayer get audioPlayer {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  PlayerState get playerState => _playerState;
  Hymn? get currentHymn => _currentHymn;
  double get tempoBpm => _tempoBpm;
  InstrumentType get instrument => _instrument;

  static const Map<String, double> standardPitches = {
    'C4': 261.63,
    'D4': 293.66,
    'E♭4': 311.13,
    'E4': 329.63,
    'F4': 349.23,
    'G4': 392.00,
    'A♭4': 415.30,
    'A4': 440.00,
    'B♭4': 466.16,
    'B4': 493.88,
    'C5': 523.25,
  };

  void setTempo(double bpm) {
    _tempoBpm = bpm.clamp(60.0, 140.0);
  }

  void setInstrument(InstrumentType type) {
    _instrument = type;
  }

  /// Plays a single pitch pipe reference note for choir precentors
  Future<void> playPitch(double frequency, {double duration = 2.5}) async {
    try {
      await audioPlayer.stop();
      final bytes = _synthesizeWav([
        HymnChord(
          melodyFreq: frequency,
          harmonyFreqs: [frequency / 2.0], // Octave warmth
          durationSeconds: duration,
          noteName: 'Pitch',
        ),
      ]);
      await audioPlayer.play(BytesSource(bytes));
    } catch (e) {
      debugPrint('Error playing pitch: $e');
    }
  }

  /// Synthesizes and plays the harmonic church hymn accompaniment
  Future<void> playHymnMelody(Hymn hymn) async {
    try {
      await audioPlayer.stop();
      _currentHymn = hymn;
      _playerState = PlayerState.playing;

      final chords = _getChordsForHymn(hymn);
      final bytes = _synthesizeWav(chords);

      await audioPlayer.play(BytesSource(bytes));

      audioPlayer.onPlayerStateChanged.listen((state) {
        _playerState = state;
      });
    } catch (e) {
      debugPrint('Error playing hymn tune: $e');
      _playerState = PlayerState.stopped;
    }
  }

  Future<void> stop() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
      _playerState = PlayerState.stopped;
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
      }
      _playerState = PlayerState.paused;
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.resume();
      }
      _playerState = PlayerState.playing;
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  /// Authentic SATB church hymn chords for hymns
  List<HymnChord> _getChordsForHymn(Hymn hymn) {
    final beat = 60.0 / _tempoBpm;
    final hymnNum = int.tryParse(hymn.number) ?? 1;
    final isChorus = hymn.category?.toLowerCase().contains('chorus') ?? false;

    // Hymn 1: Lobe den Herren (Praise to the Lord, the Almighty) in G Major
    if (hymnNum == 1 && !isChorus) {
      return [
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 587.33, harmonyFreqs: [440.00, 369.99, 293.66], durationSeconds: beat * 1.5, noteName: 'D5'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 0.5, noteName: 'C5'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [329.63, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [329.63, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 1.0, noteName: 'C5'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.5, noteName: 'B4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [369.99, 293.66, 220.00], durationSeconds: beat * 0.5, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 2.5, noteName: 'G4'),
      ];
    }

    // Hymn 2: Old 100th (All People That on Earth Do Dwell / PHB 2) in G Major
    if (hymnNum == 2 && !isChorus) {
      return [
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.5, noteName: 'G4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 369.99, harmonyFreqs: [293.66, 220.00, 184.99], durationSeconds: beat * 1.0, noteName: 'F#4'),
        HymnChord(melodyFreq: 329.63, harmonyFreqs: [261.63, 196.00, 164.81], durationSeconds: beat * 1.0, noteName: 'E4'),
        HymnChord(melodyFreq: 293.66, harmonyFreqs: [220.00, 184.99, 146.83], durationSeconds: beat * 1.0, noteName: 'D4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [329.63, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 2.0, noteName: 'B4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [329.63, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [329.63, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 246.94, 196.00], durationSeconds: beat * 2.5, noteName: 'G4'),
      ];
    }

    // Hymn 3 / PHB 3 in F Major
    if (hymnNum == 3 && !isChorus) {
      return [
        HymnChord(melodyFreq: 349.23, harmonyFreqs: [261.63, 220.00, 174.61], durationSeconds: beat * 1.0, noteName: 'F4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [440.00, 349.23, 261.63], durationSeconds: beat * 1.5, noteName: 'C5'),
        HymnChord(melodyFreq: 466.16, harmonyFreqs: [349.23, 293.66, 233.08], durationSeconds: beat * 0.5, noteName: 'B♭4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [293.66, 261.63, 196.00], durationSeconds: beat * 1.0, noteName: 'G4'),
        HymnChord(melodyFreq: 349.23, harmonyFreqs: [261.63, 220.00, 174.61], durationSeconds: beat * 2.0, noteName: 'F4'),
      ];
    }

    // Joyful Dagbani Choruses (Call-and-Response Gospel Harmonies)
    if (isChorus) {
      return [
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [329.63, 261.63, 196.00], durationSeconds: beat * 0.75, noteName: 'G4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 0.75, noteName: 'A4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [440.00, 329.63, 261.63], durationSeconds: beat * 1.0, noteName: 'C5'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 0.75, noteName: 'B4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 0.75, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [329.63, 261.63, 196.00], durationSeconds: beat * 1.5, noteName: 'G4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [369.99, 293.66, 220.00], durationSeconds: beat * 0.5, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [329.63, 261.63, 196.00], durationSeconds: beat * 2.0, noteName: 'G4'),
      ];
    }

    // St. Anne / Classic Church Hymn Progression for general hymns
    if (hymnNum % 2 == 0) {
      return [
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 1.0, noteName: 'C5'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 1.0, noteName: 'C5'),
        HymnChord(melodyFreq: 587.33, harmonyFreqs: [440.00, 349.23, 293.66], durationSeconds: beat * 1.5, noteName: 'D5'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 2.5, noteName: 'C5'),
      ];
    } else {
      // Regent Square / Westminster style hymn cadence
      return [
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 1.0, noteName: 'A4'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 1.0, noteName: 'B4'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 1.0, noteName: 'C5'),
        HymnChord(melodyFreq: 587.33, harmonyFreqs: [440.00, 349.23, 293.66], durationSeconds: beat * 1.5, noteName: 'D5'),
        HymnChord(melodyFreq: 523.25, harmonyFreqs: [392.00, 329.63, 261.63], durationSeconds: beat * 0.75, noteName: 'C5'),
        HymnChord(melodyFreq: 493.88, harmonyFreqs: [392.00, 293.66, 246.94], durationSeconds: beat * 0.75, noteName: 'B4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 1.5, noteName: 'A4'),
        HymnChord(melodyFreq: 392.00, harmonyFreqs: [329.63, 261.63, 196.00], durationSeconds: beat * 0.5, noteName: 'G4'),
        HymnChord(melodyFreq: 440.00, harmonyFreqs: [349.23, 261.63, 220.00], durationSeconds: beat * 2.5, noteName: 'A4'),
      ];
    }
  }

  /// Synthesizes 16-bit 44.1kHz PCM WAV with church organ or acoustic piano harmonics
  Uint8List _synthesizeWav(List<HymnChord> chords) {
    const int sampleRate = 44100;
    const int numChannels = 1;
    const int bitsPerSample = 16;

    double totalSeconds = 0;
    for (var chord in chords) {
      totalSeconds += chord.durationSeconds;
    }
    totalSeconds += 0.5; // Natural cathedral room reverberation tail

    final int numSamples = (totalSeconds * sampleRate).toInt();
    final int dataByteLength = numSamples * numChannels * (bitsPerSample ~/ 8);

    final ByteData byteData = ByteData(44 + dataByteLength);

    // RIFF Header
    _writeString(byteData, 0, 'RIFF');
    byteData.setUint32(4, 36 + dataByteLength, Endian.little);
    _writeString(byteData, 8, 'WAVE');

    // fmt chunk
    _writeString(byteData, 12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little); // PCM
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * numChannels * (bitsPerSample ~/ 8), Endian.little);
    byteData.setUint16(32, numChannels * (bitsPerSample ~/ 8), Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    _writeString(byteData, 36, 'data');
    byteData.setUint32(40, dataByteLength, Endian.little);

    int currentSample = 0;

    for (var chord in chords) {
      final int noteSamples = (chord.durationSeconds * sampleRate).toInt();

      for (int i = 0; i < noteSamples && currentSample < numSamples; i++, currentSample++) {
        final double t = i / sampleRate;
        final double progress = i / noteSamples;

        // Envelope
        double envelope = 1.0;
        if (_instrument == InstrumentType.churchOrgan) {
          // Organ: soft swell attack, sustained, smooth release
          if (progress < 0.04) {
            envelope = progress / 0.04;
          } else if (progress > 0.85) {
            envelope = (1.0 - progress) / 0.15;
          }
        } else {
          // Piano: fast percussive attack + exponential decay
          if (progress < 0.02) {
            envelope = progress / 0.02;
          } else {
            envelope = exp(-progress * 2.5);
          }
        }

        // Church Organ or Piano multi-stop sound
        double chordSample = 0.0;

        // 1. Soprano Lead Melody
        chordSample += _renderVoice(chord.melodyFreq, t, 0.45);

        // 2. Alto / Tenor Harmony Voices (if not solo lead mode)
        if (_instrument != InstrumentType.soloLead) {
          for (var hFreq in chord.harmonyFreqs) {
            chordSample += _renderVoice(hFreq, t, 0.20);
          }
          // 3. Deep 16' Bass Pedal (one octave down)
          chordSample += _renderVoice(chord.melodyFreq / 2.0, t, 0.22);
        }

        final double finalValue = (chordSample * envelope).clamp(-1.0, 1.0);
        final int intSample = (finalValue * 31000).toInt();
        byteData.setInt16(44 + currentSample * 2, intSample, Endian.little);
      }
    }

    return byteData.buffer.asUint8List();
  }

  /// Organ pipe harmonics generator (8' diapason, 4' octave, 2 2/3' quint, 16' pedal)
  double _renderVoice(double freq, double t, double volume) {
    if (freq <= 0) return 0.0;

    if (_instrument == InstrumentType.churchOrgan) {
      // Pipe organ with warm cathedral vibrato
      final double vibrato = 1.0 + 0.003 * sin(2 * pi * 4.8 * t);
      final double f = freq * vibrato;

      return (sin(2 * pi * f * t) * 0.65 + // 8' Principal
              sin(2 * pi * f * 2 * t) * 0.25 + // 4' Octave
              sin(2 * pi * f * 3 * t) * 0.10 // 2 2/3' Quint
          ) *
          volume;
    } else if (_instrument == InstrumentType.piano) {
      // Acoustic piano harmonics
      return (sin(2 * pi * freq * t) * 0.70 +
              sin(2 * pi * freq * 2 * t) * 0.20 +
              sin(2 * pi * freq * 3 * t) * 0.07 +
              sin(2 * pi * freq * 4 * t) * 0.03) *
          volume;
    } else {
      // Solo melodic line
      return sin(2 * pi * freq * t) * volume;
    }
  }

  void _writeString(ByteData byteData, int offset, String string) {
    for (int i = 0; i < string.length; i++) {
      byteData.setUint8(offset + i, string.codeUnitAt(i));
    }
  }
}
