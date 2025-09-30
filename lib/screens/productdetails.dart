import 'package:aishostatok/database/aishmanager.dart';
import 'package:aishostatok/database/models/currency.dart';
import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/database/models/product.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final MProduct product;

  const ProductDetails({super.key, required this.product});

  @override
  createState() => _ProductDetails();
}

class _PriceControllerModel {
  final priceForBuyController = TextEditingController();
  final priceForSaleController = TextEditingController();
  final priceForMinimumSaleController = TextEditingController();
  final priceForBuyFocusNode = FocusNode();
  final priceForSaleFocusNode = FocusNode();
  final priceForMinimumSaleFocusNode = FocusNode();
  final MCurrency currency;

  _PriceControllerModel({required this.currency});
}

class _ProductDetails extends State<ProductDetails> {
  MProduct _product = MProduct(json: {});
  final pricePercentOfSaleController = TextEditingController();
  final pricePercentOfMinimumSaleController = TextEditingController();
  final percentFocused = FocusNode();
  final percentMinimumFocused = FocusNode();
  final List<_PriceControllerModel> _priceControllerModels = [];
  double _defaultCurrencyRate = 1;
  MColor? _color;
  Future<List<MColor>>? _colors;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _colors = MColor.getAll();
    pricePercentOfSaleController.text = ((_product.json['price_base_for_sale'] /
                    _product.json['price_base_for_buying'] -
                1) *
            100)
        .toStringAsFixed(2);

    pricePercentOfSaleController.addListener(() {
      if (!percentFocused.hasFocus) return;
      final percent = double.tryParse(pricePercentOfSaleController.text);
      for (var e in _priceControllerModels) {
        e
            .priceForSaleController
            .text = ((double.tryParse(e.priceForBuyController.text) ?? 0) *
                ((percent ?? 0) + 100) /
                100)
            .toStringAsFixed(2);
      }
    });

    pricePercentOfMinimumSaleController.text = ((_product
                        .json['price_minimum_for_sale'] /
                    _product.json['price_base_for_buying'] -
                1) *
            100)
        .toStringAsFixed(2);

    pricePercentOfMinimumSaleController.addListener(() {
      if (!percentMinimumFocused.hasFocus) return;
      final percent = double.tryParse(pricePercentOfMinimumSaleController.text);
      for (var e in _priceControllerModels) {
        e
            .priceForMinimumSaleController
            .text = ((double.tryParse(e.priceForBuyController.text) ?? 0) *
                ((percent ?? 0) + 100) /
                100)
            .toStringAsFixed(2);
      }
    });

    MCurrency.getAllWithRate().then((value) {
      _defaultCurrencyRate =
          value
              .firstWhere((c) => c.json['_id'] == _product.json['currency'])
              .json['rate'];
      _priceControllerModels.addAll(
        value.map((e) {
          final model = _PriceControllerModel(currency: e);

          model.priceForBuyController.addListener(_buyingListener(model));
          model.priceForSaleController.addListener(_saleListener(model));
          model.priceForMinimumSaleController.addListener(
            _minimumSaleListener(model),
          );

          model.priceForBuyController.text = (_product
                      .json['price_base_for_buying'] /
                  _defaultCurrencyRate *
                  e.json['rate'])
              .toStringAsFixed(2);
          model.priceForSaleController.text = (_product
                      .json['price_base_for_sale'] /
                  _defaultCurrencyRate *
                  e.json['rate'])
              .toStringAsFixed(2);
          return model;
        }),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: _buildContainerTitle(context),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width - 20,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueAccent, width: 4),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Galyndy: ${_product.json['stock_in_main_measure']} ${_product.json['measureName']}",
                  ),
                  Text(
                    "Minimum galyndy: ${_product.json['instock_mainmeasure']} ${_product.json['measureName']}",
                  ),
                ],
              ),
              SizedBox(height: 8),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Alyş baha: ${_product.json['price_base_for_buying']} ${_product.json['currencyName']}\nSatyş baha: ${_product.json['price_base_for_sale']} ${_product.json['currencyName']}",
                ),
                trailing: Column(
                  children: [
                    Text(
                      "${widget.product.percentForSale.toStringAsFixed(2)} %",
                    ),
                    Text(
                      "${widget.product.percentForMinimumSale.toStringAsFixed(2)} %",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pricePercentOfSaleController,
                      focusNode: percentFocused,
                      decoration: InputDecoration(
                        labelText: "Satyş baha göterimi",
                        helper: Text(
                          "Kone satyş baha göterimi: ${widget.product.percentForSale.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),

                        suffix: Text('%', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: pricePercentOfMinimumSaleController,
                      focusNode: percentMinimumFocused,
                      decoration: InputDecoration(
                        labelText: "Minimum satyş baha göterimi",
                        helper: Text(
                          "Kone minimum satyş baha göterimi: ${widget.product.percentForMinimumSale.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),

                        suffix: Text('%', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ..._priceControllerModels.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: e.priceForBuyController,
                          focusNode: e.priceForBuyFocusNode,
                          decoration: InputDecoration(
                            labelText: "Alyş baha",
                            helper: Text(
                              "Kone alyş bahasy: ${(widget.product.json['price_base_for_buying'] / _defaultCurrencyRate * e.currency.json['rate']).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                            suffix: Text(
                              e.currency.json['name'].toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 26),
                      Expanded(
                        child: TextField(
                          controller: e.priceForSaleController,
                          focusNode: e.priceForSaleFocusNode,
                          decoration: InputDecoration(
                            labelText: "Satyş baha",
                            helper: Text(
                              "Kone satyş bahasy: ${(widget.product.json['price_base_for_sale'] / _defaultCurrencyRate * e.currency.json['rate']).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                            suffix: Text(
                              e.currency.name,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 26),
                      Expanded(
                        child: TextField(
                          controller: e.priceForMinimumSaleController,
                          focusNode: e.priceForMinimumSaleFocusNode,
                          decoration: InputDecoration(
                            labelText: "Minimum satyş baha",
                            helper: Text(
                              "Kone minimum satyş bahasy: ${(widget.product.json['price_minimum_for_sale'] / _defaultCurrencyRate * e.currency.json['rate']).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                            suffix: Text(
                              e.currency.name,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 26),
              ListTile(
                title: Text("Aýratyklyklar"),
                subtitle: Text(
                  "${_product.json['property_1']}\n${_product.json['property_2']}\n${_product.json['property_3']}\n${_product.json['property_4']}\n${_product.json['property_5']}",
                ),
              ),
              SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text("Goý Bolsun"),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              content: CircularProgressIndicator(),
                            ),
                        barrierDismissible: false,
                      );
                      try {
                        await AishManager().updateProduct(
                          id: _product.json['_id'],
                          priceForMinimumSale: 0,
                          priceForBuy: 0,
                          priceForSale: 0,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      } catch (e) {
                        debugPrint(e.toString());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Ýatda Sakla",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildContainerTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, bottom: 6, top: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _circleAvatar(),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _product.name,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAvatar() => FutureBuilder(
    future: _colors,
    builder: (context, snapshot) {
      final colors = snapshot.data ?? [];
      return DropdownButton<MColor>(
        onChanged: (value) async {
          await widget.product.changeColor(value);
          setState(() {
            _color = value;
          });
        },
        underline: SizedBox(),
        selectedItemBuilder: (context) => [SizedBox()],
        menuWidth: MediaQuery.of(context).size.width - 100,
        alignment: Alignment.bottomRight,
        items:
            colors
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
        icon: CircleAvatar(
          radius: 12,
          backgroundColor:
              _color != null
                  ? Color(
                    int.parse(
                      _color!.backgroundColor.substring(1, 9),
                      radix: 16,
                    ),
                  )
                  : _product.json['backgroundColor'] != null
                  ? Color(
                    int.parse(
                      _product.json['backgroundColor'].substring(1, 9),
                      radix: 16,
                    ),
                  )
                  : Colors.white,
          child: Text(
            _product.name[0],
            style: TextStyle(
              color:
                  _color != null
                      ? Color(
                        int.parse(_color!.fontColor.substring(1, 9), radix: 16),
                      )
                      : _product.json['fontColor'] != null
                      ? Color(
                        int.parse(
                          _product.json['fontColor'].substring(1, 9),
                          radix: 16,
                        ),
                      )
                      : Colors.grey,
            ),
          ),
        ),
      );
    },
  );

  VoidCallback _buyingListener(_PriceControllerModel model) => () {
    if (!model.priceForBuyFocusNode.hasFocus) return;
    final priceBuying = double.tryParse(model.priceForBuyController.text) ?? 0;
    for (var e in _priceControllerModels) {
      if (!e.priceForBuyFocusNode.hasFocus) {
        e.priceForBuyController.text = (priceBuying /
                model.currency.json['rate'] *
                e.currency.json['rate'])
            .toStringAsFixed(2);
      }
      e
          .priceForSaleController
          .text = ((double.tryParse(e.priceForBuyController.text) ?? 0) *
              ((double.tryParse(pricePercentOfSaleController.text) ?? 0) +
                  100) /
              100)
          .toStringAsFixed(2);

      e
          .priceForMinimumSaleController
          .text = ((double.tryParse(e.priceForBuyController.text) ?? 0) *
              ((double.tryParse(pricePercentOfMinimumSaleController.text) ??
                      0) +
                  100) /
              100)
          .toStringAsFixed(2);
    }
  };

  VoidCallback _saleListener(_PriceControllerModel model) => () {
    if (!model.priceForSaleFocusNode.hasFocus) return;
    final priceSale = double.tryParse(model.priceForSaleController.text) ?? 0;

    final percent =
        (((priceSale /
                    ((double.tryParse(model.priceForBuyController.text) ??
                        1))) -
                1) *
            100);
    for (var e in _priceControllerModels) {
      if (!e.priceForSaleFocusNode.hasFocus) {
        e
            .priceForSaleController
            .text = ((double.tryParse(e.priceForBuyController.text) ?? 0) *
                (percent + 100) /
                100)
            .toStringAsFixed(2);
      }
    }
    pricePercentOfSaleController.text = percent.toStringAsFixed(2);
  };
  VoidCallback _minimumSaleListener(_PriceControllerModel model) => () {
    if (!model.priceForMinimumSaleFocusNode.hasFocus) return;
    final priceSale =
        double.tryParse(model.priceForMinimumSaleController.text) ?? 0;

    final percent =
        (((priceSale /
                    ((double.tryParse(model.priceForBuyController.text) ??
                        1))) -
                1) *
            100);
    for (var e in _priceControllerModels) {
      if (!e.priceForMinimumSaleFocusNode.hasFocus) {
        e
            .priceForMinimumSaleController
            .text = ((double.tryParse(e.priceForBuyController.text) ?? 0) *
                (percent + 100) /
                100)
            .toStringAsFixed(2);
      }
    }
    pricePercentOfMinimumSaleController.text = percent.toStringAsFixed(2);
  };
}
