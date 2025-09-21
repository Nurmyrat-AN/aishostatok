import 'package:aishostatok/database/base_model.dart';
import 'package:sqflite/sqflite.dart';

class MStock extends BaseModel {
  MStock({required super.json});

  static String tableName = 'stock';

  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName("
      "_id TEXT PRIMARY KEY,"
      "product_id TEXT,"
      "warehouse_id TEXT,"
      "stock_in_main_measure REAL"
      ")",
    );
  }
}
