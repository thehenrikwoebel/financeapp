import 'package:intl/intl.dart';
import 'dart:math' as math;

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

double niceInterval(double rawInterval) {
  if (rawInterval <= 0) return 1.0;

  final exponent = (math.log(rawInterval) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final fraction = rawInterval / magnitude;

  double niceFraction;
  if (fraction <= 1) {
    niceFraction = 1;
  } else if (fraction <= 2) {
    niceFraction = 2;
  } else if (fraction <= 5) {
    niceFraction = 5;
  } else {
    niceFraction = 10;
  }

  return niceFraction * magnitude;
}
