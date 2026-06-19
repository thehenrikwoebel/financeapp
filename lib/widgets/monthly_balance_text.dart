import 'package:flutter/material.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/utils/formatter.dart';

final months = [
  AppStrings.get('january'),
  AppStrings.get('february'),
  AppStrings.get('march'),
  AppStrings.get('april'),
  AppStrings.get('may'),
  AppStrings.get('june'),
  AppStrings.get('july'),
  AppStrings.get('august'),
  AppStrings.get('september'),
  AppStrings.get('october'),
  AppStrings.get('november'),
  AppStrings.get('december'),
];

class MonthlyBalanceText extends StatelessWidget {
  final MonthlyBalance monthlyBalance;
  const MonthlyBalanceText({super.key, required this.monthlyBalance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 26, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${AppStrings.get('bilance')} ${months[monthlyBalance.month - 1]} ${monthlyBalance.year}: ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "${formatNumber(monthlyBalance.balance, AppStrings.currentLanguage)}${AppStrings.get('currency_symbol')}",
            style: TextStyle(
              color: monthlyBalance.balance >= 0 ? Colors.green : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
