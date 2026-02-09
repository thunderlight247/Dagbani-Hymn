import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../screens/about_screen.dart'; // <-- Make sure you create this file

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- FONT SELECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Select Hymn Font Family',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...settings.availableFonts.map((fontName) {
            final isSelected = fontName == settings.fontFamily;
            return RadioListTile<String>(
              title: Text(
                'AaBbCc - $fontName',
                style: settings.getTextStyle(size: 16),
              ),
              value: fontName,
              groupValue: settings.fontFamily,
              onChanged: (newValue) {
                if (newValue != null) {
                  settings.setFontFamily(newValue);
                }
              },
              secondary: isSelected ? const Icon(Icons.check_circle) : null,
              selected: isSelected,
              activeColor: Theme.of(context).primaryColor,
            );
          }),

          const Divider(),

          // --- ABOUT SECTION ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About this App'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
