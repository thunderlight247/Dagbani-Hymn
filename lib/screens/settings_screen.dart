import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../screens/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section: Appearance / Theme
          _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (newSelection) {
                      if (newSelection.isNotEmpty) {
                        settings.setThemeMode(newSelection.first);
                      }
                    },
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      settings.keepScreenAwake
                          ? Icons.lightbulb_rounded
                          : Icons.lightbulb_outline_rounded,
                      color: settings.keepScreenAwake
                          ? theme.colorScheme.primary
                          : Colors.grey,
                    ),
                    title: const Text(
                      'Keep Screen Awake',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Prevents screen from turning off while reading hymns during church service',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: settings.keepScreenAwake,
                    onChanged: (val) => settings.setKeepScreenAwake(val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Hymn Typography
          _buildSectionHeader(context, 'Hymn Typography', Icons.text_fields_rounded),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size (${settings.fontSize.round()} sp)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.text_decrease),
                        tooltip: 'Decrease font size',
                        onPressed: settings.fontSize > 14
                            ? () => settings.setFontSize(settings.fontSize - 1)
                            : null,
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 14.0,
                          max: 28.0,
                          divisions: 14,
                          label: '${settings.fontSize.round()}',
                          onChanged: (val) => settings.setFontSize(val),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.text_increase),
                        tooltip: 'Increase font size',
                        onPressed: settings.fontSize < 28
                            ? () => settings.setFontSize(settings.fontSize + 1)
                            : null,
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Text(
                    'Font Family',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: settings.availableFonts.map((font) {
                      final isSelected = font == settings.fontFamily;
                      return ChoiceChip(
                        label: Text(
                          font,
                          style: settings.getTextStyle(
                            size: 14,
                            weight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            settings.setFontFamily(font);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Live Hymn Preview Card
          _buildSectionHeader(context, 'Live Hymn Preview', Icons.preview_rounded),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262C38) : Colors.blue.shade50.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PAƔMIYA NAAWUNI',
                      style: settings.getTextStyle(
                        size: settings.fontSize + 2,
                        weight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "1. Paɣmiya Naawuni\nYi nɔl' ni ni suhuni zaa,\nO tumdi alahiʒiba,\nDuniya daadam zaahani,\nTi dɔɣbu pilgu ni...",
                  style: settings.getTextStyle(
                    size: settings.fontSize,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: General
          _buildSectionHeader(context, 'About', Icons.info_outline_rounded),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.church_rounded),
              title: const Text('About PCG Dagbani Hymn'),
              subtitle: const Text('Northern Presbyterian Church'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
