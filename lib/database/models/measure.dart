import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/base_model.dart';
import 'package:sqflite/sqflite.dart';

class MMeasure extends BaseModel {
  MMeasure({required super.json});

  static String tableName = 'measure';

  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName("
      "_id TEXT PRIMARY KEY,"
      "_isactive TEXT,"
      "name TEXT"
      ")",
    );
  }

  static Future<List<MMeasure>> getAll() async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((e) => MMeasure(json: e)).toList();
  }
}
