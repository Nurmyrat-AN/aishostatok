import 'package:aishostatok/database/base_model.dart';
import 'package:sqflite/sqflite.dart';

class MTransaction extends BaseModel {
  MTransaction({required super.json});

  String get transactionType => transactionTypesEnum[json['transaction_type']] ?? '';

  String get count => json['count_mainmeasure'];

  String get price => json['price_single_mainmeasure_in_product_currency'];

  String get customer => json['customer_name'];

  String get node => json['note'] ?? '';

  String get warehouse => json['warehouse_name'];

  Map<String, String> transactionTypesEnum = {
    "Inbound/Purchase": 'Giriş/Satyn alynan',
    "Inbound/Return": 'Giriş/Yzyna tabşyrylan',
    "Inbound/Other": 'Giriş/Başga',
    "Outbound/Sale": 'Çykyş/Satylan',
    "Outbound/Return": 'Çykyş/Yzyna tabşyrylan',
    "Outbound/Expense": 'Çykyş/Çykdajy',
    "Outbound/Other": 'Çykyş/Başga',
    "Warehouse to warehouse transfer": 'Ammarlaryň arasyndaky hereket',
  };

  static String tableName = 'transactions';

  String get date => json['transaction_date'].toString().replaceAll('T', ' ');

  static createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        _id TEXT,
        _isactive TEXT,
        code TEXT,
        customer_1 TEXT,
        customer_2 TEXT,
        transaction_date TEXT,
        total_sum TEXT,
        transaction_type TEXT,
        warehouse_1 TEXT,
        warehouse_2 TEXT,
        note TEXT,
        product TEXT,
        count_mainmeasure TEXT,
        price_single_mainmeasure_in_product_currency TEXT,
        UNIQUE(transaction_type, product, warehouse_1)
      );
    ''');
  }
}
