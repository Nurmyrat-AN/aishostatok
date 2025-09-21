String numberQuery({required String colName, required String? value}) {
  if(value==null || value.isEmpty){
    return '';
  }
  String stockQuery = "";
  final stockValues = value.split(",");
  if (stockValues.isNotEmpty) {}
  for (int i = 0; i < stockValues.length; i++) {
    final stockValue = stockValues[i];
    if (stockValue.contains("=<>=")) {
      final stocks = stockValue.split("=<>=");
      if (stocks.length == 2 && stocks[0].isNotEmpty && stocks[1].isNotEmpty) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName>=${stocks[0]} AND $colName<=${stocks[1]})";
      }
    } else if (stockValue.contains("=<")) {
      final stocks = stockValue.split("=<");
      if (stocks.length == 2 &&
          stocks[0].isNotEmpty &&
          double.tryParse(stocks[0]) != null) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName>=${stocks[0]})";
      }
    } else if (stockValue.contains(">=")) {
      final stocks = stockValue.split(">=");
      if (stocks.length == 2 &&
          stocks[0].isNotEmpty &&
          double.tryParse(stocks[0]) != null) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName<=${stocks[0]})";
      }
    } else if (stockValue.contains("<>")) {
      final stocks = stockValue.split("<>");
      if (stocks.length == 2 &&
          stocks[0].isNotEmpty &&
          double.tryParse(stocks[0]) != null &&
          stocks[1].isNotEmpty &&
          double.tryParse(stocks[1]) != null) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName>${stocks[0]} AND $colName<${stocks[1]})";
      }
    } else if (stockValue.contains("<")) {
      final stocks = stockValue.split("<");
      if (stocks.length == 2 &&
          stocks[0].isNotEmpty &&
          double.tryParse(stocks[0]) != null) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName>${stocks[0]})";
      }
    } else if (stockValue.contains(">")) {
      final stocks = stockValue.split(">");
      if (stocks.length == 2 &&
          stocks[0].isNotEmpty &&
          double.tryParse(stocks[0]) != null) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName<${stocks[0]})";
      }
    } else if (stockValue.contains("=")) {
      final stocks = stockValue.split("=");
      if (stocks.length == 2 &&
          stocks[0].isNotEmpty &&
          double.tryParse(stocks[0]) != null) {
        stockQuery =
            "${stockQuery == "" ? "" : "$stockQuery OR "}($colName=${stocks[0]})";
      }
    }
  }
  return stockQuery;
}
