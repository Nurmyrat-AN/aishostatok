import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/screens/products.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final db = await AppDatabase().database;
    // await AppDatabase().initializeDatabase(db);
    debugPrint('Database initialized successfully!');
  } catch (e) {
    debugPrint('Error initializing database: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aish Ostatok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ProductsScreen(),
    );
  }
}