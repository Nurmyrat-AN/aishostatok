import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/database/models/measure.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:aishostatok/database/models/warehouse.dart';
import 'package:aishostatok/utils/query.dart';
import 'package:flutter/material.dart';

class FilterProducts extends StatefulWidget {
  final MCurrency? currency;
  final MWarehouse? warehouse;
  final MMeasure? measure;
  final MColor? color;
  final String? property_1;
  final String? property_2;
  final String? property_3;
  final String? property_4;
  final String? property_5;
  final String? stock;
  final String? minStock;

  const FilterProducts({
    super.key,
    this.currency,
    this.warehouse,
    this.measure,
    this.color,
    this.property_1,
    this.property_2,
    this.property_3,
    this.property_4,
    this.property_5,
    this.stock,
    this.minStock,
  });

  @override
  State<StatefulWidget> createState() => _FilterProducts();
}

class _FilterProducts extends State<FilterProducts> {
  final _currencyController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _measureController = TextEditingController();
  final _colorController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();

  Future<List<MCurrency>>? _currencies;
  MCurrency? _selectedCurrency;
  Future<List<MWarehouse>>? _warehouse;
  MWarehouse? _selectedWarehouse;
  Future<List<MMeasure>>? _measures;
  MMeasure? _selectedMeasure;
  Future<List<MColor>>? _colors;
  MColor? _selectedColor;
  Future<List<String>>? _properties_1;
  String? _selectedProperty_1;
  Future<List<String>>? _properties_2;
  String? _selectedProperty_2;
  Future<List<String>>? _properties_3;
  String? _selectedProperty_3;
  Future<List<String>>? _properties_4;
  String? _selectedProperty_4;
  Future<List<String>>? _properties_5;
  String? _selectedProperty_5;

  @override
  initState() {
    super.initState();
    _selectedCurrency = widget.currency;
    _selectedWarehouse = widget.warehouse;
    _selectedMeasure = widget.measure;
    _selectedColor = widget.color;
    _selectedProperty_1 = widget.property_1;
    _selectedProperty_2 = widget.property_2;
    _selectedProperty_3 = widget.property_3;
    _selectedProperty_4 = widget.property_4;
    _selectedProperty_5 = widget.property_5;
    _stockController.text = widget.stock ?? "";
    _minStockController.text = widget.minStock ?? "";

    if (_selectedCurrency != null) {
      _currencyController.text = _selectedCurrency!.name;
    }
    if (_selectedWarehouse != null) {
      _warehouseController.text = _selectedWarehouse!.name;
    }
    if (_selectedMeasure != null) {
      _measureController.text = _selectedMeasure!.name;
    }
    if (_selectedColor != null) {
      _colorController.text = _selectedColor!.name;
    }

    _currencies = MCurrency.getAll();
    _measures = MMeasure.getAll();
    _colors = MColor.getAll();
    _warehouse = MWarehouse.getAll();
    _properties_1 = MProduct.getProperties1();
    _properties_2 = MProduct.getProperties2();
    _properties_3 = MProduct.getProperties3();
    _properties_4 = MProduct.getProperties4();
    _properties_5 = MProduct.getProperties5();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gözleg"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, [
                {"currency": null},
              ]);
            },
            icon: Icon(Icons.clear_sharp, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
                    TextField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: "Galyndy",
                        border: OutlineInputBorder(),
                        helperText: "10<,15<>50,20>,5=<,50=<>=60,12=,30>=",
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _minStockController,
                      decoration: InputDecoration(
                        labelText: "Minimum bn galyndynyň tapawudy",
                        border: OutlineInputBorder(),
                        helperText: "10<,15<>50,20>,5=<,50=<>=60,12=,30>=",
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildFutureBuilderWarehouse(),
                    SizedBox(height: 16),
                    _buildFutureBuilderCurrency(),
                    SizedBox(height: 16),
                    _buildFutureBuilderMeasure(),
                    SizedBox(height: 16),
                    _buildFutureBuilderColors(),
                    SizedBox(height: 16),
                    _buildFutureBuilderProperties(
                      label: "Aýratynlyk 1",
                      propertiesFuture: _properties_1,
                      value: _selectedProperty_1,
                      onSelect: (String? value) {
                        setState(() {
                          _selectedProperty_1 = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildFutureBuilderProperties(
                      label: "Aýratynlyk 2",
                      propertiesFuture: _properties_2,
                      value: _selectedProperty_2,
                      onSelect: (String? value) {
                        setState(() {
                          _selectedProperty_2 = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildFutureBuilderProperties(
                      label: "Aýratynlyk 3",
                      propertiesFuture: _properties_3,
                      value: _selectedProperty_3,
                      onSelect: (String? value) {
                        setState(() {
                          _selectedProperty_3 = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildFutureBuilderProperties(
                      label: "Aýratynlyk 4",
                      propertiesFuture: _properties_4,
                      value: _selectedProperty_4,
                      onSelect: (String? value) {
                        setState(() {
                          _selectedProperty_4 = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildFutureBuilderProperties(
                      label: "Aýratynlyk 5",
                      propertiesFuture: _properties_5,
                      value: _selectedProperty_5,
                      onSelect: (String? value) {
                        setState(() {
                          _selectedProperty_5 = value;
                        });
                      },
                    ),
                    SizedBox(height: 160),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, [
                    {
                      "currency": _selectedCurrency?.json,
                      "measure": _selectedMeasure?.json,
                      "color": _selectedColor?.json,
                      "warehouse": _selectedWarehouse?.json,
                      "property_1": _selectedProperty_1,
                      "property_2": _selectedProperty_2,
                      "property_3": _selectedProperty_3,
                      "property_4": _selectedProperty_4,
                      "property_5": _selectedProperty_5,
                      "stock":
                          _stockController.text.isNotEmpty
                              ? _stockController.text
                              : null,
                      "minStock":
                          _minStockController.text.isNotEmpty
                              ? _minStockController.text
                              : null,
                    },
                  ]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text("Gözle"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<String>> _buildFutureBuilderProperties({
    required String label,
    Future<List<String>>? propertiesFuture,
    String? value,
    required void Function(String? value) onSelect,
  }) => FutureBuilder(
    future: propertiesFuture,
    builder: (context, snapshot) {
      final properties = snapshot.data ?? [];
      final textEditingController = TextEditingController(text: value ?? "");
      final focusNode = FocusNode();
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          final selectedProperty = properties.where(
            (property) => property.toLowerCase().contains(
              textEditingController.text.toLowerCase(),
            ),
          );
          if (selectedProperty.isNotEmpty) {
            textEditingController.text = selectedProperty.first;
            onSelect(selectedProperty.first);
          } else {
            onSelect(null);
            textEditingController.text = "";
          }
        }
      });
      return RawAutocomplete(
        textEditingController: textEditingController,
        focusNode: focusNode,
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) =>
                TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (value) {
                    final selectedProperty = properties.where(
                      (property) =>
                          property.toLowerCase().contains(value.toLowerCase()),
                    );
                    if (selectedProperty.isNotEmpty) {
                      textEditingController.text = selectedProperty.first;
                      onSelect(selectedProperty.first);
                    } else {
                      onSelect(null);
                      textEditingController.text = "";
                    }
                  },
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(),
                    suffixIcon:
                        _selectedProperty_1 == null
                            ? null
                            : InkWell(
                              child: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 16,
                              ),
                              onTap: () {
                                onSelect(null);
                                textEditingController.text = "";
                              },
                            ),
                  ),
                ),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return properties;
          }
          return properties.where(
            (property) => property.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            ),
          );
        },
        onSelected: onSelect,
        optionsViewBuilder: (context, onSelected, options) {
          return Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 200,
                  maxWidth: MediaQuery.of(context).size.width - 36,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  FutureBuilder<List<MColor>> _buildFutureBuilderColors() {
    return FutureBuilder(
      future: _colors,
      builder: (context, snapshot) {
        final colors = snapshot.data ?? [];
        return DropdownMenu(
          initialSelection: _selectedColor,
          enableSearch: true,
          width: MediaQuery.of(context).size.width - 36,
          enableFilter: true,
          leadingIcon:
              _selectedColor == null
                  ? null
                  : InkWell(
                    child: Icon(Icons.clear, color: Colors.grey, size: 16),
                    onTap: () {
                      setState(() {
                        _selectedColor = null;
                        _colorController.text = "";
                      });
                    },
                  ),
          onSelected: (value) {
            setState(() {
              _selectedColor = value;
            });
          },
          controller: _colorController,
          label: Text("Reňk"),
          dropdownMenuEntries:
              colors
                  .map((e) => DropdownMenuEntry(value: e, label: e.name))
                  .toList(),
        );
      },
    );
  }

  FutureBuilder<List<MMeasure>> _buildFutureBuilderMeasure() {
    return FutureBuilder(
      future: _measures,
      builder: (context, snapshot) {
        final measures = snapshot.data ?? [];
        return DropdownMenu(
          initialSelection: _selectedMeasure,
          enableSearch: true,
          width: MediaQuery.of(context).size.width - 36,
          enableFilter: true,
          leadingIcon:
              _selectedMeasure == null
                  ? null
                  : InkWell(
                    child: Icon(Icons.clear, color: Colors.grey, size: 16),
                    onTap: () {
                      setState(() {
                        _selectedMeasure = null;
                        _measureController.text = "";
                      });
                    },
                  ),
          onSelected: (value) {
            setState(() {
              _selectedMeasure = value;
            });
          },
          controller: _measureController,
          label: Text("Ölçeg"),
          dropdownMenuEntries:
              measures
                  .map((e) => DropdownMenuEntry(value: e, label: e.name))
                  .toList(),
        );
      },
    );
  }

  FutureBuilder<List<MCurrency>> _buildFutureBuilderCurrency() {
    return FutureBuilder(
      future: _currencies,
      builder: (context, snapshot) {
        final currencies = snapshot.data ?? [];
        return DropdownMenu(
          initialSelection: _selectedCurrency,
          enableSearch: true,
          width: MediaQuery.of(context).size.width - 36,
          enableFilter: true,
          leadingIcon:
              _selectedCurrency == null
                  ? null
                  : InkWell(
                    child: Icon(Icons.clear, color: Colors.grey, size: 16),
                    onTap: () {
                      setState(() {
                        _selectedCurrency = null;
                        _currencyController.text = "";
                      });
                    },
                  ),
          controller: _currencyController,
          onSelected: (value) {
            setState(() {
              _selectedCurrency = value;
            });
          },
          label: Text("Walýuta"),
          dropdownMenuEntries:
              currencies
                  .map((e) => DropdownMenuEntry(value: e, label: e.name))
                  .toList(),
        );
      },
    );
  }

  FutureBuilder<List<MWarehouse>> _buildFutureBuilderWarehouse() {
    return FutureBuilder(
      future: _warehouse,
      builder: (context, snapshot) {
        final warehouses = snapshot.data ?? [];
        return DropdownMenu(
          initialSelection: _selectedWarehouse,
          enableSearch: true,
          width: MediaQuery.of(context).size.width - 36,
          enableFilter: true,
          leadingIcon:
              _selectedWarehouse == null
                  ? null
                  : InkWell(
                    child: Icon(Icons.clear, color: Colors.grey, size: 16),
                    onTap: () {
                      setState(() {
                        _selectedWarehouse = null;
                        _warehouseController.text = "";
                      });
                    },
                  ),
          controller: _warehouseController,
          onSelected: (value) {
            setState(() {
              _selectedWarehouse = value;
            });
          },
          label: Text("Ammar"),
          dropdownMenuEntries:
              warehouses
                  .map((e) => DropdownMenuEntry(value: e, label: e.name))
                  .toList(),
        );
      },
    );
  }
}
