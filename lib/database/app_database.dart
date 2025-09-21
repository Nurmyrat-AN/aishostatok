import 'dart:io';

import 'package:aishostatok/database/aishmanager.dart';
import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/database/models/measure.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:aishostatok/database/models/stock.dart';
import 'package:aishostatok/database/models/warehouse.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqlite3/sqlite3.dart';

class AppDatabase {
  static Database? _database; // The actual database instance.
  static final AppDatabase _instance =
      AppDatabase._internal(); // Singleton instance.

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms (Linux, Windows, macOS)
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit(); // Initialize sqflite_common_ffi for desktop
      databaseFactory = databaseFactoryFfi; // Set the FFI database factory
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'aishostatok.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onUpgrade,
    );
  }

  @pragma('vm:entry-point')
  Future<void> _onCreate(Database db, int version) async {
    await initializeDatabase(db);
  }

  @pragma('vm:entry-point')
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await initializeDatabase(db);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  initializeDatabase(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
    await MCurrency.createTable(db);
    await MWarehouse.createTable(db);
    await MMeasure.createTable(db);
    await MProduct.createTable(db);
    await MStock.createTable(db);
    await MColor.createTable(db);
    await AishManager().setLastSequenceNumber(0);
  }
}
