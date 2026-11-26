import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/hymn_loader.dart';
import '../db/hymn_database.dart';
import '../models/hymn.dart';
import '../models/settings_model.dart';
import '../widgets/hymn_view.dart';
import '../widgets/hymn_search_delegate.dart';
import '../widgets/tune_player_sheet.dart';
import '../widgets/hymn_share_sheet.dart';
import '../screens/hymn_library_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/history_screen.dart';
import '../screens/about_screen.dart';
import '../screens/churches_screen.dart';
import '../widgets/profile_check_utility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Hymn> _allHymns = [];
  List<Hymn> _favoriteHymns = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadHymns();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadHymns() async {
    setState(() => _isLoading = true);
    final hymns = await HymnLoader.loadHymnsFromAssets();
    if (mounted) {
      setState(() {
        _allHymns
          ..clear()
          ..addAll(hymns);

        _favoriteHymns = _allHymns.where((h) => h.isFavorite).toList();
        _currentIndex = 0; // Directly opens to the first hymn
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(Hymn hymn) {
    setState(() {
      final index = _allHymns.indexWhere((h) => h.id == hymn.id);
      if (index != -1) {
        final updated = _allHymns[index].copyWith(isFavorite: !hymn.isFavorite);
        _allHymns[index] = updated;

        HymnDatabase.instance.toggleFavoriteStatus(
          updated.id,
          updated.isFavorite,
        );

        if (updated.isFavorite) {
          _favoriteHymns.add(updated);
          _favoriteHymns.sort((a, b) => a.number.compareTo(b.number));
        } else {
          _favoriteHymns.removeWhere((h) => h.id == updated.id);
        }
      }
    });
  }

  void _goToHymn(Hymn hymn) {
    final index = _allHymns.indexWhere((h) => h.id == hymn.id);
    if (index != -1) {
      setState(() {
        _currentIndex = index;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
    }
  }

  void _openSearch() async {
    final selected = await showSearch<Hymn?>(
      context: context,
      delegate: HymnSearchDelegate(hymns: _allHymns),
    );

    if (selected != null && mounted) {
      _goToHymn(selected);
    }
  }

  void _openLibrary({required int initialIndex}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HymnLibraryScreen(
          initialIndex: initialIndex,
          hymns: _allHymns,
          favoriteHymns: _favoriteHymns,
          onToggleFavorite: _toggleFavorite,
          onSelectHymn: _goToHymn,
        ),
      ),
    );
  }

  void _openTunePlayer(Hymn hymn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TunePlayerSheet(hymn: hymn),
    );
  }

  void _openShareSheet(Hymn hymn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HymnShareSheet(hymn: hymn),
    );
  }

  void _showQuickJumpDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.directions_run_rounded),
              SizedBox(width: 8),
              Text('Jump to Hymn'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter hymn number (e.g. 1 or 50):',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Hymn #',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (val) {
                  _handleJump(val, ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _handleJump(controller.text, ctx),
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  void _handleJump(String input, BuildContext dialogContext) {
    final query = input.trim();
    if (query.isEmpty) return;

    final target = _allHymns.firstWhere(
      (h) => h.number == query,
      orElse: () => Hymn(id: 0, number: '', title: '', page: '', content: []),
    );

    if (target.id != 0) {
      Navigator.pop(dialogContext);
      _goToHymn(target);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hymn #$query was not found.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQuickFontSizeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<SettingsModel>(
          builder: (context, settings, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Text Size',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${settings.fontSize.round()} sp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 14.0,
                          max: 28.0,
                          divisions: 14,
                          onChanged: (val) => settings.setFontSize(val),
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/cover.png', width: 90, height: 90),
              const SizedBox(height: 20),
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              const Text(
                'Loading Dagbani Hymns...',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final currentHymn = _allHymns.isNotEmpty ? _allHymns[_currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              currentHymn != null ? 'Hymn ${currentHymn.number}' : 'PCG Dagbani Hymn',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (currentHymn != null && currentHymn.page.isNotEmpty)
              Text(
                'Page ${currentHymn.page}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          // Audio / Tune Melody Accompaniment
          if (currentHymn != null)
            IconButton(
              icon: const Icon(Icons.music_note_rounded),
              tooltip: 'Tune & melody accompaniment',
              onPressed: () => _openTunePlayer(currentHymn),
            ),
          // Share & Copy Hymn
          if (currentHymn != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share & copy lyrics',
              onPressed: () => _openShareSheet(currentHymn),
            ),
          // Quick Font Size Shortcut
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'Adjust font size',
            onPressed: _showQuickFontSizeSheet,
          ),
          // Search Button (Prominent at top)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search hymn (title, number, page e.g. 1, 1)',
            onPressed: _openSearch,
          ),
          // Favorite Toggle for Current Hymn
          if (currentHymn != null)
            IconButton(
              icon: Icon(
                currentHymn.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: currentHymn.isFavorite ? Colors.redAccent : Colors.white,
              ),
              tooltip: currentHymn.isFavorite ? 'Remove from favorites' : 'Add to favorites',
              onPressed: () => _toggleFavorite(currentHymn),
            ),
        ],
      ),

      // DRAWER MENU: Hosts Content, Favorites, Settings, etc.
      drawer: Drawer(
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F29) : theme.colorScheme.primary,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/cover.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'PCG Dagbani Hymn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Presbyterian Church of Ghana',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 1. Current Hymn (Home)
                  ListTile(
                    leading: Icon(
                      Icons.menu_book_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Current Hymn', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () => Navigator.pop(context),
                  ),

                  // 2. Table of Contents
                  ListTile(
                    leading: const Icon(Icons.format_list_bulleted_rounded),
                    title: const Text('Table of Contents'),
                    onTap: () {
                      Navigator.pop(context);
                      _openLibrary(initialIndex: 0);
                    },
                  ),

                  // 3. Favorites (with count badge)
                  ListTile(
                    leading: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                    title: const Text('Favorites'),
                    trailing: _favoriteHymns.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_favoriteHymns.length}',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _openLibrary(initialIndex: 1);
                    },
                  ),

                  const Divider(),

                  // 4. Church History
                  ListTile(
                    leading: const Icon(Icons.church_rounded),
                    title: const Text('Church History'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),


                  // 4b. Churches Directory
                  ListTile(
                    leading: const Icon(Icons.location_city_rounded),
                    title: const Text('Churches', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChurchesScreen()),
                      );
                    },
                  ),

                  // 5. Settings
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),

                  // 6. User Profile
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),

                  // 7. Uploads
                  ListTile(
                    leading: const Icon(Icons.upload_file_rounded),
                    title: const Text('Uploads'),
                    onTap: () async {
                      Navigator.pop(context);
                      final isComplete = await ProfileCheckUtility.isProfileComplete();
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Profile Required'),
                            content: const Text(
                              'Please complete your full name and congregation details in the Profile screen before uploading.',
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
                                      builder: (_) => const ProfileScreen(redirectToUpload: true),
                                    ),
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

                  const Divider(),

                  // 8. About App
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About App'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // BODY: Direct Hymn Viewer with swipe navigation
      body: currentHymn == null
          ? const Center(child: Text('No hymns available.'))
          : PageView.builder(
              controller: _pageController,
              itemCount: _allHymns.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return HymnView(hymn: _allHymns[index]);
              },
            ),

      // BOTTOM NAVIGATION BAR: Prev / Next / Direct Jump Pill
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev Button
              FilledButton.tonalIcon(
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Prev'),
              ),

              // Center Jump Pill
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _showQuickJumpDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tag,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentHymn != null
                            ? '${_currentIndex + 1} / ${_allHymns.length}'
                            : '0 / 0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Next Button
              FilledButton.tonalIcon(
                onPressed: _currentIndex < _allHymns.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Text('Next'),
                label: const Icon(Icons.chevron_right, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
