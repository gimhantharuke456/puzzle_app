import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _dbName = 'crossword_clues.db';

  static Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, _dbName);
    return dbPath;
  }

  static Future<void> copyDatabase() async {
    String dbPath = await getDatabasePath();

    // Check if the database exists
    bool exists = await databaseExists(dbPath);

    if (!exists) {
      // Copy from asset
      ByteData data = await rootBundle.load(join('assets', _dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }
  }
}
