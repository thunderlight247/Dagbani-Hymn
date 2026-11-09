import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn.dart';
import '../models/settings_model.dart';
import '../widgets/hymn_search_delegate.dart';

class HymnLibraryScreen extends StatefulWidget {
  final int initialIndex;
  final List<Hymn> hymns;
  final List<Hymn> favoriteHymns;
  final void Function(Hymn) onToggleFavorite;
  final void Function(Hymn) onSelectHymn;

  const HymnLibraryScreen({
    super.key,
    this.initialIndex = 0,
    required this.hymns,
    required this.favoriteHymns,
    required this.onToggleFavorite,
    required this.onSelectHymn,
  });

  @override
  State<HymnLibraryScreen> createState() => _HymnLibraryScreenState();
}

class _HymnLibraryScreenState extends State<HymnLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _contentsFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<Hymn>> _getGroupedHymns() {
    final query = _contentsFilter.toLowerCase().trim();
    final filtered = widget.hymns.where((h) {
      if (query.isEmpty) return true;
      return h.number.toLowerCase().contains(query) ||
          h.title.toLowerCase().contains(query) ||
          h.page.toLowerCase().contains(query) ||
          (h.translation?.toLowerCase().contains(query) ?? false) ||
          (h.category?.toLowerCase().contains(query) ?? false);
    }).toList();

    final Map<String, List<Hymn>> grouped = {};
    for (var hymn in filtered) {
      final category = hymn.category?.trim() ?? 'Hymns';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(hymn);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a.toLowerCase().contains('hymn')) return -1;
        if (b.toLowerCase().contains('hymn')) return 1;
        return a.compareTo(b);
      });

    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsModel>(context);
    final groupedHymns = _getGroupedHymns();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hymn Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search hymns',
            onPressed: () async {
              final navigator = Navigator.of(context);
              final selected = await showSearch<Hymn?>(
                context: context,
                delegate: HymnSearchDelegate(hymns: widget.hymns),
              );
              if (!mounted) return;
              if (selected != null) {
                widget.onSelectHymn(selected);
                navigator.pop();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: [
            const Tab(
              icon: Icon(Icons.format_list_bulleted),
              text: 'Contents',
            ),
            Tab(
              icon: const Icon(Icons.favorite),
              text: 'Favorites (${widget.favoriteHymns.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: TABLE OF CONTENTS
          Column(
            children: [
              // Search in contents
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Filter contents by title, number, or page...',
                    prefixIcon: const Icon(Icons.filter_list),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _contentsFilter = val;
                    });
                  },
                ),
              ),

              Expanded(
                child: groupedHymns.isEmpty
                    ? Center(
                        child: Text(
                          'No hymns found.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: groupedHymns.length,
                        itemBuilder: (context, catIndex) {
                          final category = groupedHymns.keys.elementAt(catIndex);
                          final hymns = groupedHymns[category]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                child: Text(
                                  '$category (${hymns.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              ...hymns.map((hymn) {
                                final isChorus =
                                    hymn.category?.toLowerCase().contains('chorus') ?? false;

                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isChorus
                                        ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                                        : theme.colorScheme.primary.withValues(alpha: 0.15),
                                    child: Text(
                                      hymn.number,
                                      style: TextStyle(
                                        fontSize: 13,
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
                                        : 'Page ${hymn.page}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      hymn.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: hymn.isFavorite ? Colors.red : Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      widget.onToggleFavorite(hymn);
                                    },
                                  ),
                                  onTap: () {
                                    widget.onSelectHymn(hymn);
                                    Navigator.pop(context);
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),

          // TAB 2: FAVORITES
          widget.favoriteHymns.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Favorite Hymns Yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'When reading any hymn, tap the heart icon at the top to save it here for quick access.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.favoriteHymns.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final hymn = widget.favoriteHymns[index];
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
                        '${hymn.category ?? "Hymn"} • Page ${hymn.page}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        tooltip: 'Remove from favorites',
                        onPressed: () {
                          widget.onToggleFavorite(hymn);
                        },
                      ),
                      onTap: () {
                        widget.onSelectHymn(hymn);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
