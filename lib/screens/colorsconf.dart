import 'package:aishostatok/database/models/mcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorsConfiguration extends StatefulWidget {
  final MColor? color;

  const ColorsConfiguration({super.key, this.color});

  @override
  State<StatefulWidget> createState() => _ColorsConfiguration();
}

class _ColorsConfiguration extends State<ColorsConfiguration> {
  MColor? color;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _property_1 = TextEditingController();
  final _property_2 = TextEditingController();
  final _property_3 = TextEditingController();
  final _property_4 = TextEditingController();
  final _property_5 = TextEditingController();
  String _backgroundColor = "#FFFFFFFF";
  String _fontColor = "#FF000000";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    color = widget.color;
    _nameController.text = color?.name ?? "";
    _property_1.text = color?.property_1 ?? "";
    _property_2.text = color?.property_2 ?? "";
    _property_3.text = color?.property_3 ?? "";
    _property_4.text = color?.property_4 ?? "";
    _property_5.text = color?.property_5 ?? "";
    _backgroundColor = color?.backgroundColor ?? "#FFFFFFFF";
    _fontColor = color?.fontColor ?? "#FF000000";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(color == null ? "Täze reňk döret" : "Reňki üýtget"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: "Ady"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Adyny giriziň';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildColors(context, color),
                      SizedBox(height: 16),
                      ExpansionTile(
                        title: Text("Aýratynlyklar"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        childrenPadding: EdgeInsets.all(8),
                        children: [
                          TextFormField(
                            controller: _property_1,
                            decoration: InputDecoration(
                              labelText: "Aýratynlyk 1",
                            ),
                            validator: emptyValidator,
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _property_2,
                            decoration: InputDecoration(
                              labelText: "Aýratynlyk 2",
                            ),
                            validator: emptyValidator,
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _property_3,
                            decoration: InputDecoration(
                              labelText: "Aýratynlyk 3",
                            ),
                            validator: emptyValidator,
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _property_4,
                            decoration: InputDecoration(
                              labelText: "Aýratynlyk 4",
                            ),
                            validator: emptyValidator,
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _property_5,
                            decoration: InputDecoration(
                              labelText: "Aýratynlyk 5",
                            ),
                            validator: emptyValidator,
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Goý Bolsun"),
        ),
        TextButton(
          onPressed: () => _saveColor(context),
          child: Text("Ýatda Sakla"),
        ),
      ],
    );
  }

  String? emptyValidator(value) {
    return null;
  }

  void _saveColor(BuildContext context) async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final newColor = widget.color ?? MColor(json: {});
    newColor.json['name'] = _nameController.text;
    newColor.json['property_1'] = _property_1.text;
    newColor.json['property_2'] = _property_2.text;
    newColor.json['property_3'] = _property_3.text;
    newColor.json['property_4'] = _property_4.text;
    newColor.json['property_5'] = _property_5.text;
    newColor.json['backgroundColor'] = _backgroundColor;
    newColor.json['fontColor'] = _fontColor;
    try {
      await newColor.save();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reňk üstünlikli ýatda saklandy"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, [true]);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reňk ýatda saklama näsazlygy: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildColors(BuildContext context, MColor? color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Hatyň reňki"),
              ElevatedButton(
                onPressed: () async {
                  final newColor = await _showColorPickerDialog(
                    context,
                    initialColor: Color(
                      int.parse(_fontColor.substring(1, 9), radix: 16),
                    ),
                  );
                  if (newColor != null) {
                    setState(() {
                      _fontColor = "#${newColor.toHexString()}";
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Color(
                        int.parse(_fontColor.substring(1, 9), radix: 16),
                      ),
                      width: 4,
                    ),

                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _fontColor,
                  style: TextStyle(
                    color: Color(
                      int.parse(_fontColor.substring(1, 9), radix: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Arka fonyň reňki"),
              ElevatedButton(
                onPressed: () async {
                  final newColor = await _showColorPickerDialog(
                    context,
                    initialColor: Color(
                      int.parse(_backgroundColor.substring(1, 9), radix: 16),
                    ),
                  );
                  if (newColor != null) {
                    setState(() {
                      _backgroundColor = "#${newColor.toHexString()}";
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Color(
                        int.parse(_backgroundColor.substring(1, 9), radix: 16),
                      ),
                      width: 4,
                    ),

                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _backgroundColor,
                  style: TextStyle(
                    color: Color(
                      int.parse(_backgroundColor.substring(1, 9), radix: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Color?> _showColorPickerDialog(
    BuildContext context, {
    required Color initialColor,
  }) async {
    Color tempColor = initialColor;

    return showDialog<Color?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reňk saýlaň'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Виджет палитры (Palette)
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    tempColor = color;
                  },
                  colorPickerWidth: 300.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: true,
                  displayThumbColor: true,
                  paletteType: PaletteType.hslWithLightness,
                  labelTypes: const [],
                  pickerAreaBorderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2.0),
                    topRight: Radius.circular(2.0),
                  ),
                ),
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    tempColor = color;
                  },
                  enableAlpha: true,
                  displayThumbColor: false,
                  labelTypes: const [ColorLabelType.hex],
                  pickerAreaBorderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(2.0),
                    bottomRight: Radius.circular(2.0),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Goý Bolsun'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              child: const Text('Saýla'),
              onPressed: () {
                Navigator.of(dialogContext).pop(tempColor);
              },
            ),
          ],
        );
      },
    );
  }
}
