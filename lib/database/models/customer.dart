import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/base_model.dart';
import 'package:sqflite/sqflite.dart';

class MCustomer extends BaseModel {
  MCustomer({required super.json});

  static String tableName = 'customer';

  static Future<void> createTable(Database db) async {
    await db.execute(
      "CREATE TABLE IF NOT EXISTS $tableName("
      "_id TEXT PRIMARY KEY,"
      "_isactive TEXT,"
      "name TEXT"
      ")",
    );
  }

  static Future<List<MCustomer>> getAll() async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((e) => MCustomer(json: e)).toList();
  }
}
