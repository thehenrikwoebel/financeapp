import 'package:flutter/material.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/utils/formatter.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Icon(expense.category.icon),
        title: Text.rich(TextSpan(children: [TextSpan(text: expense.title)])),
        trailing: Text(
          "${formatNumber(expense.amount, AppStrings.currentLanguage)}${AppStrings.get('currency_symbol')}",
          style: TextStyle(
            color: expense.amount > 0 ? Colors.green : Colors.red,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          DateFormat(AppStrings.get('date_format')).format(expense.createdAt),
        ),
      ),
    );
  }
}
