import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/church.dart';

class ChurchDetailScreen extends StatelessWidget {
  final Church church;
  const ChurchDetailScreen({super.key, required this.church});

  Future<void> _openMaps(BuildContext context) async {
    final url = church.googleMapsUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location link available.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  Future<void> _callPhone(BuildContext context) async {
    final phone = church.contactPhone.replaceAll(RegExp(r'\s'), '');
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not dial number.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(church.name, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header card ──────────────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.church_rounded, color: primary, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              church.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${church.townCity} · ${church.presbytery}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Location ─────────────────────────────────────────────────────
          _SectionCard(
            icon: Icons.location_on_rounded,
            title: 'Location',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (church.locationDescription.isNotEmpty)
                  Text(church.locationDescription),
                const SizedBox(height: 10),
                if (church.googleMapsUrl.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () => _openMaps(context),
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: const Text('Open in Google Maps'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Contact ───────────────────────────────────────────────────────
          _SectionCard(
            icon: Icons.person_rounded,
            title: 'Contact',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (church.minister.isNotEmpty)
                  _InfoRow(label: 'Minister/Contact', value: church.minister),
                const SizedBox(height: 6),
                if (church.contactPhone.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                            label: 'Phone', value: church.contactPhone),
                      ),
                      TextButton.icon(
                        onPressed: () => _callPhone(context),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Call'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Weekly Activities ─────────────────────────────────────────────
          if (church.activities.trim().isNotEmpty) ...[
            _SectionCard(
              icon: Icons.calendar_month_rounded,
              title: 'Weekly Activities',
              child: Column(
                children: church.parsedActivities.map((a) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a['day']!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              a['day']!,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: Text(a['detail']!)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
