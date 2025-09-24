import 'dart:convert';

import 'package:aishostatok/database/aishmanager.dart';
import 'package:aishostatok/database/app_database.dart';
import 'package:flutter/material.dart';
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
        await _aishManager.setLastUpdatedAt(DateTime.now().toIso8601String());
        mainInfoStatus +=
            "Soňky üýtgedilen senesi: ${DateTime.now().toIso8601String()}\n";
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
        if (tableName == "warehouse") {
          await txn.insert(tableName, {
            "_id": json['_id'],
            "_isactive": json['_isactive'],
            "name": json['name'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        if (tableName == "product") {
          var instock_mainmeasure = json['instock_mainmeasure'];
          try{
            List<dynamic> lstArbitraryProperties = json['lstArbitraryProperties'];
            for(var arbitraryProperty in lstArbitraryProperties){
              if(arbitraryProperty['Key'] == minStockAttribute){
                instock_mainmeasure = arbitraryProperty['Value'];
                break;
              }
            }
          }catch(e){}
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
          await txn.insert(tableName, writeData, conflictAlgorithm: ConflictAlgorithm.replace);
          final List<dynamic> barcodes = json['lstBarcodes'] ?? [];
          if(barcodes.isNotEmpty) {
            debugPrint(barcodes.toString());
          }
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
      content: Text(_error ?? _status),
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
