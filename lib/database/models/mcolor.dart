import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/base_model.dart';
import 'package:sqflite/sqflite.dart';

class MColor extends BaseModel {
  MColor({required super.json});

  static String tableName = "color_configurations";

  String get backgroundColor => json['backgroundColor'] ?? "#FF000000";

  String get fontColor => json['fontColor'] ?? "#FF000000";

  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName ("
      "id INTEGER PRIMARY KEY, "
      "name TEXT,"
      "fontColor TEXT,"
      "backgroundColor TEXT"
      ")",
    );
  }

  save() async {
    final db = await AppDatabase().database;
    await db.insert(
      tableName,
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<MColor>> getAll({String? query}) async {
    final db = await AppDatabase().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "name LIKE ?",
      whereArgs: ["%${query ?? ""}%"],
    );
    return List.generate(maps.length, (i) {
      return MColor(
        json: {
          "id": maps[i]['id'],
          "name": maps[i]['name'],
          "property_1": maps[i]['property_1'],
          "property_2": maps[i]['property_2'],
          "property_3": maps[i]['property_3'],
          "property_4": maps[i]['property_4'],
          "property_5": maps[i]['property_5'],
          "fontColor": maps[i]['fontColor'],
          "backgroundColor": maps[i]['backgroundColor'],
        },
      );
    });
  }

  delete() async {
    final db = await AppDatabase().database;
    await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}

class MColorConnection extends BaseModel {
  MColorConnection({required super.json});
  static String tableName = "color_connections";

  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName ("
      "id INTEGER PRIMARY KEY, "
      "colorId INTEGER,"
      "productId TEXT"
      ")",
    );
  }
}
