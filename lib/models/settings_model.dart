import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsModel extends ChangeNotifier {
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyFontFamily = 'settings_font_family';
  static const String _keyFontSize = 'settings_font_size';
  static const String _keyKeepScreenAwake = 'settings_keep_screen_awake';

  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Merriweather';
  double _fontSize = 18.0;
  bool _keepScreenAwake = false;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get keepScreenAwake => _keepScreenAwake;

  final List<String> availableFonts = [
    'Merriweather',
    'Playfair Display',
    'Roboto',
    'Open Sans',
    'Lora',
    'Lato',
  ];

  SettingsModel() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeStr = prefs.getString(_keyThemeMode);
      if (themeStr != null) {
        if (themeStr == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (themeStr == 'light') {
          _themeMode = ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
      }

      final fontStr = prefs.getString(_keyFontFamily);
      if (fontStr != null && availableFonts.contains(fontStr)) {
        _fontFamily = fontStr;
      }

      final sizeVal = prefs.getDouble(_keyFontSize);
      if (sizeVal != null && sizeVal >= 12.0 && sizeVal <= 32.0) {
        _fontSize = sizeVal;
      }

      _keepScreenAwake = prefs.getBool(_keyKeepScreenAwake) ?? false;
      if (_keepScreenAwake) {
        try {
          await WakelockPlus.enable();
        } catch (_) {}
      }

      notifyListeners();
    } catch (_) {
      // SharedPreferences / Wakelock might fail in test environments; safe fallback
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'system';
      if (mode == ThemeMode.light) val = 'light';
      if (mode == ThemeMode.dark) val = 'dark';
      await prefs.setString(_keyThemeMode, val);
    } catch (_) {}
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setFontFamily(String newFont) async {
    if (_fontFamily == newFont) return;
    _fontFamily = newFont;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFontFamily, newFont);
    } catch (_) {}
  }

  Future<void> setFontSize(double newSize) async {
    final clamped = newSize.clamp(14.0, 28.0);
    if (_fontSize == clamped) return;
    _fontSize = clamped;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, clamped);
    } catch (_) {}
  }

  Future<void> setKeepScreenAwake(bool awake) async {
    _keepScreenAwake = awake;
    notifyListeners();
    try {
      if (awake) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyKeepScreenAwake, awake);
    } catch (_) {}
  }

  TextStyle getTextStyle({double? size, FontWeight? weight, Color? color, double? height}) {
    final effectiveSize = size ?? _fontSize;
    TextStyle style;
    switch (_fontFamily) {
      case 'Playfair Display':
        style = GoogleFonts.playfairDisplay(fontSize: effectiveSize, fontWeight: weight);
        break;
      case 'Roboto':
        style = GoogleFonts.roboto(fontSize: effectiveSize, fontWeight: weight);
        break;
      case 'Open Sans':
        style = GoogleFonts.openSans(fontSize: effectiveSize, fontWeight: weight);
        break;
      case 'Lora':
        style = GoogleFonts.lora(fontSize: effectiveSize, fontWeight: weight);
        break;
      case 'Lato':
        style = GoogleFonts.lato(fontSize: effectiveSize, fontWeight: weight);
        break;
      case 'Merriweather':
      default:
        style = GoogleFonts.merriweather(fontSize: effectiveSize, fontWeight: weight);
        break;
    }

    return style.copyWith(color: color, height: height);
  }
}
