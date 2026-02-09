import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HymnDatabase {
  static final HymnDatabase instance = HymnDatabase._init();
  static Database? _database;

  HymnDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dagbani_hymns.db');
    
    // NOTE: We don't increment the version here, expecting user to delete app data.
    _database = await openDatabase( 
      path,
      version: 1,
      onCreate: _createDB,
    );
    await _database!.execute('PRAGMA foreign_keys = ON');
    await _seedFromTOC(_database!);
    return _database!;
  }

  // CRITICAL FIX: ADDED isFavorite COLUMN
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hymns (
        id INTEGER PRIMARY KEY,
        number TEXT NOT NULL,
        title TEXT NOT NULL,
        page TEXT NOT NULL,
        content TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0  -- <--- NEW COLUMN
      )
    ''');
  }

  Future<void> _seedFromTOC(Database db) async {
    final tocData = await rootBundle.loadString('assets/hymn.json');
    final List<dynamic> tocList = json.decode(tocData);
    for (var entry in tocList) {
      // NOTE: We do NOT seed the isFavorite field here; it defaults to 0 (false).
      await db.insert('hymns', {
        'id': entry['id'] ?? 0,
        'number': entry['number'] ?? '',
        'title': entry['title'] ?? '',
        'page': entry['page'] ?? '',
        'content': entry['lyrics'] ?? '',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // ADDED: Updates the isFavorite status in the database
  Future<void> toggleFavoriteStatus(int hymnId, bool isFavorite) async {
    final db = await database;
    await db.update(
      'hymns',
      {'isFavorite': isFavorite ? 1 : 0}, // 1 for true, 0 for false
      where: 'id = ?',
      whereArgs: [hymnId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ADDED: Fetches all favorited hymns from the database (currently unused, but helpful)
  Future<List<Map<String, dynamic>>> getFavoriteHymnsData() async {
    final db = await database;
    return await db.query(
      'hymns',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'number ASC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getAllHymns() async {
    final db = await database;
    // Query now returns the isFavorite status too
    return await db.query('hymns'); 
  }

  Future close() async {
    final db = await database;
    _database = null;
    await db.close();
  }
}