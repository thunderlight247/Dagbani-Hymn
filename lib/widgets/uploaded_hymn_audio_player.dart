import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/uploaded_hymn_audio.dart';

class UploadedHymnAudioPlayer extends StatefulWidget {
  final UploadedHymnAudio audio;

  const UploadedHymnAudioPlayer({super.key, required this.audio});

  @override
  State<UploadedHymnAudioPlayer> createState() => _UploadedHymnAudioPlayerState();
}

class _UploadedHymnAudioPlayerState extends State<UploadedHymnAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  void _initAudio() {
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    _player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  Future<void> _togglePlay() async {
    try {
      if (_playerState == PlayerState.playing) {
        await _player.pause();
      } else {
        if (!kIsWeb && File(widget.audio.filePath).existsSync()) {
          await _player.play(DeviceFileSource(widget.audio.filePath));
        } else {
          // If URL or virtual source
          await _player.play(UrlSource(widget.audio.filePath));
        }
      }
    } catch (e) {
      debugPrint('Error playing uploaded audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not play audio file: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _seek(double seconds) async {
    await _player.seek(Duration(seconds: seconds.toInt()));
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262C38) : Colors.blue.shade50.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.audiotrack_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.audio.audioType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Uploaded Recording',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (widget.audio.uploaderName != null && widget.audio.uploaderName!.isNotEmpty)
                      Text(
                        'By ${widget.audio.uploaderName}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    else if (widget.audio.notes != null && widget.audio.notes!.isNotEmpty)
                      Text(
                        widget.audio.notes!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Player controls
          Row(
            children: [
              IconButton.filled(
                iconSize: 28,
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: _togglePlay,
                tooltip: isPlaying ? 'Pause' : 'Play',
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_position),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble().clamp(
                        0.0,
                        _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                      ),
                  max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                  onChanged: (val) => _seek(val),
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
