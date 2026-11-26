import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/church.dart';

class ChurchService {
  static const _cacheKey = 'cached_pcg_churches_v3';
  static const _workerUrl =
      'https://dagbani-hymn.pcg-dagbani-hymn.workers.dev/churches';

  // ── Fetch ──────────────────────────────────────────────────────────────────

  /// Returns churches from the Cloudflare worker, falling back to local cache.
  /// Always starts completely clean — no seed data ever pre-loaded.
  Future<List<Church>> fetchChurches() async {
    try {
      final response =
          await http.get(Uri.parse(_workerUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['churches'] as List? ?? [])
            .map((e) => Church.fromMap(e as Map<String, dynamic>))
            .toList();
        await _saveToCache(list);
        return list;
      }
    } catch (_) {
      // Network unavailable — use cache
    }
    return _loadFromCache();
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<bool> uploadChurch(Church church) async {
    try {
      final response = await http
          .post(
            Uri.parse(_workerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(church.toMap()),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<bool> updateChurch(Church church) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_workerUrl/${church.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(church.toMap()),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Cache helpers ──────────────────────────────────────────────────────────

  Future<void> _saveToCache(List<Church> churches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(churches.map((c) => c.toMap()).toList());
      await prefs.setString(_cacheKey, encoded);
    } catch (_) {}
  }

  Future<List<Church>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Church.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
