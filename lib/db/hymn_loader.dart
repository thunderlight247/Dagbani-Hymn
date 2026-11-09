import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/hymn.dart';
import '../db/hymn_database.dart'; // <--- ADDED IMPORT

class HymnLoader {
  static Future<List<Hymn>> loadHymnsFromAssets() async {
    try {
      // 1. Load data from assets (JSON files)
      final hymnsData = await rootBundle.loadString('assets/hymn.json');
      final chorusesData = await rootBundle.loadString('assets/choruses.json');

      final hymnsList = json.decode(hymnsData) as List<dynamic>;
      final chorusesList = json.decode(chorusesData) as List<dynamic>;

      final combinedList = [...hymnsList, ...chorusesList];

      // Convert JSON to Hymn objects (using the default isFavorite=false)
      final List<Hymn> hymnsFromAssets = combinedList.map((json) => Hymn.fromMap(json)).toList();

      if (!HymnDatabase.supportsSqlite) {
        return hymnsFromAssets;
      }

      // 2. Load persisted favorite data from the database
      final db = HymnDatabase.instance;
      // We assume your database contains *all* hymns, but we check which are favorited
      final allDbHymnMaps = await db.getAllHymns();
      final Map<int, bool> favoriteStatusMap = {
        for (var map in allDbHymnMaps) map['id'] as int: (map['isFavorite'] as int) == 1
      };

      // 3. Combine: Apply persisted favorite status to the asset data
      return hymnsFromAssets.map((hymn) {
        final isFavorite = favoriteStatusMap[hymn.id] ?? false;
        if (isFavorite) {
          // Return a copy of the hymn with isFavorite set to true
          return hymn.copyWith(isFavorite: true);
        }
        return hymn;
      }).toList();
    } catch (e) {
      debugPrint('Error loading hymns: $e');
      return [];
    }
  }
}