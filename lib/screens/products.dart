import 'package:aishostatok/database/aishmanager.dart';
import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/database/models/measure.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:aishostatok/database/models/warehouse.dart';
import 'package:aishostatok/screens/colorslist.dart';
import 'package:aishostatok/screens/currencies.dart';
import 'package:aishostatok/screens/loadingprogress.dart';
import 'package:aishostatok/screens/print.dart';
import 'package:aishostatok/screens/productdetails.dart';
import 'package:aishostatok/screens/serverip.dart';
import 'package:aishostatok/utils/export.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'filterproducts.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProductsScreen();
}

class _ProductsScreen extends State<ProductsScreen> {
  Future<String?> lastUpdatedAt = AishManager().lastUpdatedAt;
  Future<List<MProduct>> productsFuture = MProduct.getAll();
  Future<List<MColor>> _colorsFuture = MColor.getAll();
  final _searchController = TextEditingController();
  final _barcodeController = TextEditingController();
  List<String>? selectedProducts;
  String? _orderBy = "name";
  MMeasure? _measure;
  MWarehouse? _warehouse;
  MCurrency? _currency;
  MColor? _color;
  String? _property_1;
  String? _property_2;
  String? _property_3;
  String? _property_4;
  String? _property_5;
  String? _stock;
  String? _minStock;
  List<MProduct> _products = [];

  @override
  initState() {
    super.initState();
    _searchController.addListener(_fetchProducts);
    _barcodeController.addListener(_fetchProducts);
  }

  @override
  dispose() {
    super.dispose();
    _searchController.dispose();
    _barcodeController.dispose();
  }

  _fetchProducts() {
    setState(() {
      _colorsFuture = MColor.getAll();
      _products = [];
      productsFuture = MProduct.getAll(
        query: _searchController.text,
        barcode: _barcodeController.text,
        orderBy: _orderBy,
        measureId: _measure?.json['_id'],
        warehouseId: _warehouse?.json['_id'],
        currencyId: _currency?.json['_id'],
        // property_1: _color != null ? _color!.property_1 : _property_1,
        // property_2: _color != null ? _color!.property_2 : _property_2,
        // property_3: _color != null ? _color!.property_3 : _property_3,
        // property_4: _color != null ? _color!.property_4 : _property_4,
        // property_5: _color != null ? _color!.property_5 : _property_5,
        stock: _stock,
        minStock: _minStock,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: _buildSpeedDial(context),
      body: _buildBody(),
    );
  }

  Padding _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          prefixIcon: PopupMenuButton(
                            itemBuilder:
                                (context) =>
                                    MProduct.orderByOptions
                                        .map<PopupMenuItem<String>>(
                                          (e) => PopupMenuItem(
                                            value: e['value'],
                                            child: Text(e['label']!),
                                          ),
                                        )
                                        .toList(),
                            onSelected: (value) {
                              setState(() {
                                _orderBy = value;
                              });
                              _fetchProducts();
                            },
                            child: Icon(Icons.sort),
                          ),
                          label: Text("Ştrihkod"),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Gözleg",
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FilterProducts(
                            currency: _currency,
                            warehouse: _warehouse,
                            measure: _measure,
                            color: _color,
                            property_1: _property_1,
                            property_2: _property_2,
                            property_3: _property_3,
                            property_4: _property_4,
                            property_5: _property_5,
                            stock: _stock,
                            minStock: _minStock,
                          ),
                    ),
                  );
                  if (result != null) {
                    final Map<String, dynamic> filter = result[0];
                    setState(() {
                      _measure =
                          filter['measure'] != null
                              ? MMeasure(json: filter['measure'])
                              : null;
                      _warehouse =
                          filter['warehouse'] != null
                              ? MWarehouse(json: filter['warehouse'])
                              : null;
                      _currency =
                          filter['currency'] != null
                              ? MCurrency(json: filter['currency'])
                              : null;
                      _color =
                          filter['color'] != null
                              ? MColor(json: filter['color'])
                              : null;
                      _property_1 = filter['property_1'];
                      _property_2 = filter['property_2'];
                      _property_3 = filter['property_3'];
                      _property_4 = filter['property_4'];
                      _property_5 = filter['property_5'];
                      _stock = filter['stock'];
                      _minStock = filter['minStock'];
                    });
                    _fetchProducts();
                  }
                },
                icon: Icon(Icons.filter_alt_outlined),
              ),
            ],
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_warehouse != null ||
                    _measure != null ||
                    _currency != null ||
                    _color != null ||
                    _property_1 != null ||
                    _property_2 != null ||
                    _property_3 != null ||
                    _property_4 != null ||
                    _property_5 != null ||
                    _stock != null ||
                    _minStock != null)
                  _buildFilterContainer(
                    label: "Gözleg",
                    onClear: () {
                      setState(() {
                        _warehouse = null;
                        _measure = null;
                        _currency = null;
                        _color = null;
                        _property_1 = null;
                        _property_2 = null;
                        _property_3 = null;
                        _property_4 = null;
                        _property_5 = null;
                        _stock = null;
                        _minStock = null;
                      });
                      _fetchProducts();
                    },
                  ),
                if (_property_1 != null ||
                    _property_2 != null ||
                    _property_3 != null ||
                    _property_4 != null ||
                    _property_5 != null)
                  _buildFilterContainer(
                    label:
                        "Aýratynlyklar: ${_property_1 ?? ""}, ${_property_2 ?? ""}, ${_property_3 ?? ""}, ${_property_4 ?? ""}, ${_property_5 ?? ""}",
                    onClear: () {
                      setState(() {
                        _property_1 = null;
                        _property_2 = null;
                        _property_3 = null;
                        _property_4 = null;
                        _property_5 = null;
                      });
                      _fetchProducts();
                    },
                  ),
                if (_warehouse != null)
                  _buildFilterContainer(
                    label: "Ammar: ${_warehouse!.name}",
                    onClear: () {
                      setState(() {
                        _warehouse = null;
                      });
                      _fetchProducts();
                    },
                  ),
                if (_measure != null)
                  _buildFilterContainer(
                    label: "Ölçeg: ${_measure!.name}",
                    onClear: () {
                      setState(() {
                        _measure = null;
                      });
                      _fetchProducts();
                    },
                  ),
                if (_currency != null)
                  _buildFilterContainer(
                    label: "Walýuta: ${_currency!.name}",
                    onClear: () {
                      setState(() {
                        _currency = null;
                      });
                      _fetchProducts();
                    },
                  ),
                if (_color != null)
                  _buildFilterContainer(
                    label: "Color: ${_color!.name}",
                    onClear: () {
                      setState(() {
                        _color = null;
                      });
                      _fetchProducts();
                    },
                    backgroundColor: _color!.json['backgroundColor'],
                    fontColor: _color!.json['fontColor'],
                  ),
                if (_stock != null)
                  _buildFilterContainer(
                    label: "Galyndy: ${_stock!}",
                    onClear: () {
                      setState(() {
                        _stock = null;
                      });
                      _fetchProducts();
                    },
                  ),
                if (_minStock != null)
                  _buildFilterContainer(
                    label: "Minimum Galyndy: ${_minStock!}",
                    onClear: () {
                      setState(() {
                        _minStock = null;
                      });
                      _fetchProducts();
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: InkWell(
                      onTap: _fetchProducts,
                      child: Text("Näsazlyk: ${snapshot.error}"),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Maglumat ýok"));
                }
                _products = snapshot.data! ?? [];
                return RefreshIndicator(
                  onRefresh: () async => _fetchProducts(),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];

                      return ListTile(
                        onTap: () async {
                          if (selectedProducts != null) {
                            if (selectedProducts!.contains(
                              product.json['_id'],
                            )) {
                              selectedProducts!.remove(product.json['_id']);
                            } else {
                              selectedProducts!.add(product.json['_id']);
                            }
                            setState(() {});
                            return;
                          }
                          await showDialog(
                            context: context,
                            builder:
                                (context) => ProductDetails(product: product),
                          );
                          final pr = await MProduct.getById(
                            product.json['_id'],
                          );

                          product.json.addAll({...pr.json});
                          setState(() {});
                        },
                        onLongPress: () {
                          selectedProducts ??= [product.json['_id']];
                          setState(() {});
                        },
                        leading: FutureBuilder(
                          future: _colorsFuture,
                          builder: (context, snapshot) {
                            final colors = snapshot.data ?? [];
                            return DropdownButton<MColor>(
                              onChanged: (value) async {
                                await product.changeColor(value);
                                setState(() {});
                              },
                              underline: SizedBox(),
                              selectedItemBuilder: (context) => [SizedBox()],
                              menuWidth:
                                  MediaQuery.of(context).size.width - 100,
                              alignment: Alignment.bottomRight,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    "Reňki arassala",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                ...colors.map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                ),
                              ],
                              icon: CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    _color != null
                                        ? Color(
                                          int.parse(
                                            _color!.backgroundColor.substring(
                                              1,
                                              9,
                                            ),
                                            radix: 16,
                                          ),
                                        )
                                        : product.json['backgroundColor'] !=
                                            null
                                        ? Color(
                                          int.parse(
                                            product.json['backgroundColor']
                                                .substring(1, 9),
                                            radix: 16,
                                          ),
                                        )
                                        : Colors.white,
                                child: Text(
                                  product.name[0],
                                  style: TextStyle(
                                    color:
                                        _color != null
                                            ? Color(
                                              int.parse(
                                                _color!.fontColor.substring(
                                                  1,
                                                  9,
                                                ),
                                                radix: 16,
                                              ),
                                            )
                                            : product.json['fontColor'] != null
                                            ? Color(
                                              int.parse(
                                                product.json['fontColor']
                                                    .substring(1, 9),
                                                radix: 16,
                                              ),
                                            )
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        trailing:
                            selectedProducts != null
                                ? Checkbox(
                                  value: selectedProducts!.contains(
                                    product.json['_id'],
                                  ),
                                  onChanged: (value) {
                                    if (selectedProducts!.contains(
                                      product.json['_id'],
                                    )) {
                                      selectedProducts!.remove(
                                        product.json['_id'],
                                      );
                                    } else {
                                      selectedProducts!.add(
                                        product.json['_id'],
                                      );
                                    }
                                    setState(() {});
                                  },
                                )
                                : null,
                        title: Text(product.name),
                        subtitle: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                style: TextStyle(color: Colors.black54),
                                text:
                                    "${product.json['price_base_for_sale']} ${product.json['currencyName']}\n ${product.json['stock_in_main_measure']} ${product.json['measureName']}   ",
                              ),
                              TextSpan(
                                style: TextStyle(
                                  color:
                                      product.json['difference_in_main_measure'] <
                                              0
                                          ? Colors.red
                                          : product
                                                  .json['difference_in_main_measure'] ==
                                              0
                                          ? Colors.deepOrange
                                          : Colors.black54,
                                ),
                                text:
                                    '${product.json['difference_in_main_measure']} ${product.json['measureName']}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 32),
          FutureBuilder(
            future: lastUpdatedAt,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Näsazlyk: ${snapshot.error}");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Text(
                  "Soňky täzelenen senesi: ${snapshot.hasData ? DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(snapshot.data!)) : "---"}",
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _buildFilterContainer({
    required String label,
    required void Function() onClear,
    String? backgroundColor,
    String? fontColor,
  }) => Container(
    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    margin: EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(16),
      color:
          backgroundColor != null
              ? Color(int.parse(backgroundColor.substring(1, 9), radix: 16))
              : null,
    ),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                fontColor != null
                    ? Color(int.parse(fontColor.substring(1, 9), radix: 16))
                    : null,
          ),
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: onClear,
          child: Icon(
            Icons.cancel_outlined,
            size: 16,
            color:
                fontColor != null
                    ? Color(int.parse(fontColor.substring(1, 9), radix: 16))
                    : null,
          ),
        ),
      ],
    ),
  );

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Harytlar"),
      actions: [
        if (selectedProducts != null && selectedProducts!.isNotEmpty)
          FutureBuilder(
            future: _colorsFuture,
            builder: (context, snapshot) {
              final colors = snapshot.data ?? [];
              return DropdownButton<MColor>(
                onChanged: (value) async {
                  if (selectedProducts == null || selectedProducts!.isEmpty) {
                    return;
                  }
                  await MProduct.changeColorMultiple(
                    products:
                        selectedProducts!.map<MProduct>((e) {
                          MProduct product = _products.firstWhere(
                            (element) => element.json['_id'] == e,
                            orElse: () => MProduct(json: {"_id": e}),
                          );

                          return product;
                        }).toList(),
                    color: value,
                  );

                  setState(() {});
                },
                underline: SizedBox(),
                selectedItemBuilder: (context) => [SizedBox()],
                menuWidth: MediaQuery.of(context).size.width - 100,
                alignment: Alignment.bottomRight,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      "Reňki arassala",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ...colors.map(
                    (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                  ),
                ],
                icon: Icon(Icons.colorize),
              );
            },
          ),
        if (selectedProducts != null && selectedProducts!.isNotEmpty)
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PrintScreen(selectedProducts: selectedProducts!),
                ),
              );
            },
            icon: Icon(Icons.print_outlined),
          ),
        if (selectedProducts != null)
          DropdownButton(
            items: [
              DropdownMenuItem(
                value: 'selectall',
                child: Text("Ählisini saýla"),
              ),
              DropdownMenuItem(value: 'clearall', child: Text("Arassala")),
              DropdownMenuItem(value: 'reverse', child: Text("Tersini saýla")),
            ],
            underline: SizedBox(),
            menuWidth: 120,
            selectedItemBuilder: (context) => [SizedBox()],
            onChanged: (value) {
              switch (value) {
                case 'selectall':
                  setState(() {
                    selectedProducts =
                        _products.map<String>((e) => e.json['_id']).toList();
                  });
                  break;
                case 'clearall':
                  setState(() {
                    selectedProducts = null;
                  });
                  break;
                case 'reverse':
                  setState(() {
                    selectedProducts =
                        _products
                            .map<String>((e) => e.json['_id'])
                            .where(
                              (element) => !selectedProducts!.contains(element),
                            )
                            .toList();
                  });

                  break;
              }
            },
            icon: Icon(Icons.check_box_outlined),
          ),
        IconButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: SizedBox(
                      width: 300,
                      height: 300,
                      child: MobileScanner(
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty) {
                            _barcodeController.text =
                                barcodes.first.rawValue.toString();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
            );
          },
          icon: Icon(Icons.qr_code_scanner),
        ),
      ],
    );
  }

  SpeedDial _buildSpeedDial(BuildContext context) {
    return SpeedDial(
      icon: Icons.menu,
      activeIcon: Icons.close,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      // Анимация выкручивания
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeInOut,
      direction: SpeedDialDirection.up,
      // mini: true,
      // Настройка меню
      children: [
        SpeedDialChild(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Täzele',
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => LoadingProgress(),
            );
            setState(() {
              lastUpdatedAt = AishManager().lastUpdatedAt;
            });
            _fetchProducts();
          },
          child: Icon(Icons.refresh),
        ),
        SpeedDialChild(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Sazlamalar',
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => ServerIPConfiguration(),
            );
            _fetchProducts();
          },
          child: Icon(Icons.settings),
        ),
        SpeedDialChild(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          label: 'Reňkler',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ColorsList()),
              ),
          child: Icon(Icons.color_lens),
        ),
        SpeedDialChild(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'Walýutalar',
          onTap:
              () => showDialog(
                context: context,
                builder: (context) => CurrenciesConf(),
              ),
          child: Icon(Icons.attach_money_outlined),
        ),
        SpeedDialChild(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Export Excel',
          onTap: () async {
            showDialog(
              context: context,
              builder:
                  (context) =>
                      AlertDialog(content: CircularProgressIndicator()),
              barrierDismissible: false,
            );

            try {
              await exportProductsToExcel(
                context: context,
                products: _products,
              );
            } catch (e) {
              debugPrint(e.toString());
              rethrow;
            }

            Navigator.pop(context);
          },
          child: Icon(Icons.file_download),
        ),
      ],
    );
  }
}
