import 'package:flutter/material.dart';
import 'package:frontend/models/configured_expense.dart';

class ConfiguredExpenseCard extends StatelessWidget {
  final ConfiguredExpense configuredExpense;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const ConfiguredExpenseCard({
    super.key,
    required this.configuredExpense,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Icon(configuredExpense.category.icon),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    "'${configuredExpense.expenseName}' -> '${configuredExpense.newExpenseName}'",
              ),
            ],
          ),
        ),
        subtitle: Text(configuredExpense.category.name),
      ),
    );
  }
}
