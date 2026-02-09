import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart'; 
// import 'package:firebase_core/firebase_core.dart'; // COMMENTED OUT
// import 'firebase_options.dart'; // COMMENTED OUT
import './splash/splash_screen.dart';
import './models/settings_model.dart';

final logger = Logger();

void main() { // <--- CHANGED BACK TO SYNCHRONOUS
  WidgetsFlutterBinding.ensureInitialized();

  // REMOVED FIREBASE INITIALIZATION BLOCK
  
  // Initialize sqflite_ffi for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    logger.i('Initializing sqflite_ffi for desktop...');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; 
    logger.i('sqflite_ffi initialized. databaseFactory: $databaseFactory');
  } else {
    logger.i('Using default sqflite for mobile. databaseFactory: $databaseFactory');
  }

  // WRAP APP IN PROVIDER
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsModel(),
      child: const HymnBookApp(),
    ),
  );
}

class HymnBookApp extends StatelessWidget {
  const HymnBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    // READ THE SETTINGS STATE
    final settings = Provider.of<SettingsModel>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dagbani Hymn Book',
      
      // APPLY THEME MODE: Locked to Light
      themeMode: ThemeMode.light, 
      
      theme: ThemeData( // Light Theme Setup
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0, 
          surfaceTintColor: Colors.transparent,
        ),
        // Ensure card colors are explicitly white for contrast
        cardColor: Colors.white, 
        scaffoldBackgroundColor: Colors.white,
        
        // This is necessary for light mode color consistency:
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.teal,
        ),
      ),
      
      home: const SplashScreen(),
    );
  }
}