import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

abstract class BaseModel {

  final Map<String, dynamic> json;

  BaseModel({required this.json});

  int? get id => json['id'];

  bool get isDeleted => json['deletedAt'] != null;

  String get name => json['name'];

  static Future<void> createTable (Database db)async{}

}
