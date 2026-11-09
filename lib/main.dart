import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import './splash/splash_screen.dart';
import './models/settings_model.dart';

final logger = Logger();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_ffi only for native desktop platforms.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    logger.i('Initializing sqflite_ffi for desktop...');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    logger.i('sqflite_ffi initialized. databaseFactory: $databaseFactory');
  } else {
    logger.i(
      'Using default sqflite for non-desktop or web runtime. databaseFactory: $databaseFactory',
    );
  }

  runApp(const HymnBookApp());
}

class HymnBookApp extends StatelessWidget {
  final SettingsModel? settingsModel;

  const HymnBookApp({super.key, this.settingsModel});

  static const Color pcgBlue = Color(0xFF1565C0);
  static const Color pcgDarkBlue = Color(0xFF0D47A1);
  static const Color pcgTeal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsModel>(
      create: (_) => settingsModel ?? SettingsModel(),
      child: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PCG Dagbani Hymn',
            themeMode: settings.themeMode,

            // Modern Light Theme with Presbyterian Church of Ghana colors
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: pcgBlue,
                primary: pcgBlue,
                secondary: pcgTeal,
                brightness: Brightness.light,
                surface: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: pcgBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              drawerTheme: const DrawerThemeData(
                backgroundColor: Colors.white,
              ),
              dividerColor: const Color(0xFFEEEEEE),
            ),

            // Modern Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: pcgBlue,
                primary: const Color(0xFF64B5F6),
                secondary: const Color(0xFF4DB6AC),
                brightness: Brightness.dark,
                surface: const Color(0xFF1E222B),
              ),
              scaffoldBackgroundColor: const Color(0xFF121418),
              cardColor: const Color(0xFF1E222B),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A1F29),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              drawerTheme: const DrawerThemeData(
                backgroundColor: Color(0xFF1A1F29),
              ),
              dividerColor: const Color(0xFF2C323F),
            ),

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
