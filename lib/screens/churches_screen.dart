import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/church.dart';
import '../services/church_service.dart';
import 'church_detail_screen.dart';
import 'church_form_screen.dart';

class ChurchesScreen extends StatefulWidget {
  const ChurchesScreen({super.key});

  @override
  State<ChurchesScreen> createState() => _ChurchesScreenState();
}

class _ChurchesScreenState extends State<ChurchesScreen> {
  final _service = ChurchService();
  List<Church> _churches = [];
  bool _loading = true;
  String? _userCongregation;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userCongregation = prefs.getString('user_congregation') ?? '';
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final churches = await _service.fetchChurches();
    if (mounted) {
      setState(() {
        _churches = churches;
        _loading = false;
      });
    }
  }

  void _openUpload() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChurchFormScreen(userCongregation: _userCongregation),
      ),
    );
    if (added == true) _reload();
  }

  void _openEdit(Church church) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChurchFormScreen(
          userCongregation: _userCongregation,
          existing: church,
        ),
      ),
    );
    if (updated == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PCG Churches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _churches.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _churches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ChurchCard(
                      church: _churches[i],
                      canEdit: _churches[i].canEdit(_userCongregation),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChurchDetailScreen(church: _churches[i]),
                        ),
                      ),
                      onEdit: () => _openEdit(_churches[i]),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUpload,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Church'),
        tooltip: 'Upload your church details',
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.church_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No Churches Yet',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Be the first to add your congregation.\nTap the button below or use the + button.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _openUpload,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Upload Your Church Details'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Church list card ───────────────────────────────────────────────────────

class _ChurchCard extends StatelessWidget {
  final Church church;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ChurchCard({
    required this.church,
    required this.canEdit,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.church_rounded,
                    color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${church.townCity} · ${church.presbytery}',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (church.minister.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        church.minister,
                        style: TextStyle(
                            color: theme.colorScheme.primary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
