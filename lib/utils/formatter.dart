import 'package:intl/intl.dart';

String formatNumber(num number, String locale) {
  final formatter = NumberFormat.decimalPattern(locale);
  return formatter.format(number);
}

double parseNumber(String input, String locale) {
  final format = NumberFormat.decimalPattern(locale);
  return format.parse(input).toDouble();
}

bool isStringValidNum(String input) {
  return input.startsWith(RegExp(r'-?[0-9]'));
}
