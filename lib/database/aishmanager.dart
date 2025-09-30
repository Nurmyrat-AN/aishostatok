import 'dart:convert';

import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/database/models/measure.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:aishostatok/database/models/stock.dart';
import 'package:aishostatok/database/models/warehouse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AishManager {
  String? _serverIp;
  int? _lastSequenceNumber;

  Future<int> get lastSequenceNumber async {
    // return 59356;
    if (_lastSequenceNumber == null) {
      final pref = await SharedPreferences.getInstance();
      _lastSequenceNumber = pref.getInt('last_sequence_number') ?? 0;
    }
    return _lastSequenceNumber!;
  }

  Future<String> get serverIp async {
    if (_serverIp == null) {
      final pref = await SharedPreferences.getInstance();
      _serverIp =
          pref.getString('server_ip') ?? 'http://127.0.0.1:5959/aish5/api/v1';
    }

    return _serverIp!;
  }

  Future<String> get badgeSize async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('badge_size') ?? '100';
  }

  Future<void> setServerIp(String ip) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('server_ip', ip);
    _serverIp = ip;
  }

  Future<void> setBadgeSize(String badgeSize) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('badge_size', badgeSize);
  }

  Future<Uri> get cachedObjectsUri async {
    final serverIp = await this.serverIp;
    final badgeSize = await this.badgeSize;
    final sequenceNumber = await lastSequenceNumber;

    final path = Uri.parse(
      "$serverIp/cachedobjects?since=$sequenceNumber&limit=$badgeSize",
    );
    return path;
  }

  Future<Uri> get cachedObjectsInfo async {
    final serverIp = await this.serverIp;
    final path = Uri.parse("$serverIp/cachedobjectsinfo");
    return path;
  }

  Future<Uri> get stocksOfProducts async {
    final serverIp = await this.serverIp;
    final path = Uri.parse("$serverIp/stocksofproducts");
    return path;
  }

  Future<Map<String, dynamic>> getCachedObjectsInfo() async {
    final response = await http.get(await cachedObjectsInfo);
    final data = jsonDecode(response.body);
    return data;
  }

  Future<List<dynamic>> getCachedObjects() async {
    final response = await http.get(await cachedObjectsUri);
    return jsonDecode(response.body);
  }

  setLastSequenceNumber(int lastSequenceNumber) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt('last_sequence_number', lastSequenceNumber);
    _lastSequenceNumber = lastSequenceNumber;
  }

  Future<List<dynamic>> getStocksOfProducts() async {
    final response = await http.get(await stocksOfProducts);
    return jsonDecode(response.body);
  }

  setLastUpdatedAt(String iso8601string) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('last_updated_at', iso8601string);
  }

  Future<String?> get lastUpdatedAt async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('last_updated_at');
  }

  Future<String> get minStockAttribute async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('minstock') ?? 'minstock';
  }

  clearDB() async {
    final db = await AppDatabase().database;
    await db.transaction((txn) async {
      await txn.delete(MProduct.tableName);
      await txn.delete(MCurrency.tableName);
      await txn.delete(MMeasure.tableName);
      await txn.delete(MWarehouse.tableName);
      await txn.delete(MStock.tableName);
    });
    await setLastSequenceNumber(0);
  }

  Future<void> updateProduct({
    required String id,
    double? priceForSale,
    double? priceForMinimumSale,
    double? priceForBuy,
  }) async {
    final db = await AppDatabase().database;

    try {
      final serverIp = await this.serverIp;
      final response = await http
          .get(Uri.parse("$serverIp/cachedobjects?id=$id"))
          .timeout(Duration(seconds: 3));
      final data = jsonDecode(response.body);
      final product = data[0];
      // if (priceForSale != null) {
      //   product['price_base_for_sale'] = priceForSale;
      // }
      // if (priceForBuy != null) {
      //   product['price_base_for_buying'] = priceForBuy;
      // }
      final response2 = await http.post(
        Uri.parse("$serverIp/updatecacheobject"),
        body: jsonEncode(product),
      );
      final data2 = jsonDecode(response2.body);
      if (data2['ok'] != true) return;
      final response3 = await http.get(
        Uri.parse("$serverIp/cachedobjects?id=$id"),
      );
      final data3 = jsonDecode(response3.body);
      final json = data3[0];
      await db.transaction((txn) async {
        await txn.insert("product", {
          "_id": json['_id'],
          "_isactive": json['_isactive'],
          "code": json['code'],
          "name": json['name'],
          "price_base_for_sale": json['price_base_for_sale'],
          "price_base_for_buying": json['price_base_for_buying'],
          "price_minimum_for_sale": json['price_minimum_for_sale'],
          "currency": json['currency'],
          "measure": json['measure'],
          "property_1": json['property_1'],
          "property_2": json['property_2'],
          "property_3": json['property_3'],
          "property_4": json['property_4'],
          "property_5": json['property_5'],
          "instock_mainmeasure": json['instock_mainmeasure'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        final List<dynamic> barcodes = json['lstBarcodes'] ?? [];
        for (var barcode in barcodes) {
          await txn.insert("lstBarcodes", {
            "product_id": json['_id'],
            "barcode": barcode,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        return true;
      });
    } catch (e) {
      try {
        final cursor = await db.query(
          'product',
          where: '_id = ?',
          whereArgs: [id],
        );
        final Map<String, dynamic> json = Map.from(cursor.first);

        await db.update('product', json, where: '_id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  setMinStockAttribute(String text) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('minstock', text);
  }
}
