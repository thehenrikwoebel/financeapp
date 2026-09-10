import 'package:flutter/material.dart';
import 'package:frontend/models/configured_expense.dart';
import 'package:frontend/widgets/add_configured_expense_dialog.dart';

class EditConfiguredExpenseDialog extends StatelessWidget {
  final ConfiguredExpense? initialConfiguredExpense;
  const EditConfiguredExpenseDialog({super.key, this.initialConfiguredExpense});

  @override
  Widget build(BuildContext context) {
    return AddConfiguredExpenseDialog(
      initialConfiguredExpense: initialConfiguredExpense,
    );
  }
}
