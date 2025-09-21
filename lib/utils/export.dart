import 'dart:io';

import 'package:aishostatok/database/models/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as Excel;

exportProductsToExcel({
  required BuildContext context,
  required List<MProduct> products,
}) async {
  if (products.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Нет данных для экспорта.')));
  }

  // 1. Проверка разрешений на хранение (только для Android)
  if (Platform.isAndroid) {
    var status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      print('Доступ к хранилищу не предоставлен.');
      return;
    }
  }

  try {
    // 2. Создание Excel-документа
    var excel = Excel.Excel.createExcel();
    var sheet = excel.sheets.values.first;

    sheet.appendRow([
      Excel.TextCellValue('Ady'),
      Excel.TextCellValue('Kody'),
      Excel.TextCellValue('Alys Baha'),
      Excel.TextCellValue('Satys Baha'),
      Excel.TextCellValue('Pul'),
      Excel.TextCellValue('Galyndy'),
      Excel.TextCellValue('Azyndan Bolmaly Galyndy'),
      Excel.TextCellValue('Galyndy Tapawudy'),
      Excel.TextCellValue('Ölçegi'),
      Excel.TextCellValue('Aýratynlyklary'),
    ]);

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final cells = [
        sheet.cell(Excel.CellIndex.indexByString('A${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('B${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('C${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('D${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('E${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('F${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('G${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('H${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('I${i + 2}')),
        sheet.cell(Excel.CellIndex.indexByString('J${i + 2}')),
      ];
      cells[0].value = Excel.TextCellValue(product.name);
      cells[1].value = Excel.TextCellValue(product.json['code'].toString());
      cells[2].value = Excel.DoubleCellValue(
        product.json['price_base_for_buying'],
      );
      cells[3].value = Excel.DoubleCellValue(
        product.json['price_base_for_sale'],
      );
      cells[4].value = Excel.TextCellValue(product.json['currencyName']);
      cells[5].value = Excel.DoubleCellValue(
        product.json['stock_in_main_measure'],
      );
      cells[6].value = Excel.DoubleCellValue(
        product.json['instock_mainmeasure'],
      );
      cells[7].value = Excel.DoubleCellValue(
        product.json['difference_in_main_measure'],
      );
      cells[8].value = Excel.TextCellValue(product.json['measureName']);
      cells[9].value = Excel.TextCellValue(
        "${product.json['property_1']}; ${product.json['property_2']}; ${product.json['property_3']}; ${product.json['property_4']}; ${product.json['property_5']}",
      );
      for (var cell in cells) {
        if (product.json['backgroundColor'] != null &&
            product.json['fontColor'] != null) {
          cell.cellStyle = Excel.CellStyle(
            backgroundColorHex: Excel.ExcelColor.fromHexString(
              product.json['backgroundColor'],
            ),
            fontColorHex: Excel.ExcelColor.fromHexString(
              product.json['fontColor'],
            ),
          );
        }
      }
    }

    // 5. Преобразование Excel-документа в байты
    final fileBytes = excel.encode();

    if (fileBytes == null) {
      print('Ошибка при кодировании файла.');
      return;
    }

    // 6. Вызов диалога сохранения
    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Excel faýla ýazdyrmak',
      fileName: 'Harytlaryň sanawy.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      initialDirectory: '/storage/emulated/0/Download',
      bytes: Uint8List.fromList(fileBytes),
    );

    if (outputFilePath == null) {
      // Пользователь отменил сохранение
      print('Сохранение отменено.');
      return;
    }

    // 7. Сохранение файла по выбранному пути
    final file = File(outputFilePath);
    await file.writeAsBytes(fileBytes);

    print('Файл успешно сохранён: $outputFilePath');

    // 8. (Опционально) Показать пользователю, что файл сохранён
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Üstünlikli ýatda saklanyldy'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  }
}
