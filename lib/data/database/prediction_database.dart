import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:marcadores_mundial_app/domain/entities/prediction.dart';

class PredictionDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'predictions.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            match_id TEXT NOT NULL UNIQUE,
            home_score INTEGER NOT NULL,
            away_score INTEGER NOT NULL,
            points INTEGER DEFAULT 0,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  // Predictions
  static Future<void> savePrediction(Prediction p) async {
    final db = await database;
    await db.insert(
      'predictions',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Prediction?> getPrediction(String matchId) async {
    final db = await database;
    final results = await db.query(
      'predictions',
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
    if (results.isEmpty) return null;
    return Prediction.fromMap(results.first);
  }

  static Future<List<Prediction>> getAllPredictions() async {
    final db = await database;
    final results = await db.query('predictions', orderBy: 'updated_at DESC');
    return results.map((m) => Prediction.fromMap(m)).toList();
  }

  static Future<int> getTotalPoints() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(points),0) as total FROM predictions');
    return result.first['total'] as int;
  }

  static Future<int> getPredictionCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM predictions');
    return result.first['cnt'] as int;
  }

  // Cache
  static Future<void> cacheData(String key, String value) async {
    final db = await database;
    await db.insert(
      'cache',
      {'key': key, 'value': value, 'updated_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getCachedData(String key) async {
    final db = await database;
    final results = await db.query('cache', where: 'key = ?', whereArgs: [key]);
    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  static Future<void> clearAllCaches() async {
    final db = await database;
    await db.delete('cache');
  }
}
