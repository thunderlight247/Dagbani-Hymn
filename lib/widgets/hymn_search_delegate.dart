import 'package:flutter/material.dart';
import '../models/hymn.dart';
import '../models/settings_model.dart';
import 'package:provider/provider.dart';

class HymnSearchDelegate extends SearchDelegate<Hymn?> {
  final List<Hymn> hymns;
  String _selectedCategory = 'All';

  HymnSearchDelegate({required this.hymns})
      : super(
          searchFieldLabel: 'Hymn #, title, or 1, 1 / 1, 48',
          searchFieldStyle: const TextStyle(fontSize: 16),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: isDark ? const Color(0xFF1A1F29) : const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          tooltip: 'Clear',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      tooltip: 'Back',
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context, listen: false);
    final theme = Theme.of(context);
    final cleanQuery = query.toLowerCase().trim();

    // Check for "number, page" or "page, number" pattern (e.g., "1, 1" or "1, 48")
    final commaRegex = RegExp(r'^\s*(\d+)\s*,\s*(\d+)\s*$');
    final match = commaRegex.firstMatch(cleanQuery);

    List<Hymn> baseResults = [];

    if (match != null) {
      final val1 = match.group(1)!;
      final val2 = match.group(2)!;

      // Check both (number=val1, page=val2) and (page=val1, number=val2)
      baseResults = hymns.where((h) {
        final matchesStandard = h.number == val1 && h.page == val2;
        final matchesReversed = h.number == val2 && h.page == val1;
        return matchesStandard || matchesReversed;
      }).toList();
    } else if (cleanQuery.isEmpty) {
      baseResults = hymns;
    } else {
      baseResults = hymns.where((h) {
        final numMatch = h.number.toLowerCase() == cleanQuery ||
            h.number.toLowerCase().startsWith(cleanQuery);
        final titleMatch = h.title.toLowerCase().contains(cleanQuery);
        final pageMatch = h.page.toLowerCase() == cleanQuery;
        final transMatch = h.translation?.toLowerCase().contains(cleanQuery) ?? false;
        final catMatch = h.category?.toLowerCase().contains(cleanQuery) ?? false;
        final lyricsMatch = h.content.any((stanza) => stanza.toLowerCase().contains(cleanQuery));

        return numMatch || titleMatch || pageMatch || transMatch || catMatch || lyricsMatch;
      }).toList();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        final displayedResults = baseResults.where((h) {
          final isChorus = h.category?.toLowerCase().contains('chorus') ?? false;
          if (_selectedCategory == 'Hymns') {
            return !isChorus;
          } else if (_selectedCategory == 'Dagbani Choruses') {
            return isChorus;
          }
          return true;
        }).toList();

        final hymnsCount = baseResults.where((h) => !(h.category?.toLowerCase().contains('chorus') ?? false)).length;
        final chorusesCount = baseResults.where((h) => h.category?.toLowerCase().contains('chorus') ?? false).length;

        return Column(
          children: [
            // Instructions banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search by hymn number, title, page (e.g., 1, 1 or 1, 48)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _filterChip(
                    label: 'All (${baseResults.length})',
                    isSelected: _selectedCategory == 'All',
                    onSelected: () => setState(() => _selectedCategory = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: 'Hymns ($hymnsCount)',
                    isSelected: _selectedCategory == 'Hymns',
                    onSelected: () => setState(() => _selectedCategory = 'Hymns'),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: 'Dagbani Choruses ($chorusesCount)',
                    isSelected: _selectedCategory == 'Dagbani Choruses',
                    onSelected: () => setState(() => _selectedCategory = 'Dagbani Choruses'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Results List
            Expanded(
              child: displayedResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedCategory != 'All'
                                  ? 'No $_selectedCategory found for "$query"'
                                  : 'No hymns found for "$query"',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tip: Try typing "1, 1" for Hymn 1 or "1, 48" for Chorus 1',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: displayedResults.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final hymn = displayedResults[index];
                        final isChorus = hymn.category?.toLowerCase().contains('chorus') ?? false;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isChorus
                                ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                                : theme.colorScheme.primary.withValues(alpha: 0.15),
                            child: Text(
                              hymn.number,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isChorus
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            hymn.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: settings.getTextStyle(
                              size: 15,
                              weight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            hymn.translation != null && hymn.translation!.isNotEmpty
                                ? '${hymn.translation} • Page ${hymn.page}'
                                : '${hymn.category ?? "Hymn"} • Page ${hymn.page}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: hymn.isFavorite
                              ? const Icon(Icons.favorite, color: Colors.red, size: 20)
                              : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          onTap: () => close(context, hymn),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
