import 'package:flutter/material.dart';
import '/db/hymn_loader.dart';
import '../hymns/hymn_list.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/history_screen.dart';
import 'toc_screen.dart';
import '../models/hymn.dart';
import '../hymns/hymn_detail.dart';
import '../db/hymn_database.dart';
import '../widgets/profile_check_utility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Hymn> _allHymns = [];
  final List<Hymn> _filteredHymns = [];
  final List<Hymn> _searchHistory = [];

  List<Hymn> _favoriteHymns = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHymns();
  }

  Future<void> _loadHymns() async {
    final hymns = await HymnLoader.loadHymnsFromAssets();
    setState(() {
      _allHymns
        ..clear()
        ..addAll(hymns);

      _filteredHymns
        ..clear()
        ..addAll(hymns);

      _searchHistory.clear();
      _favoriteHymns = _allHymns.where((h) => h.isFavorite).toList();
    });
  }

  void _toggleFavorite(Hymn hymn) {
    setState(() {
      final index = _allHymns.indexWhere((h) => h.id == hymn.id);
      if (index != -1) {
        final updated = _allHymns[index].copyWith(isFavorite: !hymn.isFavorite);
        _allHymns[index] = updated;

        HymnDatabase.instance
            .toggleFavoriteStatus(updated.id, updated.isFavorite);

        if (updated.isFavorite) {
          _favoriteHymns.add(updated);
          _favoriteHymns.sort((a, b) => a.number.compareTo(b.number));
        } else {
          _favoriteHymns.removeWhere((h) => h.id == updated.id);
        }
      }
    });
  }

  void _handleDirectSearch(Hymn hymn) {
    _tabController.animateTo(1);

    final latest =
        _allHymns.firstWhere((h) => h.id == hymn.id, orElse: () => hymn);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HymnDetail(
          hymn: latest,
          onToggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }

  void _filterHymns(String query) {
    final lower = query.toLowerCase().trim();

    setState(() {
      _filteredHymns
        ..clear()
        ..addAll(_allHymns.where((h) {
          final number = h.number.toLowerCase();
          final title = h.title.toLowerCase();
          final page = h.page.toLowerCase();
          final translation = h.translation?.toLowerCase() ?? '';
          final category = h.category?.toLowerCase() ?? '';

          return number.contains(lower) ||
              title.contains(lower) ||
              page.contains(lower) ||
              translation.contains(lower) ||
              category.contains(lower);
        }));

      final commaMatch = RegExp(r'^\s*\d+\s*,\s*\d+\s*$');
      if (commaMatch.hasMatch(lower)) {
        final parts = lower.split(',').map((s) => s.trim()).toList();
        if (parts.length == 2) {
         
          final page = parts[0];
           final number = parts[1];

          final match = _allHymns.firstWhere(
            (h) => h.number == number && h.page == page,
            orElse: () => Hymn(id: 0, number: '', title: '', page: '', content: []),
          );

          if (match.id != 0) {
            _searchHistory.insert(0, match);
            _handleDirectSearch(match);
          }
        }
      }
    });
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by hymn number, title, page (e.g., 1, 1 or 1, 48)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filterHymns,
          ),
        ),
        Expanded(child: _buildHymnList(_filteredHymns)),
      ],
    );
  }

  Widget _buildHymnList(List<Hymn> hymns) {
    return HymnList(
      hymns: hymns,
      onHymnTap: (hymn) {
        _searchHistory.insert(0, hymn);

        final latest =
            _allHymns.firstWhere((h) => h.id == hymn.id, orElse: () => hymn);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HymnDetail(
              hymn: latest,
              onToggleFavorite: _toggleFavorite,
            ),
          ),
        ).then((_) => setState(() {}));
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dagbani Hymn Book'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Contents'),
            Tab(icon: Icon(Icons.book), text: 'Hymns'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Dagbani Hymn Book',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Uploads'),
              onTap: () async {
                Navigator.pop(context);

                final isComplete =
                    await ProfileCheckUtility.isProfileComplete();

                if (!context.mounted) return;

                if (isComplete) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UploadScreen()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Profile Required'),
                      content: const Text(
                        'Please complete your full name and congregation details in the Profile screen before uploading.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()),
                            );
                          },
                          child: const Text('Go to Profile'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text('Church History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoryScreen()),
                );
              },
            ),

            /*ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('AI/App Q&A'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AiQueryScreen()),
                );
              },
            ),*/

            /*ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Congregation Activity'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ActivityScreen()),
                );
              },
            ),*/

            /*ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Find Church'),
              onTap: () {
                Navigator.pop(context);
                // FIXED: Removed broken Navigator.push
                // Add your screen later:
                // Navigator.push(context, MaterialPageRoute(builder: (_) => FindChurchScreen()));
              },
            ),*/
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          TOCScreen(
            onDirectSearch: _handleDirectSearch,
            onToggleFavorite: _toggleFavorite,
          ),
          _buildSearchTab(),
          _buildHymnList(_favoriteHymns),
        ],
      ),
    );
  }
}
