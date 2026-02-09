import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- ADDED PROVIDER
import '../models/hymn.dart';
import '../models/settings_model.dart'; // <--- ADDED SETTINGS MODEL

class TOCSection extends StatelessWidget {
  final String title;
  final List<Hymn> hymns;
  final Function(Hymn) onTap;

  const TOCSection({
    super.key,
    required this.title,
    required this.hymns,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ACCESS SETTINGS MODEL
    final settings = Provider.of<SettingsModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title (Uses Theme)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        
        // Hymn List
        ...hymns.map((hymn) => ListTile(
              leading: Icon(
                hymn.category == 'Dagbani Choruses' ? Icons.music_note : Icons.book,
                color: Theme.of(context).colorScheme.secondary,
              ),
              // --- USE DYNAMIC GETTEXTSTYLE FOR TITLE ---
              title: Text(
                hymn.title,
                style: settings.getTextStyle(
                  size: 16,
                  weight: FontWeight.w500,
                ).copyWith(color: Colors.black87),
              ),
              // Subtitle
              subtitle: hymn.translation != null
                  ? Text(
                      '${hymn.translation} (${hymn.category ?? 'Hymns'})',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Text(hymn.category ?? 'Hymns'),
              
              // --- USE DYNAMIC GETTEXTSTYLE FOR TRAILING NUMBER ---
              trailing: Text(
                hymn.number,
                style: settings.getTextStyle(
                  size: 16,
                  weight: FontWeight.bold,
                ).copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () => onTap(hymn),
            )),
      ],
    );
  }
}