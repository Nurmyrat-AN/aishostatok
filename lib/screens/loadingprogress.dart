import 'dart:convert';

import 'package:aishostatok/database/aishmanager.dart';
import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/models/customer.dart';
import 'package:aishostatok/database/models/mcache.dart';
import 'package:aishostatok/database/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:sqflite/sqflite.dart';

class LoadingProgress extends StatefulWidget {
  const LoadingProgress({super.key});

  @override
  State<StatefulWidget> createState() => _LoadingProgressState();
}

class _LoadingProgressState extends State<LoadingProgress> {
  String _status = "Cache obýektleriň maglumatlary alynýar...";
  bool _isDisposed = false;
  String? _error;
  bool _isFinished = false;
  dynamic _caches;
  final AishManager _aishManager = AishManager();

  @override
  initState() {
    super.initState();
    _fetchData();
  }

  @override
  dispose() {
    _isDisposed = true;
    super.dispose();
  }

  _fetchData() async {
    if (_isDisposed) return;
    try {
      final cachedObjectsInfo = await _aishManager.getCachedObjectsInfo();
      if (_isDisposed) return;
      String mainInfoStatus = "${cachedObjectsInfo.toString()}\n";
      setState(() {
        _status = "$mainInfoStatus Cache obýektler alynýar...";
      });
      int lastSequenceNumber = await _aishManager.lastSequenceNumber;
      if (_isDisposed) return;
      mainInfoStatus += "Soňky sequence nomer: $lastSequenceNumber\n";
      setState(() {
        _status = "$mainInfoStatus Cache obýektler alynýar...";
      });
      final data = await _aishManager.getCachedObjects();
      if (_isDisposed) return;
      mainInfoStatus += "Alnan obýektler: ${data.length}\n";

      if (data.isEmpty) {
        setState(() {
          _status = "$mainInfoStatus Harytlaryň galyndylary alynýar...";
        });
        final stocksOfProducts = await _aishManager.getStocksOfProducts();
        if (_isDisposed) return;
        mainInfoStatus +=
            "Harytlaryň galyndylary alyndy: ${stocksOfProducts.length}\n";
        setState(() {
          _status = "$mainInfoStatus Ýerli baza ýazdyrylýar...";
        });
        await _writeStocksToDb(stocksOfProducts);
        if (_isDisposed) return;
        mainInfoStatus += "Ýerli baza ýazdyryldy\n";
        setState(() {
          _status = "$mainInfoStatus Ýerli keş taýýarlanýar...";
        });
        if (_isDisposed) return;
        await MCache.prepareCache();
        if (_isDisposed) return;
        final lastDate = DateTime.now().toIso8601String();
        await _aishManager.setLastUpdatedAt(lastDate);
        mainInfoStatus += "Ýerli keş taýýarlandy\n";
        
        if (_isDisposed) return;
        mainInfoStatus = await _getTransactions(mainInfoStatus);

        mainInfoStatus +=
            "Soňky üýtgedilen senesi: $lastDate\n";
        setState(() {
          _status = "$mainInfoStatus Ýerine ýetirildi!";
          _isFinished = true;
        });
        return;
      }
      setState(() {
        _status = "$mainInfoStatus Ýerli baza ýazdyrylýar...";
      });

      lastSequenceNumber = await _writeToDb(data) ?? lastSequenceNumber;
      if (_isDisposed) return;
      await _aishManager.setLastSequenceNumber(lastSequenceNumber);
      await Future.delayed(Duration(milliseconds: 200));
      if (_isDisposed) return;
      _fetchData();
    } catch (e) {
      if (_isDisposed) return;
      debugPrint(e.toString());
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<String> _getTransactions(String mainInfoStatus) async {
    String mainInfo = mainInfoStatus;

    if (_isDisposed) return mainInfo;
    try {
      final lastTransactionSequenceNumber =
          await AishManager().lastTransactionSequenceNumber;
      setState(() {
        _status = "${mainInfo}Soňky sequence nomer: $lastTransactionSequenceNumber\n Hereketler alynýar...";
      });
      final transactions = await _aishManager.getTransactions();
      setState(() {
        _status =
            "${mainInfo}Soňky sequence nomer: $lastTransactionSequenceNumber\nAlynan hereketler ${transactions.length}\n Ýerli baza ýazdyrylýar...";
      });
      if (_isDisposed) return '';
      final db = await AppDatabase().database;
      await MTransaction.createTable(db);
      if (transactions.isEmpty) return "${mainInfo}Soňky sequence nomer: $lastTransactionSequenceNumber\nHereketler alyndy\n";
      int lastSequenceNumber = 0;
      await db.transaction((txn) async {
        for (var object in transactions) {
          lastSequenceNumber = object['_sequence_number'];
          final invoices = object['lst_invoices'];
          for (var invoice in invoices) {
            if (invoice['_isactive'] == 'active') {
              final items = invoice['lst_items'];
              for (var item in items) {
                final Map<String, dynamic> json = {
                  "_id": invoice['_id'],
                  "_isactive": invoice['_isactive'],
                  "code": invoice['code'],
                  "customer_1": invoice['customer_1'],
                  "customer_2": invoice['customer_2'],
                  "transaction_date": invoice['transaction_date'],
                  "total_sum": invoice['total_sum'],
                  "transaction_type": invoice['transaction_type'],
                  "warehouse_1": invoice['warehouse_1'],
                  "warehouse_2": invoice['warehouse_2'],
                  "note": invoice['note'],
                  'product': item['product'],
                  'count_mainmeasure': item['count_mainmeasure'],
                  'price_single_mainmeasure_in_product_currency':
                      item['price_single_mainmeasure_in_product_currency'],
                };
                await txn.insert(
                  "transactions",
                  json,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            }
          }
        }
      });
      await AishManager().setLastTransactionSequenceNumber(lastSequenceNumber);
      return await _getTransactions(mainInfoStatus);
    } catch (e) {
      debugPrint(e.toString());
      return mainInfo;
    }
  }

  Future<void> _writeStocksToDb(List<dynamic> stocksOfProducts) async {
    if (_isDisposed) return;
    final db = await AppDatabase().database;
    await db.transaction((txn) async {
      await txn.update("product", {"stock_in_main_measure": 0.0});
      await txn.delete("stock");
      for (var object in stocksOfProducts) {
        final Map<String, dynamic> json = object;
        json['_id'] = "${json['product_id']}_${json['warehouse_id']}";
        await txn.insert(
          "stock",
          object,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.execute('''
        UPDATE product SET stock_in_main_measure = stock_in_main_measure + ${json['stock_in_main_measure']} WHERE _id = '${json['product_id']}'
        ''');
      }
    });
  }

  Future<int?> _writeToDb(List<dynamic> data) async {
    if (_isDisposed) return null;
    int lastSequenceNumber = 0;
    final minStockAttribute = await AishManager().minStockAttribute;
    final db = await AppDatabase().database;
    await MCustomer.createTable(db);

    await db.transaction((txn) async {
      for (var object in data) {
        lastSequenceNumber = object['_sequence_number'];
        final Map<String, dynamic> json = object;

        String tableName = json['OBJECT_TYPE'];
        if (tableName == "currency") {
          await txn.insert(tableName, {
            "_id": json['_id'],
            "_isactive": json['_isactive'],
            "name": json['name'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        if (tableName == "measure") {
          await txn.insert(tableName, {
            "_id": json['_id'],
            "_isactive": json['_isactive'],
            "name": json['name'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        if (tableName == "customer") {
          await txn.insert(tableName, {
            "_id": json['_id'],
            "_isactive": json['_isactive'],
            "name": json['name'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        if (tableName == "warehouse") {
          await txn.insert(tableName, {
            "_id": json['_id'],
            "_isactive": json['_isactive'],
            "name": json['name'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        if (tableName == "product") {
          var instock_mainmeasure = json['instock_mainmeasure'];

          try {
            if (minStockAttribute == 'property_1' ||
                minStockAttribute == 'property_2' ||
                minStockAttribute == 'property_3' ||
                minStockAttribute == 'property_4' ||
                minStockAttribute == 'property_5') {
              instock_mainmeasure = json[minStockAttribute];
            } else {
              List<dynamic> lstArbitraryProperties =
                  json['lstArbitraryProperties'];
              for (var arbitraryProperty in lstArbitraryProperties) {
                if (arbitraryProperty['Key'] == minStockAttribute) {
                  instock_mainmeasure = arbitraryProperty['Value'];
                  break;
                }
              }
            }
          } catch (e) {}

          final writeData = {
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
            "instock_mainmeasure": instock_mainmeasure,
          };
          await txn.insert(
            tableName,
            writeData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          final List<dynamic> barcodes = json['lstBarcodes'] ?? [];
          await txn.delete(
            "lstBarcodes",
            where: "product_id = ?",
            whereArgs: [json['_id']],
          );
          for (var barcode in barcodes) {
            await txn.insert("lstBarcodes", {
              "product_id": json['_id'],
              "barcode": barcode,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
      return true;
    });
    return lastSequenceNumber;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Ýüklenilýär"),
      content:
          _caches != null
              ? SingleChildScrollView(child: JsonViewer(_caches))
              : Text(_error ?? _status),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(_isFinished ? "Ýerine ýetirildi" : "Goý Bolsun"),
        ),
      ],
    );
  }
}
