import 'dart:convert';
import 'package:flutter/services.dart';

class ContentService {
  Future<Map<String, dynamic>> loadContent() async {
    final rawData = await rootBundle.loadString('assets/data/content.json');
    return json.decode(rawData);
  }
}