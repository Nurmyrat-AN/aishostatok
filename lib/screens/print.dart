import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class PrintScreen extends StatefulWidget {
  final List<String> selectedProducts;

  const PrintScreen({super.key, required this.selectedProducts});

  @override
  State<StatefulWidget> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  Future<List<MCurrency>>? _future;
  List<MCurrency>? _currencies;
  MCurrency? _currency;
  final _property_1 = TextEditingController();
  final _property_2 = TextEditingController();
  final _property_3 = TextEditingController();
  final _property_4 = TextEditingController();
  final _property_5 = TextEditingController();
  final _fontSizeController = TextEditingController();
  double _fontSize = 5;

  String? p1 = '', p2 = '', p3 = '', p4 = '', p5 = '';

  @override
  void initState() {
    super.initState();
    _future = MCurrency.getAllWithRate();
    _property_1.addListener(() => _listener(1));
    _property_2.addListener(() => _listener(2));
    _property_3.addListener(() => _listener(3));
    _property_4.addListener(() => _listener(4));
    _property_5.addListener(() => _listener(5));
    _fontSizeController.addListener(() => _listener(6));
    _initProperties();
  }

  _listener(int key) async {
    final pref = await SharedPreferences.getInstance();
    switch (key) {
      case 1:
        p1 = _property_1.text;
        pref.setString("property_1", _property_1.text);
        break;
      case 2:
        p2 = _property_2.text;
        pref.setString("property_2", _property_2.text);
        break;
      case 3:
        p3 = _property_3.text;
        pref.setString("property_3", _property_3.text);
        break;
      case 4:
        p4 = _property_4.text;
        pref.setString("property_4", _property_4.text);
        break;
      case 5:
        p5 = _property_5.text;
        pref.setString("property_5", _property_5.text);
        break;
      case 6:
        _fontSize = double.tryParse(_fontSizeController.text) ?? 5;
        pref.setDouble("fontSize", _fontSize);
        break;
    }
    setState(() {});
  }

  _initProperties() async {
    final pref = await SharedPreferences.getInstance();
    _property_1.text = pref.getString('property_1') ?? "Aýratynlyk 1";
    _property_2.text = pref.getString('property_2') ?? "Aýratynlyk 2";
    _property_3.text = pref.getString('property_3') ?? "Aýratynlyk 3";
    _property_4.text = pref.getString('property_4') ?? "Aýratynlyk 4";
    _property_5.text = pref.getString('property_5') ?? "Aýratynlyk 5";
    _fontSizeController.text = (pref.getDouble('fontSize') ?? 5).toString();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Öň gorme")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    _currencies = snapshot.data ?? [];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Autocomplete<MCurrency>(
                        optionsBuilder:
                            (textEditingValue) => _currencies!.where(
                              (element) => element.name.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            ),
                        onSelected:
                            (option) => setState(() {
                              _currency = option;
                            }),
                        displayStringForOption: (option) => option.name,
                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) => TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onSubmitted: (value) => onFieldSubmitted(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Çap etme walýutasy",
                                suffixIcon:
                                    _currency == null
                                        ? null
                                        : IconButton(
                                          onPressed: () {
                                            textEditingController.text = "";
                                            setState(() {
                                              _currency = null;
                                            });
                                          },
                                          icon: Icon(Icons.clear),
                                        ),
                              ),
                            ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Hatyň razmeri",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _fontSizeController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _property_1,
                    decoration: InputDecoration(labelText: "Aýratynlyk 1"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _property_2,
                    decoration: InputDecoration(labelText: "Aýratynlyk 2"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _property_3,
                    decoration: InputDecoration(labelText: "Aýratynlyk 3"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _property_4,
                    decoration: InputDecoration(labelText: "Aýratynlyk 4"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _property_5,
                    decoration: InputDecoration(labelText: "Aýratynlyk 5"),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: (format) => _generatePdf(format, "Harytlar"),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.anekLatinLight();
    final products = await MProduct.getAll(ids: widget.selectedProducts);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(8),
        pageFormat: format,
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: font, fontSize: _fontSize),
        ),
        build: (context) {
          return pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            columnWidths: {
              0: pw.FixedColumnWidth(10),
              3: pw.FixedColumnWidth(16),
              4: pw.FixedColumnWidth(16),
              5: pw.FixedColumnWidth(10),
              6: pw.FixedColumnWidth(16),
              7: pw.FixedColumnWidth(16),
              8: pw.FixedColumnWidth(16),
              9: pw.FixedColumnWidth(10),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                children: [
                  pw.Center(child: pw.Text("T/b")),
                  pw.Center(child: pw.Text("Barkod")),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text("Ady"),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Ammardaky sany"),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Ammarda azyndan bolmaly sany"),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Ölçeg"),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Alyş baha"),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Satyş baha"),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Minimum satyş baha"),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text("Pul birligi"),
                    ),
                  ),
                  if (p1 != null && p1!.isNotEmpty)
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(p1 ?? "Ayratynlyk 1"),
                      ),
                    ),
                  if (p2 != null && p2!.isNotEmpty)
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(p2 ?? "Ayratynlyk 2"),
                      ),
                    ),
                  if (p3 != null && p3!.isNotEmpty)
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(p3 ?? "Ayratynlyk 3"),
                      ),
                    ),
                  if (p4 != null && p4!.isNotEmpty)
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(p4 ?? "Ayratynlyk 4"),
                      ),
                    ),
                  if (p5 != null && p5!.isNotEmpty)
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(p5 ?? "Ayratynlyk 5"),
                      ),
                    ),
                ],
              ),
              ...products.map((e) {
                double rate = 1;
                if (_currency != null) {
                  final defaultCurrency = (_currencies ?? []).firstWhere(
                    (element) => element.json['_id'] == e.json['_id'],
                    orElse: () => MCurrency(json: {"rate": 1}),
                  );
                  rate =
                      1 /
                      (defaultCurrency.json['rate'] ?? 1) *
                      (_currency!.json['rate'] ?? 1);
                }
                return pw.TableRow(
                  children: [
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text("${products.indexOf(e) + 1}"),
                      ),
                    ),

                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(e.json['barcode']),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 1),
                      child: pw.Text(e.name),
                    ),

                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(
                          e.json['stock_in_main_measure'].toString(),
                        ),
                      ),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(
                          e.json['difference_in_main_measure'].toString(),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 1),
                      child: pw.Text(e.json['measureName'].toString()),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(
                          (e.json['price_base_for_buying'] * rate)
                              .toStringAsFixed(2),
                        ),
                      ),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(
                          (e.json['price_base_for_sale'] * rate)
                              .toStringAsFixed(2),
                        ),
                      ),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(
                          (e.json['price_minimum_for_sale'] * rate)
                              .toStringAsFixed(2),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 1),
                      child: pw.Text(
                        _currency?.name ?? e.json['currencyName'].toString(),
                      ),
                    ),
                    if (p1 != null && p1!.isNotEmpty)
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(e.json['property_1'].toString()),
                      ),
                    if (p2 != null && p2!.isNotEmpty)
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(e.json['property_2'].toString()),
                      ),
                    if (p3 != null && p3!.isNotEmpty)
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(e.json['property_3'].toString()),
                      ),
                    if (p4 != null && p4!.isNotEmpty)
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(e.json['property_4'].toString()),
                      ),
                    if (p5 != null && p5!.isNotEmpty)
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 1),
                        child: pw.Text(e.json['property_5'].toString()),
                      ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
