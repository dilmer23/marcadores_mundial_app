import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:marcadores_mundial_app/domain/entities/prediction.dart';

class PredictionDatabase {
  static Database? _db;
  static final _predictions = intMapStoreFactory.store('predictions');
  static final _cache = intMapStoreFactory.store('cache');

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'predictions.db');
    return databaseFactoryIo.openDatabase(path);
  }

  static Future<void> savePrediction(Prediction p) async {
    final db = await database;
    final updated = await _predictions.update(
      db,
      p.toMap(),
      finder: Finder(filter: Filter.equals('match_id', p.matchId)),
    );
    if (updated == 0) {
      await _predictions.add(db, p.toMap());
    }
  }

  static Future<Prediction?> getPrediction(String matchId) async {
    final db = await database;
    final records = await _predictions.find(
      db,
      finder: Finder(filter: Filter.equals('match_id', matchId)),
    );
    if (records.isEmpty) return null;
    return Prediction.fromMap(records.first.value.cast<String, dynamic>());
  }

  static Future<List<Prediction>> getAllPredictions() async {
    final db = await database;
    final records = await _predictions.find(db);
    return records
        .map((r) => Prediction.fromMap(r.value.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => (b.updatedAt ?? '').compareTo(a.updatedAt ?? ''));
  }

  static Future<int> getTotalPoints() async {
    final db = await database;
    final records = await _predictions.find(db);
    var total = 0;
    for (final r in records) {
      total += r.value['points'] as int? ?? 0;
    }
    return total;
  }

  static Future<int> getPredictionCount() async {
    final db = await database;
    final records = await _predictions.find(db);
    return records.length;
  }

  static Future<void> cacheData(String key, String value) async {
    final db = await database;
    final data = <String, Object?>{
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    };
    final updated = await _cache.update(
      db,
      data,
      finder: Finder(filter: Filter.equals('key', key)),
    );
    if (updated == 0) {
      await _cache.add(db, data);
    }
  }

  static Future<String?> getCachedData(String key) async {
    final db = await database;
    final records = await _cache.find(
      db,
      finder: Finder(filter: Filter.equals('key', key)),
    );
    if (records.isEmpty) return null;
    return records.first.value['value'] as String?;
  }

  static Future<void> clearAllCaches() async {
    await _cache.delete(await database);
  }
}
