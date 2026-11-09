import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/hymn.dart';
import '../services/tune_audio_service.dart';

class TunePlayerSheet extends StatefulWidget {
  final Hymn hymn;

  const TunePlayerSheet({super.key, required this.hymn});

  @override
  State<TunePlayerSheet> createState() => _TunePlayerSheetState();
}

class _TunePlayerSheetState extends State<TunePlayerSheet> {
  final _audioService = TuneAudioService.instance;
  bool _isPlaying = false;
  double _tempo = 92.0;
  InstrumentType _instrument = InstrumentType.churchOrgan;
  String? _activePitch;

  @override
  void initState() {
    super.initState();
    _tempo = _audioService.tempoBpm;
    _instrument = _audioService.instrument;
    _audioService.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  void _togglePlayMelody() async {
    if (_isPlaying) {
      await _audioService.stop();
      setState(() => _isPlaying = false);
    } else {
      _audioService.setTempo(_tempo);
      _audioService.setInstrument(_instrument);
      await _audioService.playHymnMelody(widget.hymn);
      setState(() => _isPlaying = true);
    }
  }

  void _playPitch(String pitchName, double freq) async {
    setState(() => _activePitch = pitchName);
    await _audioService.playPitch(freq);
    if (mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _activePitch == pitchName) {
          setState(() => _activePitch = null);
        }
      });
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.church_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hymn ${widget.hymn.number} Church Melody',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.hymn.reference != null && widget.hymn.reference!.isNotEmpty
                          ? 'Tune Ref: ${widget.hymn.reference}'
                          : 'Full Church Hymn Accompaniment',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Instrument Selector (Organ vs Piano vs Solo)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInstrumentChip('Church Organ', InstrumentType.churchOrgan, Icons.church),
              const SizedBox(width: 8),
              _buildInstrumentChip('Piano', InstrumentType.piano, Icons.piano),
              const SizedBox(width: 8),
              _buildInstrumentChip('Solo Lead', InstrumentType.soloLead, Icons.music_note),
            ],
          ),

          const SizedBox(height: 14),

          // Main Melody Play/Stop Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262C38) : Colors.blue.shade50.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                IconButton.filled(
                  iconSize: 34,
                  icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  tooltip: _isPlaying ? 'Stop tune' : 'Play accompaniment',
                  onPressed: _togglePlayMelody,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPlaying
                            ? 'Playing Hymn Accompaniment...'
                            : 'Play Church Hymn Tune',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _instrument == InstrumentType.churchOrgan
                            ? 'Majestic Pipe Organ with SATB harmony'
                            : _instrument == InstrumentType.piano
                                ? 'Acoustic piano hymn chords'
                                : 'Melody guide for singers',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tempo control
          Row(
            children: [
              const Icon(Icons.speed, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Tempo (${_tempo.round()} BPM)',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Expanded(
                child: Slider(
                  value: _tempo,
                  min: 60.0,
                  max: 130.0,
                  divisions: 14,
                  onChanged: (val) {
                    setState(() {
                      _tempo = val;
                      _audioService.setTempo(val);
                    });
                  },
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Choir Pitch Pipe Section
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Choir Precentor Pitch Pipe (Starting Key)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Sound the opening key for choir and congregation:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // Pitch chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TuneAudioService.standardPitches.entries.map((entry) {
              final isPitchActive = _activePitch == entry.key;
              return ActionChip(
                avatar: Icon(
                  Icons.volume_up,
                  size: 16,
                  color: isPitchActive ? Colors.white : theme.colorScheme.primary,
                ),
                label: Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPitchActive ? Colors.white : null,
                  ),
                ),
                backgroundColor: isPitchActive ? theme.colorScheme.primary : null,
                onPressed: () => _playPitch(entry.key, entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentChip(String label, InstrumentType type, IconData icon) {
    final isSelected = _instrument == type;
    final theme = Theme.of(context);

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : theme.colorScheme.primary,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _instrument = type;
            _audioService.setInstrument(type);
          });
          if (_isPlaying) {
            _audioService.stop();
            _togglePlayMelody();
          }
        }
      },
    );
  }
}
