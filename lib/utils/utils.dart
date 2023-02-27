import 'package:intl/intl.dart';

String numberFormatFixed(num n, {int fixedDecimals = 2}) {
  final decimalPattern = "0" * fixedDecimals;
  final f = fixedDecimals == 0
      ? NumberFormat("#,##0")
      : NumberFormat("#,##0.$decimalPattern");
  return f.format(n);
}
