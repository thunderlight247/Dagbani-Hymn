import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymn/db/hymn_database.dart';

void main() {
  test('SQLite support matches the current Flutter runtime', () {
    expect(HymnDatabase.supportsSqlite, equals(!kIsWeb));
  });
}
