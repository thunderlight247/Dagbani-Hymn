import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system setting
  String _fontFamily = 'Merriweather'; // Default to our preferred font

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;

  // Available fonts for the user to select
  final List<String> availableFonts = [
    'Merriweather',
    'Playfair Display',
    'Roboto',
    'Open Sans',
    // You can add more Google Fonts here
  ];

  // --- ACTIONS ---

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setFontFamily(String newFont) {
    _fontFamily = newFont;
    notifyListeners();
  }

  // Helper to get the correct GoogleFont.TextStyle
  TextStyle getTextStyle({double? size, FontWeight? weight}) {
    // Dynamically returns the TextStyle for the selected font
    switch (_fontFamily) {
      case 'Playfair Display':
        return GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight);
      case 'Roboto':
        return GoogleFonts.roboto(fontSize: size, fontWeight: weight);
      case 'Open Sans':
        return GoogleFonts.openSans(fontSize: size, fontWeight: weight);
      case 'Merriweather':
      default:
        return GoogleFonts.merriweather(fontSize: size, fontWeight: weight);
    }
  }
}