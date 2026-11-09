import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hymn.dart';

class HymnShareSheet extends StatelessWidget {
  final Hymn hymn;

  const HymnShareSheet({super.key, required this.hymn});

  String _formatFullHymn() {
    final buffer = StringBuffer();
    buffer.writeln('PCG Dagbani Hymn ${hymn.number}: ${hymn.title}');
    if (hymn.page.isNotEmpty) {
      buffer.writeln('Page: ${hymn.page}');
    }
    if (hymn.translation != null && hymn.translation!.trim().isNotEmpty) {
      buffer.writeln('Tune / Translation: ${hymn.translation}');
    }
    buffer.writeln();

    for (int i = 0; i < hymn.content.length; i++) {
      final stanza = hymn.content[i].trim();
      buffer.writeln(stanza);
      buffer.writeln();
    }

    buffer.writeln('— Presbyterian Church of Ghana (PCG) Dagbani Hymn Book');
    return buffer.toString().trim();
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('$label copied to clipboard!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareViaSystem(BuildContext context, String text) async {
    Navigator.pop(context);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Hymn ${hymn.number}: ${hymn.title}',
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullText = _formatFullHymn();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Hymn ${hymn.number}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hymn.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 1. Copy Full Hymn Tile
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: Icon(Icons.copy_all_rounded, color: theme.colorScheme.primary),
              title: const Text('Copy Entire Hymn Lyrics', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Copies all verses with title and references'),
              onTap: () => _copyToClipboard(context, fullText, 'Entire hymn'),
            ),
          ),

          const SizedBox(height: 8),

          // 2. Share via WhatsApp / Messages / Apps
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.send_rounded, color: Colors.green),
              title: const Text('Share via WhatsApp / SMS / Apps', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Send hymn text to church members or social groups'),
              onTap: () => _shareViaSystem(context, fullText),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),

          // 3. Stanza-by-Stanza Quick Copy
          Text(
            'Copy Individual Stanzas',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hymn.content.asMap().entries.map((entry) {
                final verseIndex = entry.key + 1;
                final stanzaText = entry.value.trim();

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.content_copy, size: 16),
                    label: Text('Stanza $verseIndex'),
                    onPressed: () => _copyToClipboard(
                      context,
                      'Hymn ${hymn.number} (${hymn.title})\nStanza $verseIndex:\n\n$stanzaText\n\n— PCG Dagbani Hymn',
                      'Stanza $verseIndex',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
