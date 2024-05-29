import 'dart:async';
import 'package:path/path.dart';
import 'package:puzzle_app/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/crossword.dart';

class CrossWordDbService {
  static final CrossWordDbService _instance = CrossWordDbService._internal();
  factory CrossWordDbService() => _instance;

  static Database? _database;

  CrossWordDbService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    await DatabaseHelper.copyDatabase();
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await DatabaseHelper.getDatabasePath();
    return await openDatabase(path);
  }

  Future<List<CrossWord>> searchWords(
      String pattern, int maxLength, String excludedLetters) async {
    final db = await database;
    final List<String> conditions = [
      "word LIKE '$pattern'",
    ];

    final String whereClause = conditions.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'crossword_clues',
      where: whereClause,
    );
    print(whereClause);
    return List.generate(maps.length, (i) {
      return CrossWord(
        id: i,
        word: maps[i]['Word'],
        clue: maps[i]['Clue'],
        date: maps[i]['Date'],
      );
    });
  }
}
