import 'dart:async';

import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
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
  double _fontSize = 5.0;
  List<double> _tSizes = [2.0, 9.0, 10.0, 12.0];

  String? p1 = '', p2 = '', p3 = '', p4 = '', p5 = '';
  List<MProduct> products = [];
  int _from = 0, _to = 100;

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

    MProduct.getAll(ids: widget.selectedProducts).then((value) {
      products = value;
      setState(() {});
    });
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
    int tableColCount = 10;
    if (_property_1.text.isNotEmpty) tableColCount++;
    if (_property_2.text.isNotEmpty) tableColCount++;
    if (_property_3.text.isNotEmpty) tableColCount++;
    if (_property_4.text.isNotEmpty) tableColCount++;
    if (_property_5.text.isNotEmpty) tableColCount++;
    final sliderSize =
        products.isEmpty || products.length < _to ? _to : products.length;
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
          Text("Çap ediljek harytlar: $_from - $_to"),
          RangeSlider(
            values: RangeValues(_from.toDouble(), _to.toDouble()),
            min: 0,
            max: sliderSize.toDouble(),
            labels: RangeLabels(_from.toString(), _to.toString()),
            divisions: sliderSize,
            onChanged: (value) {
              final from = value.start.toInt();
              final to = value.end.toInt();
              if (to - from > 1000) {
                if (from != _from) {
                  setState(() {
                    _from = to > 1000 ? to - 1000 : 0;
                  });
                } else {
                  setState(() {
                    _to = from + 1000 <= sliderSize ? from + 1000 : sliderSize;
                  });
                }
              } else {
                setState(() {
                  _from = value.start.toInt();
                  _to = value.end.toInt();
                });
              }
            },
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
          SizedBox(height: 8),
          _TableSizes(
            count: tableColCount,
            onSizesChanged: (tSizes) {
              setState(() {
                _tSizes = tSizes;
              });
            },
          ),
          SizedBox(height: 8),
          Expanded(
            child: PdfPreview(
              dynamicLayout: true,
              build: (format) => _generatePdf(format, "Harytlar"),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.openSansRegular();
    final table = pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths:
          _tSizes
              .map(
                (e) => pw.FractionColumnWidth(
                  e / _tSizes.reduce((res, v) => res + v),
                ),
              )
              .toList()
              .asMap(),
      oddRowDecoration: pw.BoxDecoration(color: PdfColors.blue50),
      headerDecoration: pw.BoxDecoration(color: PdfColors.blue400),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        font: font,
        fontWeight: pw.FontWeight.bold,
        fontSize: _fontSize + 1,
      ),
      cellStyle: pw.TextStyle(font: font, fontSize: _fontSize),
      headerAlignment: pw.Alignment.center,
      headerAlignments: {2: pw.Alignment.centerLeft},
      cellPadding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.centerRight,
        9: pw.Alignment.centerLeft,
      },
      headers: [
        'T/b',
        'Barkod',
        'Ady',
        'Ammardaky sany',
        'Ammarda azyndan bolmaly sany',
        'Ölçeg',
        'Alyş baha',
        'Satyş baha',
        'Minimum satyş baha',
        'Pul birligi',
        if (p1 != null && p1!.isNotEmpty) p1,
        if (p2 != null && p2!.isNotEmpty) p2,
        if (p3 != null && p3!.isNotEmpty) p3,
        if (p4 != null && p4!.isNotEmpty) p4,
        if (p5 != null && p5!.isNotEmpty) p5,
      ],
      data:
          (products.length < _from
                  ? products
                  : products.length < _from + _to
                  ? products.sublist(_from)
                  : products.sublist(_from, _to))
              .map(
                (e) => [
                  "${products.indexOf(e) + 1}",
                  e.json['barcode'] ?? "",
                  e.name,
                  e.json['stock_in_main_measure'].toString(),
                  e.json['difference_in_main_measure'].toString(),
                  e.json['measureName'].toString(),
                  (e.json['price_base_for_buying'] *
                          (1 /
                              (_currency?.json['rate'] ?? 1) *
                              (_currency?.json['rate'] ?? 1)))
                      .toString(),
                  (e.json['price_base_for_sale'] *
                          (1 /
                              (_currency?.json['rate'] ?? 1) *
                              (_currency?.json['rate'] ?? 1)))
                      .toString(),
                  (e.json['price_minimum_for_sale'] *
                          (1 /
                              (_currency?.json['rate'] ?? 1) *
                              (_currency?.json['rate'] ?? 1)))
                      .toString(),
                  _currency?.name ?? e.json['currencyName'].toString(),
                  if (p1 != null && p1!.isNotEmpty) e.json['property_1'],
                  if (p2 != null && p2!.isNotEmpty) e.json['property_2'],
                  if (p3 != null && p3!.isNotEmpty) e.json['property_3'],
                  if (p4 != null && p4!.isNotEmpty) e.json['property_4'],
                  if (p5 != null && p5!.isNotEmpty) e.json['property_5'],
                ],
              )
              .toList(),
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: pw.EdgeInsets.all(8),
        build: (context) => [table],
        maxPages: 5000,
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: font, fontSize: _fontSize),
        ),
      ),
    );

    return pdf.save();
  }
}

class _TableSizes extends StatefulWidget {
  final int count;
  final void Function(List<double> tSizes) onSizesChanged;

  const _TableSizes({required this.count, required this.onSizesChanged});

  @override
  _TableSizesState createState() => _TableSizesState();
}

class _TableSizesState extends State<_TableSizes> {
  List<double> _tSizes = [];
  List<TextEditingController> _controllers = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tSizes = List.generate(widget.count, (index) => 10);
    _controllers =
        _tSizes.map((e) => TextEditingController(text: e.toString())).toList();
    _getSizes();
  }

  @override
  void didUpdateWidget(covariant _TableSizes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _tSizes = List.generate(widget.count, (index) => 10);
      _controllers =
          _tSizes
              .map((e) => TextEditingController(text: e.toString()))
              .toList();
      _getSizes();
    }
  }

  _getSizes() async {
    final pref = await SharedPreferences.getInstance();
    final tSizesString = pref.getString("tSizes");

    if (tSizesString != null) {
      _tSizes =
          tSizesString.split(",").map((e) => double.tryParse(e) ?? 10).toList();
      if (_tSizes.length < widget.count) {
        while (_tSizes.length < widget.count) {
          _tSizes.add(10);
        }
      } else {
        while (_tSizes.length > widget.count) {
          _tSizes.removeLast();
        }
      }
      _controllers =
          _tSizes
              .map((e) => TextEditingController(text: e.toString()))
              .toList();
      widget.onSizesChanged(_tSizes);
      setState(() {});
    }
  }

  _saveSizes() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 200), () async {
      final pref = await SharedPreferences.getInstance();
      pref.setString("tSizes", _tSizes.join(","));
      widget.onSizesChanged(_tSizes);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.95;
    return SizedBox(
      width: width,
      child: Row(
        children:
            _controllers
                .map(
                  (controller) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              '${_controllers.indexOf(controller) + 1}: (${(_tSizes[_controllers.indexOf(controller)] / _tSizes.reduce((res, v) => res + v) * 100).toStringAsFixed(2)}%)',
                          suffix: Text("/"),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final newValue = double.tryParse(value);
                          if (newValue != null) {
                            _tSizes[_controllers.indexOf(controller)] =
                                newValue;
                            _saveSizes();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
