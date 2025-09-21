import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/base_model.dart';
import 'package:sqflite/sqflite.dart';

class MCurrency extends BaseModel {
  MCurrency({required super.json});

  static String tableName = 'currency';

  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS currencyRate");
    await db.execute(
      "CREATE TABLE currencyRate("
      "currency_id TEXT PRIMARY KEY,"
      "rate REAL"
      ")",
    );

    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName("
      "_id TEXT PRIMARY KEY,"
      "_isactive TEXT,"
      "name TEXT"
      ")",
    );
  }

  static Future<List<MCurrency>> getAll() async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((e) => MCurrency(json: e)).toList();
  }

  static Future<List<MCurrency>> getAllWithRate() async {
    final db = await AppDatabase().database;
    final List<dynamic> maps = await db.rawQuery('''
    SELECT currency.*, COALESCE(currencyRate.rate, 1.0) as rate FROM currency LEFT JOIN currencyRate ON currency._id = currencyRate.currency_id
    ''');
    return maps.map((e) => MCurrency(json: e)).toList();
  }
}
