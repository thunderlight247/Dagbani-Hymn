import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/hymn_loader.dart';
import '../models/hymn.dart';
import '../models/uploaded_hymn_audio.dart';
import '../services/uploaded_audio_service.dart';
import '../hymns/hymn_detail.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _audioService = UploadedAudioService.instance;
  final _player = AudioPlayer();

  List<Hymn> _allHymns = [];
  Hymn? _selectedHymn;
  String _selectedAudioType = 'Keyboard / Organ Play';
  final _performerController = TextEditingController();
  final _notesController = TextEditingController();

  PlatformFile? _pickedFile;
  bool _isLoadingHymns = true;
  bool _isSaving = false;

  String? _currentlyPlayingId;
  PlayerState _playerState = PlayerState.stopped;

  final List<String> _audioTypes = [
    'Keyboard / Organ Play',
    'Choir / Congregation',
    'Solo / Leader Vocal',
    'General Hymn Tune',
  ];

  @override
  void initState() {
    super.initState();
    _loadHymns();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
  }

  Future<void> _loadHymns() async {
    final hymns = await HymnLoader.loadHymnsFromAssets();
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    final savedCong = prefs.getString('user_congregation');

    if (mounted) {
      setState(() {
        _allHymns = hymns;
        if (_allHymns.isNotEmpty) {
          _selectedHymn = _allHymns.first;
        }
        if (_performerController.text.isEmpty && savedName != null && savedName.isNotEmpty) {
          _performerController.text = (savedCong != null && savedCong.isNotEmpty)
              ? '$savedName ($savedCong)'
              : savedName;
        }
        _isLoadingHymns = false;
      });
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'wma', 'opus'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  Future<void> _saveAndLinkAudio() async {
    if (_selectedHymn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a hymn to link this audio to.')),
      );
      return;
    }

    if (_pickedFile == null || _pickedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audio file to upload.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _audioService.saveAudio(
        hymnNumber: _selectedHymn!.number,
        hymnTitle: _selectedHymn!.title,
        sourceFilePath: _pickedFile!.path!,
        originalFileName: _pickedFile!.name,
        audioType: _selectedAudioType,
        uploaderName: _performerController.text.trim().isNotEmpty
            ? _performerController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final uploadedHymn = _selectedHymn!;

      if (!mounted) return;

      setState(() {
        _pickedFile = null;
        _performerController.clear();
        _notesController.clear();
        _isSaving = false;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 10),
              const Text('Audio Uploaded!'),
            ],
          ),
          content: Text(
            'The audio has been linked to Hymn ${uploadedHymn.number}: "${uploadedHymn.title}".\n\n'
            'A playback button will now automatically appear on this hymn so congregation and choir members can listen to it while reading the lyrics!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HymnDetail(
                      hymn: uploadedHymn,
                      onToggleFavorite: (_) {},
                    ),
                  ),
                );
              },
              child: const Text('View Hymn Now'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving audio: $e')),
        );
      }
    }
  }

  void _showHymnPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _allHymns.where((h) {
              if (filter.isEmpty) return true;
              final q = filter.toLowerCase().trim();
              return h.number.contains(q) ||
                  h.title.toLowerCase().contains(q) ||
                  h.page.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Hymn for Audio Upload',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by hymn number or title...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => filter = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final hymn = filtered[index];
                        final isSelected = _selectedHymn?.id == hymn.id;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade200,
                            foregroundColor: isSelected ? Colors.white : Colors.black87,
                            child: Text(hymn.number, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(hymn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Page ${hymn.page} • ${hymn.category ?? "Hymn"}'),
                          trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () {
                            setState(() => _selectedHymn = hymn);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _togglePlayUploaded(UploadedHymnAudio audio) async {
    if (_currentlyPlayingId == audio.id && _playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.stop();
      setState(() => _currentlyPlayingId = audio.id);
      await _player.play(DeviceFileSource(audio.filePath));
    }
  }

  @override
  void dispose() {
    _performerController.dispose();
    _notesController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hymn Audio Uploads'),
        centerTitle: true,
      ),
      body: _isLoadingHymns
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: _audioService,
              builder: (context, _) {
                final uploadedList = _audioService.audios;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    // SECTION 1: UPLOAD HYMN AUDIO
                    _buildSectionHeader(
                      context,
                      'Upload Hymn Audio / Keyboard Sound',
                      Icons.cloud_upload_rounded,
                    ),
                    const SizedBox(height: 8),

                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Select Hymn Target
                            const Text(
                              '1. Select Target Hymn',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _showHymnPicker,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF262C38) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _selectedHymn != null ? 'Hymn ${_selectedHymn!.number}' : 'Select',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedHymn != null ? _selectedHymn!.title : 'Tap to choose hymn',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 2. Select Audio Type
                            const Text(
                              '2. Audio Sound Type',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _audioTypes.map((type) {
                                final isSelected = _selectedAudioType == type;
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) setState(() => _selectedAudioType = type);
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 18),

                            // 3. Performer / Congregation Info
                            const Text(
                              '3. Performer / Congregation (Optional)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _performerController,
                              decoration: InputDecoration(
                                hintText: 'e.g. Played by Organist John / Tamale Congregation Choir',
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 4. Select Audio File
                            const Text(
                              '4. Audio File (MP3, M4A, WAV, AAC)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),

                            _pickedFile == null
                                ? OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.audio_file_rounded),
                                    label: const Text('Choose Audio File from Device'),
                                    onPressed: _pickAudioFile,
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.green),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _pickedFile!.name,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${(_pickedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.refresh),
                                          tooltip: 'Change file',
                                          onPressed: _pickAudioFile,
                                        ),
                                      ],
                                    ),
                                  ),

                            const SizedBox(height: 20),

                            // 5. Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: _isSaving ? null : _saveAndLinkAudio,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  _isSaving ? 'Linking Audio...' : 'Save & Link Audio to Hymn',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // SECTION 2: UPLOADED HYMN AUDIOS LIBRARY
                    _buildSectionHeader(
                      context,
                      'Uploaded Hymn Audios (${uploadedList.length})',
                      Icons.library_music_rounded,
                    ),
                    const SizedBox(height: 8),

                    uploadedList.isEmpty
                        ? Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.queue_music_rounded, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No Hymn Audios Uploaded Yet',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'When you upload an audio or keyboard accompaniment using the form above, it will be listed here and will automatically show a play button whenever you read that hymn!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: uploadedList.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final audio = uploadedList[index];
                              final isPlayingThis =
                                  _currentlyPlayingId == audio.id && _playerState == PlayerState.playing;

                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                    child: Text(
                                      audio.hymnNumber,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Hymn ${audio.hymnNumber}: ${audio.hymnTitle}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    '${audio.audioType}${audio.uploaderName != null ? " • ${audio.uploaderName}" : ""}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(isPlayingThis ? Icons.pause_circle_filled : Icons.play_circle_filled),
                                        iconSize: 32,
                                        color: theme.colorScheme.primary,
                                        tooltip: isPlayingThis ? 'Pause' : 'Play',
                                        onPressed: () => _togglePlayUploaded(audio),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                        tooltip: 'Delete audio',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Uploaded Audio?'),
                                              content: Text(
                                                'Remove audio recording for Hymn ${audio.hymnNumber}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    _audioService.deleteAudio(audio.id);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 28),

                    // SECTION 3: CHURCH RECORDINGS GUIDE
                    _buildSectionHeader(
                      context,
                      'Audio Recording Tips & Guide',
                      Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 8),

                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Presbyterian Worship Audio Guidelines:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Keyboard / Organ accompaniment should be recorded with steady tempo so the congregation can follow along easily.\n'
                              '• Ensure the phone or recording microphone is placed 1 to 2 meters away from the organ or choir speakers to prevent audio distortion.\n'
                              '• Supported formats: MP3, M4A, WAV, and AAC.\n'
                              '• Any uploaded audio is stored locally on this device for offline playback during church service.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
