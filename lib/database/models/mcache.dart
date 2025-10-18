import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/base_model.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class MCache extends BaseModel {
  MCache({required super.json});
  static String tableName = 'cache';
  static Future<void> createTable(Database db) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute(
      "CREATE TABLE $tableName("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "_id TEXT,"
      "_isactive TEXT,"
      "code TEXT,"
      "name TEXT,"
      "price_base_for_buying REAL,"
      "price_base_for_sale REAL,"
      "price_minimum_for_sale REAL,"
      "property_1 TEXT,"
      "property_2 TEXT,"
      "property_3 TEXT,"
      "property_4 TEXT,"
      "property_5 TEXT,"
      "warehouseId TEXT,"
      "warehouseName TEXT,"
      "instock_mainmeasure REAL,"
      "stock_in_main_measure REAL,"
      "difference_in_main_measure REAL,"
      "currency TEXT,"
      "currencyName TEXT,"
      "measure TEXT,"
      "measureName TEXT,"
      "colorId INTEGER,"
      "colorName TEXT,"
      "backgroundColor TEXT,"
      "fontColor TEXT,"
      "row_number_for_custom_sort REAL DEFAULT 0,"
      "barcode TEXT"
      ")",
    );
  }

  static Future<Map<String, String>> _queryToMap(
    Transaction txn,
    tableName,
  ) async {
    final Map<String, String> map = {};
    final cursor = await txn.query(tableName);
    for (var row in cursor) {
      map[row['_id'].toString()] = row['name'].toString();
    }
    return map;
  }

  static dynamic prepareCache() async {
    final db = await AppDatabase().database;
    return await db.transaction((txn) async {
      await txn.delete(MCache.tableName);
      final measures = await _queryToMap(txn, "measure");
      final currencies = await _queryToMap(txn, "currency");
      final warehouses = await _queryToMap(txn, "warehouse");
      final bCursor = await txn.query("lstBarcodes", groupBy: "product_id");
      final Map<String, String> barcodes = {};
      for (var row in bCursor) {
        barcodes[row['product_id'].toString()] = row['barcode'].toString();
      }

      final cConCursor = await txn.query("color_connections");
      final Map<String, int> cConnections = {};
      for (var row in cConCursor) {
        cConnections[row['productId'].toString()] = int.parse(
          row['colorId'].toString(),
        );
      }
      final cCursor = await txn.query(
        "color_configurations",
        where: "id IN (${cConnections.values.join(',')})",
      );
      final Map<int, MColor> colors = {};
      for (var row in cCursor) {
        colors[int.parse(row['id'].toString())] = MColor(json: Map.from(row));
      }

      final sCursor = await txn.query("stock");
      final Map<String, List<Map<String, dynamic>>> stocks = {};
      for (var row in sCursor) {
        final productId = row['product_id'].toString();
        if (!stocks.containsKey(productId)) {
          stocks[productId] = [
            {
              "warehouseId": null,
              "warehouseName": "Ählisi",
              "stock_in_main_measure": 0,
            },
          ];
        }
        stocks[productId]![0]['stock_in_main_measure'] +=
            row['stock_in_main_measure'];

        stocks[productId]!.add({
          "warehouseId": row['warehouse_id'].toString(),
          "warehouseName": warehouses[row['warehouse_id'].toString()],
          "stock_in_main_measure": row['stock_in_main_measure'],
        });
      }

      final products = await txn.query("product");
      final List<Map<String, dynamic>> caches = [];
      for (var product in products) {
        final Map<String, dynamic> pMap = Map.from(product);

        pMap['measureName'] = measures[pMap['measure']];
        pMap['currencyName'] = currencies[pMap['currency']];
        pMap['barcode'] = barcodes[pMap['_id']];
        if (cConnections.containsKey(pMap['_id'])) {
          pMap['colorId'] = cConnections[pMap['_id']];
          pMap['colorName'] = colors[cConnections[pMap['_id']]]?.name;
          pMap['backgroundColor'] =
              colors[cConnections[pMap['_id']]]?.backgroundColor;
          pMap['fontColor'] = colors[cConnections[pMap['_id']]]?.fontColor;
        }

        pMap['warehouseId'] = null;
        pMap['warehouseName'] = "Ählisi";
        pMap['stock_in_main_measure'] = 0;
        pMap['difference_in_main_measure'] =
            pMap['stock_in_main_measure'] - (pMap['instock_mainmeasure'] ?? 0);

        if (!stocks.containsKey(product['_id'].toString())) {
          await txn.insert(MCache.tableName, pMap);
          caches.add(pMap);
        } else {
          for (var stock in stocks[product['_id'].toString()]!) {
            pMap['warehouseId'] = stock['warehouseId'];
            pMap['warehouseName'] = stock['warehouseName'];
            pMap['stock_in_main_measure'] = stock['stock_in_main_measure'];
            pMap['difference_in_main_measure'] =
                pMap['stock_in_main_measure'] -
                (pMap['instock_mainmeasure'] ?? 0);
            await txn.insert(MCache.tableName, pMap);
            caches.add(Map.from(pMap));
          }
        }
      }
      debugPrint("Cache prepared");
      return caches;
    });
  }
}
