import 'package:flutter/material.dart';
import '../widgets/toc_section.dart';
import '../widgets/bottom_nav.dart';
import '../db/hymn_loader.dart';
import '../models/hymn.dart';
import '../hymns/hymn_detail.dart';
import '../widgets/search_bar.dart' as custom;
// import '../db/hymn_database.dart'; // Uncomment if needed later

class TOCScreen extends StatefulWidget {
  final void Function(Hymn)? onDirectSearch;
  final void Function(Hymn) onToggleFavorite; // CRITICAL: Added required function

  const TOCScreen({
    super.key, 
    this.onDirectSearch,
    required this.onToggleFavorite, // CRITICAL: Added to constructor
  });

  @override
  State<TOCScreen> createState() => _TOCScreenState();
}

class _TOCScreenState extends State<TOCScreen> {
  // RESTORED: State variables
  String _searchQuery = '';
  List<Hymn> _hymns = [];
  List<Hymn> _filteredHymns = [];
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadHymns();
  }

  // RESTORED: _loadHymns method
  Future<void> _loadHymns() async {
    final hymns = await HymnLoader.loadHymnsFromAssets();
    setState(() {
      _hymns = hymns;
      _filteredHymns = List.from(hymns);
    });
  }

  // RESTORED: _handleSearch method
  void _handleSearch(String value) {
    final query = value.toLowerCase().trim();
    setState(() {
      _searchQuery = value;
      _searchError = null;

      // Handle "number, page" quick search
      final commaMatch = RegExp(r'^\s*\d+\s*,\s*\d+\s*$');
      if (commaMatch.hasMatch(query)) {
        final parts = query.split(',').map((s) => s.trim()).toList();
        if (parts.length == 2) {
          final number = parts[0];
          final page = parts[1];

          final match = _hymns.firstWhere(
            (hymn) =>
                hymn.number.toLowerCase() == number &&
                hymn.page.toLowerCase() == page,
            orElse: () => Hymn(id: 0, number: '', title: '', page: '', content: []),
          );

          if (match.id != 0 && widget.onDirectSearch != null && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onDirectSearch!(match);
              _searchQuery = ''; 
              _filteredHymns = List.from(_hymns); 
            });
            return; 
          } else {
            _searchError = 'No hymn or chorus found for "$number, $page"';
          }
        }
      }

      // Filter for partial matches
      _filteredHymns = _hymns.where((hymn) {
        final number = hymn.number.toLowerCase();
        final title = hymn.title.toLowerCase();
        final page = hymn.page.toLowerCase();
        final translation = hymn.translation?.toLowerCase() ?? '';
        final category = hymn.category?.toLowerCase() ?? '';
        return number.contains(query) ||
            title.contains(query) ||
            page.contains(query) ||
            translation.contains(query) ||
            category.contains(query);
      }).toList();

      if (_filteredHymns.isEmpty && query.isNotEmpty) {
        _searchError = 'No matches found for "$query"';
      }
    });
  }

  // RESTORED: _groupByCategory method
  Map<String, List<Hymn>> _groupByCategory(List<Hymn> hymns) {
    final Map<String, List<Hymn>> grouped = {};
    for (var hymn in hymns) {
      final category = hymn.category?.trim() ?? 'Hymns';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(hymn);
    }
    // Sort categories to prioritize "Dagbani Choruses"
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Dagbani Choruses') return -1;
        if (b == 'Dagbani Choruses') return 1;
        return a.compareTo(b);
      });
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  @override
  Widget build(BuildContext context) {
    final groupedHymns = _groupByCategory(_filteredHymns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table of Contents'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          custom.SearchBar(
            onChanged: _handleSearch,
            hintText: 'Search title, number, page, or category (e.g., 1, 1 or 1, 48)',
            errorText: _searchError,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: groupedHymns.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final category = groupedHymns.keys.elementAt(index);
                final hymns = groupedHymns[category]!;
                return TOCSection(
                  title: category,
                  hymns: hymns,
                  onTap: (hymn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HymnDetail(
                          hymn: hymn,
                          onToggleFavorite: widget.onToggleFavorite, // THE FIXED CALL
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}