import 'package:flutter/material.dart';
import '../models/hymn.dart';
import '../widgets/hymn_view.dart';
import '../widgets/tune_player_sheet.dart';
import '../widgets/hymn_share_sheet.dart';

class HymnDetail extends StatefulWidget {
  final Hymn hymn;
  final void Function(Hymn) onToggleFavorite;

  const HymnDetail({
    super.key,
    required this.hymn,
    required this.onToggleFavorite,
  });

  @override
  State<HymnDetail> createState() => _HymnDetailState();
}

class _HymnDetailState extends State<HymnDetail> {
  late Hymn _currentHymn;

  @override
  void initState() {
    super.initState();
    _currentHymn = widget.hymn;
  }

  void _handleFavoriteToggle() {
    setState(() {
      _currentHymn = _currentHymn.copyWith(isFavorite: !_currentHymn.isFavorite);
    });
    widget.onToggleFavorite(_currentHymn);
  }

  void _openTunePlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TunePlayerSheet(hymn: _currentHymn),
    );
  }

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HymnShareSheet(hymn: _currentHymn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hymn ${_currentHymn.number}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.music_note_rounded),
            tooltip: 'Tune & melody accompaniment',
            onPressed: _openTunePlayer,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share & copy lyrics',
            onPressed: _openShareSheet,
          ),
          IconButton(
            icon: Icon(
              _currentHymn.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentHymn.isFavorite ? Colors.red : null,
            ),
            tooltip: _currentHymn.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _handleFavoriteToggle,
          ),
        ],
      ),
      body: HymnView(hymn: _currentHymn),
    );
  }
}
