import 'package:flutter/material.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/widgets/add_expense_dialog.dart';

class EditExpenseDialog extends StatelessWidget {
  final Expense? initialExpense;
  const EditExpenseDialog({super.key, this.initialExpense});

  @override
  Widget build(BuildContext context) {
    return AddExpenseDialog(initialExpense: initialExpense);
  }
}
