import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/base_model.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/database/models/transaction.dart';
import 'package:aishostatok/utils/query.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class MProduct extends BaseModel {
  MProduct({required super.json});

  static String tableName = 'product';

  static List<Map<String, String>> orderByOptions = [
    {"value": 'name ASC', "label": 'Ady (A-Z)'},
    {"value": 'name DESC', "label": 'Ady (Z-A)'},
    {"value": "price_base_for_sale", "label": "Satyş baha (azdan köpe)"},
    {"value": "price_base_for_sale DESC", "label": "Satyş baha (köpden aza)"},
    {"value": "price_base_for_buying ASC", "label": "Alyş baha (azdan köpe)"},
    {"value": "price_base_for_buying DESC", "label": "Alyş baha (köpden aza)"},
    {
      "value": "price_minimum_for_sale ASC",
      "label": "Minimum baha (azdan köpe)",
    },
    {
      "value": "price_minimum_for_sale DESC",
      "label": "Minimum baha (köpden aza)",
    },
    {
      "value": "instock_mainmeasure ASC",
      "label": "Minimum galyndy (azdan köpe)",
    },
    {
      "value": "instock_mainmeasure DESC",
      "label": "Minimum galyndy (köpden aza)",
    },
    {"value": "stock_in_main_measure ASC", "label": "Galyndy (azdan köpe)"},
    {"value": "stock_in_main_measure DESC", "label": "Galyndy (köpden aza)"},
  ];

  String get name => json['name'] ?? "";

  double get percentForSale =>
      (json['price_base_for_sale'] / json['price_base_for_buying'] - 1) * 100;

  double get percentForMinimumSale =>
      (json['price_minimum_for_sale'] / json['price_base_for_buying'] - 1) *
      100;

  MTransaction? get transaction =>
      json.containsKey('transaction') ? json['transaction'] : null;

  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS lstBarcodes");
    await db.execute(
      "CREATE TABLE lstBarcodes("
      "product_id TEXT,"
      "barcode TEXT"
      ")",
    );
    db.execute(
      "CREATE INDEX idx_product_barcode ON lstBarcodes (product_id, barcode);",
    );
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName("
      "_id TEXT PRIMARY KEY,"
      "_isactive TEXT,"
      "code TEXT,"
      "name TEXT,"
      "price_base_for_buying REAL,"
      "price_base_for_sale REAL,"
      "price_minimum_for_sale REAL,"
      "currency TEXT,"
      "measure TEXT,"
      "instock_mainmeasure REAL,"
      "stock_in_main_measure REAL DEFAULT 0,"
      "property_1 TEXT,"
      "property_2 TEXT,"
      "property_3 TEXT,"
      "property_4 TEXT,"
      "property_5 TEXT,"
      "row_number_for_custom_sort REAL"
      ")",
    );
  }

  static Future<List<MProduct>> getAll({
    String? query = '',
    String? warehouseId,
    String? measureId,
    String? currencyId,
    String? orderBy = 'name',
    String? property_1,
    String? property_2,
    String? property_3,
    String? property_4,
    String? property_5,
    String? stock,
    String? minStock,
    String? barcode,
    List<String>? ids,
    int? colorId,
    bool? noColor = false,
  }) async {
    final db = await AppDatabase().database;
    String stockQuery = numberQuery(
      colName: "stock_in_main_measure",
      value: stock,
    );
    String minStockQuery = numberQuery(
      colName: "(stock_in_main_measure - instock_mainmeasure)",
      value: minStock,
    );
    final pIds = [];

    if (barcode != null && barcode != '') {
      final bCursor = await db.query(
        'lstBarcodes',
        where: "barcode LIKE '$barcode'",
      );
      pIds.addAll(bCursor.map((e) => e['product_id']).toList());
    }
    final cursor = await db.query(
      'cache',
      where: '''
        ${barcode != null && barcode != '' && pIds.isEmpty ? "1=0" : "1=1"}
        ${stockQuery != '' ? 'AND $stockQuery' : ''}    
        ${minStockQuery != '' ? 'AND $minStockQuery' : ''}
        ${noColor == true ? "AND colorId IS NULL" : ''}
        ${noColor != true && colorId != null ? ' AND colorId = $colorId' : ''}
        ${warehouseId != null ? "AND warehouseId = '$warehouseId'" : 'AND warehouseId IS NULL'}
        ${measureId != null ? "AND measureId = '$measureId'" : ''}
        ${currencyId != null ? "AND currencyId = '$currencyId'" : ''}
        ${query != null && query != '' ? "AND name LIKE '%${query.replaceAll(" ", "%")}%'" : ''}
        ${property_1 != null && property_1 != '' ? "AND property_1 LIKE '$property_1'" : ''}
        ${property_2 != null && property_2 != '' ? "AND property_2 LIKE '$property_2'" : ''}
        ${property_3 != null && property_3 != '' ? "AND property_3 LIKE '$property_3'" : ''}
        ${property_4 != null && property_4 != '' ? "AND property_4 LIKE '$property_4'" : ''}
        ${property_5 != null && property_5 != '' ? "AND property_5 LIKE '$property_5'" : ''}
        ${pIds.isNotEmpty || ((ids ?? []).isNotEmpty) ? "AND _id IN (${[...(ids ?? []), ...pIds].map((e) => "'$e'").join(',')})" : ''}
        ORDER BY $orderBy
    ''',
    );
    final data = cursor.map((e) => MProduct(json: Map.from(e))).toList();
    // debugPrint(data[0].json.toString());
    return data;
  }

  static Future<List<String>> getProperties() async {
    final db = await AppDatabase().database;
    final List<String> propertiesUnique = [];
    final properties1 = await db.rawQuery(
      'SELECT DISTINCT property_1 FROM $tableName '
      'WHERE property_1 IS NOT NULL AND property_1 != \'\'',
    );
    propertiesUnique.addAll(properties1.map((e) => e['property_1'].toString()));
    final properties2 = await db.rawQuery(
      'SELECT DISTINCT property_2 FROM $tableName '
      'WHERE property_2 IS NOT NULL'
      ' AND property_2 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties2.map((e) => e['property_2'].toString()));
    final properties3 = await db.rawQuery(
      'SELECT DISTINCT property_3 FROM $tableName '
      'WHERE property_3 IS NOT NULL'
      ' AND property_3 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties3.map((e) => e['property_3'].toString()));
    final properties4 = await db.rawQuery(
      'SELECT DISTINCT property_4 FROM $tableName '
      'WHERE property_4 IS NOT NULL'
      ' AND property_4 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties4.map((e) => e['property_4'].toString()));

    final properties5 = await db.rawQuery(
      'SELECT DISTINCT property_5 FROM $tableName '
      'WHERE property_5 IS NOT NULL'
      ' AND property_5 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties5.map((e) => e['property_5'].toString()));

    return propertiesUnique;
  }

  static Future<List<String>>? getProperties1() async {
    final db = await AppDatabase().database;
    final List<String> propertiesUnique = [];
    final properties1 = await db.rawQuery(
      'SELECT DISTINCT property_1 FROM $tableName '
      'WHERE property_1 IS NOT NULL AND property_1 != \'\'',
    );
    propertiesUnique.addAll(properties1.map((e) => e['property_1'].toString()));
    return propertiesUnique;
  }

  static Future<List<String>>? getProperties2() async {
    final db = await AppDatabase().database;
    final List<String> propertiesUnique = [];
    final properties2 = await db.rawQuery(
      'SELECT DISTINCT property_2 FROM $tableName '
      'WHERE property_2 IS NOT NULL'
      ' AND property_2 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties2.map((e) => e['property_2'].toString()));
    return propertiesUnique;
  }

  static Future<List<String>>? getProperties3() async {
    final db = await AppDatabase().database;
    final List<String> propertiesUnique = [];
    final properties3 = await db.rawQuery(
      'SELECT DISTINCT property_3 FROM $tableName '
      'WHERE property_3 IS NOT NULL'
      ' AND property_3 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties3.map((e) => e['property_3'].toString()));
    return propertiesUnique;
  }

  static Future<List<String>>? getProperties4() async {
    final db = await AppDatabase().database;
    final List<String> propertiesUnique = [];
    final properties4 = await db.rawQuery(
      'SELECT DISTINCT property_4 FROM $tableName '
      'WHERE property_4 IS NOT NULL'
      ' AND property_4 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties4.map((e) => e['property_4'].toString()));
    return propertiesUnique;
  }

  static Future<List<String>>? getProperties5() async {
    final db = await AppDatabase().database;
    final List<String> propertiesUnique = [];
    final properties5 = await db.rawQuery(
      'SELECT DISTINCT property_5 FROM $tableName '
      'WHERE property_5 IS NOT NULL'
      ' AND property_5 NOT IN (\'\''
      '${propertiesUnique.map((e) => "'$e'").join(',')}'
      ')',
    );
    propertiesUnique.addAll(properties5.map((e) => e['property_5'].toString()));
    return propertiesUnique;
  }

  Future<void> changeColor(MColor? value) async {
    final db = await AppDatabase().database;
    await db.transaction((txn) async {
      await txn.delete(
        MColorConnection.tableName,
        where: "productId LIKE ?",
        whereArgs: [json['_id']],
      );
      await txn.update(
        "cache",
        {
          "colorId": value?.id,
          "colorName": value?.name,
          "fontColor": value?.fontColor,
          "backgroundColor": value?.backgroundColor,
        },
        where: "_id = ?",
        whereArgs: [json['_id']],
      );
      if (value != null) {
        await txn.insert(MColorConnection.tableName, {
          "productId": json['_id'],
          "colorId": value.id,
        });

        json['colorId'] = value.id;

        json['colorName'] = value.name;
        json['fontColor'] = value.fontColor;
        json['backgroundColor'] = value.backgroundColor;
      } else {
        json['colorName'] = null;
        json['fontColor'] = null;
        json['backgroundColor'] = null;
      }
      return true;
    });
  }

  static Future<void> changeColorMultiple({
    required List<MProduct> products,
    required MColor? color,
  }) async {
    final db = await AppDatabase().database;
    await db.transaction((txn) async {
      for (var product in products) {
        await txn.delete(
          MColorConnection.tableName,
          where: "productId LIKE ?",
          whereArgs: [product.json['_id']],
        );
        await txn.update(
          "cache",
          {
            "colorId": color?.id,
            "colorName": color?.name,
            "fontColor": color?.fontColor,
            "backgroundColor": color?.backgroundColor,
          },
          where: "_id = ?",
          whereArgs: [product.json['_id']],
        );
        if (color != null) {
          await txn.insert(MColorConnection.tableName, {
            "productId": product.json['_id'],
            "colorId": color.id,
          });
          product.json['colorName'] = color.name;
          product.json['fontColor'] = color.fontColor;
          product.json['backgroundColor'] = color.backgroundColor;
        } else {
          product.json['colorName'] = null;
          product.json['fontColor'] = null;
          product.json['backgroundColor'] = null;
        }
      }
      return true;
    });
  }

  static Future<MProduct> getById(String id) async {
    final db = await AppDatabase().database;
    final c = await db.query(tableName, where: "_id = '$id'");
    return MProduct(json: Map.from(c.first ?? {}));
  }

  Future<List<MTransaction>>? getTransactions() async {
    final db = await AppDatabase().database;
    final c = await db.rawQuery('''
      SELECT 
          transactions.*, 
          warehouse.name as warehouse_name, 
          customer.name as  customer_name
      FROM transactions 
        RIGHT JOIN customer ON transactions.customer_1 = customer._id
        RIGHT JOIN warehouse ON transactions.warehouse_1 = warehouse._id
      WHERE product = '${json['_id']}'
      ORDER BY id DESC
    ''');
    return c.map((e) => MTransaction(json: Map.from(e))).toList();
  }
}
