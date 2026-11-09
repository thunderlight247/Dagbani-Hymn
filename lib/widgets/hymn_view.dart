import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/hymn.dart';
import '../models/settings_model.dart';
import '../services/uploaded_audio_service.dart';
import 'uploaded_hymn_audio_player.dart';

class HymnView extends StatelessWidget {
  final Hymn hymn;

  const HymnView({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isChorus = hymn.category?.toLowerCase().contains('chorus') ?? false;

    return Stack(
      children: [
        // Watermark PCG emblem behind the hymn text
        Positioned.fill(
          child: Center(
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.07,
                child: Image.asset(
                  'assets/images/cover.png',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),

        // Foreground Scrollable Hymn Content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Metadata Pills
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isChorus
                          ? theme.colorScheme.secondary.withValues(alpha: 0.12)
                          : theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isChorus ? 'DAGBANI CHORUS' : 'HYMN ${hymn.number}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isChorus
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (hymn.page.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Page ${hymn.page}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  if (hymn.reference != null && hymn.reference!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hymn.reference!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                hymn.title,
                textAlign: TextAlign.center,
                style: settings.getTextStyle(
                  size: settings.fontSize + 4,
                  weight: FontWeight.bold,
                  height: 1.25,
                ),
              ),

              // Optional Translation Subtitle
              if (hymn.translation != null && hymn.translation!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  hymn.translation!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: (settings.fontSize - 3).clamp(13.0, 20.0),
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],

              // Uploaded Audio Player (Appears ONLY if an audio recording exists for this hymn)
              AnimatedBuilder(
                animation: UploadedAudioService.instance,
                builder: (context, _) {
                  final uploadedAudio =
                      UploadedAudioService.instance.getAudioForHymn(hymn.number);
                  if (uploadedAudio == null) return const SizedBox.shrink();
                  return UploadedHymnAudioPlayer(
                    key: ValueKey(uploadedAudio.id),
                    audio: uploadedAudio,
                  );
                },
              ),

              const SizedBox(height: 16),
              Divider(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                thickness: 1,
              ),
              const SizedBox(height: 12),

              // Stanzas
              ...hymn.content.asMap().entries.map((entry) {
                final index = entry.key;
                final rawStanza = entry.value.trim();

                // Detect and clean leading numbering (e.g. "1. " or "1) ")
                final numberRegex = RegExp(r'^\s*(\d+)[\.\)]\s*(.*)$', dotAll: true);
                final match = numberRegex.firstMatch(rawStanza);

                final String verseLabel = match != null ? match.group(1)! : '${index + 1}';
                final String stanzaText = match != null ? match.group(2)!.trim() : rawStanza;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse Number Badge
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          verseLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Stanza Lyrics
                      Expanded(
                        child: Text(
                          stanzaText,
                          style: settings.getTextStyle(
                            size: settings.fontSize,
                            height: 1.55,
                          ),
                        ),
                      ),

                      // Quick Copy Button for this Stanza
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        color: Colors.grey,
                        tooltip: 'Copy Stanza $verseLabel',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: 'Hymn ${hymn.number} (${hymn.title})\nStanza $verseLabel:\n\n$stanzaText\n\n— PCG Dagbani Hymn',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Stanza $verseLabel copied to clipboard!'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
