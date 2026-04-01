enum AppCurrency {
  usd('USD', 2, '\$'),
  eur('EUR', 2, '€'),
  clp('CLP', 0, '\$'),
  ars('ARS', 2, '\$'),
  mxn('MXN', 2, '\$'),
  cop('COP', 0, '\$'),
  pen('PEN', 2, 'S/'),
  cny('CNY', 2, '¥');

  final String code;
  final int decimalPlaces; // 0 significa números enteros, 2 significa centavos
  final String symbol;

  const AppCurrency(this.code, this.decimalPlaces, this.symbol);

  // Funciones de ayuda
  double roundAmount(double amount) {
    if (decimalPlaces == 0) {
      return amount.roundToDouble();
    } else {
      // Truco simple en Dart para redondear a N decimales
      return double.parse(amount.toStringAsFixed(decimalPlaces));
    }
  }
}
