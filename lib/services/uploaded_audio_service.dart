import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/uploaded_hymn_audio.dart';
import '../db/hymn_database.dart';

class UploadedAudioService extends ChangeNotifier {
  static final UploadedAudioService instance = UploadedAudioService._();
  UploadedAudioService._() {
    loadAudios();
  }

  static const String _prefKey = 'uploaded_hymn_audios_cache';
  final List<UploadedHymnAudio> _audios = [];

  List<UploadedHymnAudio> get audios => List.unmodifiable(_audios);

  Future<void> loadAudios() async {
    _audios.clear();

    // 1. Load from SQLite if supported
    if (HymnDatabase.supportsSqlite) {
      try {
        final db = await HymnDatabase.instance.database;
        await _ensureTableExists(db);
        final records = await db.query('uploaded_hymn_audios', orderBy: 'hymn_number ASC');
        for (var row in records) {
          _audios.add(UploadedHymnAudio.fromMap(row));
        }
      } catch (e) {
        debugPrint('Error reading uploaded audios from SQLite: $e');
      }
    }

    // 2. If SQLite is empty or unsupported (e.g. web/first launch), fallback to SharedPreferences
    if (_audios.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = prefs.getString(_prefKey);
        if (jsonStr != null) {
          final List<dynamic> decoded = jsonDecode(jsonStr);
          for (var item in decoded) {
            _audios.add(UploadedHymnAudio.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      } catch (e) {
        debugPrint('Error reading uploaded audios from SharedPreferences: $e');
      }
    }

    notifyListeners();
  }

  UploadedHymnAudio? getAudioForHymn(String hymnNumber) {
    try {
      final cleanNum = hymnNumber.trim();
      return _audios.firstWhere((a) => a.hymnNumber.trim() == cleanNum);
    } catch (_) {
      return null;
    }
  }

  Future<UploadedHymnAudio> saveAudio({
    required String hymnNumber,
    required String hymnTitle,
    required String sourceFilePath,
    required String originalFileName,
    required String audioType,
    String? uploaderName,
    String? notes,
  }) async {
    String destinationPath = sourceFilePath;
    int fileSize = 0;

    // On native mobile/desktop platforms, copy the file to the app documents directory
    if (!kIsWeb) {
      try {
        final sourceFile = File(sourceFilePath);
        fileSize = await sourceFile.length();

        final appDir = await getApplicationDocumentsDirectory();
        final hymnsAudioDir = Directory(p.join(appDir.path, 'hymn_audios'));
        if (!await hymnsAudioDir.exists()) {
          await hymnsAudioDir.create(recursive: true);
        }

        final fileExt = p.extension(sourceFilePath).isNotEmpty
            ? p.extension(sourceFilePath)
            : '.mp3';
        final uniqueFileName = 'hymn_${hymnNumber}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
        final destFile = File(p.join(hymnsAudioDir.path, uniqueFileName));

        await sourceFile.copy(destFile.path);
        destinationPath = destFile.path;
      } catch (e) {
        debugPrint('Error copying audio file locally: $e');
        destinationPath = sourceFilePath;
      }
    }

    final newAudio = UploadedHymnAudio(
      id: '${hymnNumber}_${DateTime.now().millisecondsSinceEpoch}',
      hymnNumber: hymnNumber.trim(),
      hymnTitle: hymnTitle.trim(),
      filePath: destinationPath,
      fileName: originalFileName,
      audioType: audioType,
      uploaderName: uploaderName,
      notes: notes,
      fileSizeBytes: fileSize,
      uploadedAt: DateTime.now(),
    );

    // Remove any previous recording for this hymn so it gets replaced
    _audios.removeWhere((a) => a.hymnNumber == newAudio.hymnNumber);
    _audios.insert(0, newAudio);
    _audios.sort((a, b) {
      final numA = int.tryParse(a.hymnNumber) ?? 9999;
      final numB = int.tryParse(b.hymnNumber) ?? 9999;
      return numA.compareTo(numB);
    });

    // Persist in SQLite
    if (HymnDatabase.supportsSqlite) {
      try {
        final db = await HymnDatabase.instance.database;
        await _ensureTableExists(db);
        await db.delete(
          'uploaded_hymn_audios',
          where: 'hymn_number = ?',
          whereArgs: [newAudio.hymnNumber],
        );
        await db.insert('uploaded_hymn_audios', newAudio.toMap());
      } catch (e) {
        debugPrint('Error inserting uploaded audio to SQLite: $e');
      }
    }

    // Persist in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _audios.map((a) => a.toMap()).toList();
      await prefs.setString(_prefKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving uploaded audios to SharedPreferences: $e');
    }

    notifyListeners();
    return newAudio;
  }

  Future<void> deleteAudio(String id) async {
    final index = _audios.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final target = _audios[index];

    // Remove file if exists
    if (!kIsWeb && target.filePath.isNotEmpty) {
      try {
        final file = File(target.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting local audio file: $e');
      }
    }

    _audios.removeAt(index);

    // Remove from SQLite
    if (HymnDatabase.supportsSqlite) {
      try {
        final db = await HymnDatabase.instance.database;
        await db.delete('uploaded_hymn_audios', where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint('Error deleting audio from SQLite: $e');
      }
    }

    // Update SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _audios.map((a) => a.toMap()).toList();
      await prefs.setString(_prefKey, jsonEncode(jsonList));
    } catch (_) {}

    notifyListeners();
  }

  Future<void> _ensureTableExists(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS uploaded_hymn_audios (
        id TEXT PRIMARY KEY,
        hymn_number TEXT NOT NULL,
        hymn_title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        audio_type TEXT NOT NULL,
        uploader_name TEXT,
        notes TEXT,
        file_size INTEGER,
        uploaded_at TEXT NOT NULL
      )
    ''');
  }
}
