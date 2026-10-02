import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
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

class MonthlyBalanceCard extends StatelessWidget {
  final MonthlyBalance monthlyBalance;
  final Category category;
  const MonthlyBalanceCard({
    super.key,
    required this.monthlyBalance,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(months[monthlyBalance.month - 1]),
        subtitle: Text(monthlyBalance.year.toString()),
        trailing: Text(
          "${formatNumber(monthlyBalance.balance, AppStrings.currentLanguage)}${AppStrings.get('currency_symbol')}",
          style: TextStyle(
            color: monthlyBalance.balance > 0 ? Colors.green : Colors.red,
            fontSize: 18,
          ),
        ),
        leading: Icon(category.icon),
      ),
    );
  }
}
