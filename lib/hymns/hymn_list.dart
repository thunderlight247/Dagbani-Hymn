import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- ADDED PROVIDER
import '../models/hymn.dart';
import '../models/settings_model.dart'; // <--- ADDED SETTINGS MODEL

class HymnList extends StatelessWidget {
  final List<Hymn> hymns; 
  final Function(Hymn) onHymnTap; 

  const HymnList({
    super.key,
    required this.hymns,
    required this.onHymnTap,
  });

  @override
  Widget build(BuildContext context) {
    // ACCESS SETTINGS MODEL
    final settings = Provider.of<SettingsModel>(context);
    
    return ListView.builder(
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymns[index];
        return ListTile(
          title: Text(
            '${hymn.number} - ${hymn.title} (Page ${hymn.page})',
            // --- USE DYNAMIC GETTEXTSTYLE ---
            style: settings.getTextStyle(
              size: 16,
              weight: FontWeight.w500,
            ).copyWith(color: Colors.black87), // Added color for clarity
          ),
          onTap: () {
            onHymnTap(hymn); 
          },
        );
      },
    );
  }
}