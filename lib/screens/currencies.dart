import 'package:aishostatok/database/app_database.dart';
import 'package:aishostatok/database/models/currency.dart';
import 'package:flutter/material.dart';

class CurrenciesConf extends StatefulWidget {
  const CurrenciesConf({super.key});

  @override
  State<CurrenciesConf> createState() => _CurrenciesConf();
}

class _CurrencyController {
  final MCurrency currency;
  final TextEditingController controller;

  _CurrencyController({required this.currency})
    : controller = TextEditingController(
        text: currency.json['rate'].toString(),
      );
}

class _CurrenciesConf extends State<CurrenciesConf> {
  List<_CurrencyController>? _future;

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Walýutalar"),
      content: Builder(
        builder: (context) {
          final currencies = _future ?? [];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children:
                    currencies.map((currencyController) {
                      return TextField(
                        controller: currencyController.controller,
                        decoration: InputDecoration(
                          labelText: currencyController.currency.name,
                        ),
                      );
                    }).toList(),
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Goý Bolsun", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () async {
            final db = await AppDatabase().database;
            final newDataList =
                (_future ?? [])
                    .map(
                      (currencyController) => ({
                        "currency_id": currencyController.currency.json['_id'],
                        "rate":
                            double.tryParse(
                              currencyController.controller.text,
                            ) ??
                            1,
                      }),
                    )
                    .toList();
            await db.transaction((txn) async {
              await txn.delete("currencyRate");
              for (var value in newDataList) {
                await txn.insert('currencyRate', value);
              }
              return true;
            });
            Navigator.pop(context);
          },
          child: Text("Ýatda Sakla", style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }

  _getCurrencies() async {
    final currencies = await MCurrency.getAllWithRate();
    setState(() {
      _future =
          (currencies ?? [])
              .map((currency) => _CurrencyController(currency: currency))
              .toList();
    });
  }
}
