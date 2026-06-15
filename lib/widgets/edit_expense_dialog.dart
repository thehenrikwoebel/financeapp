import 'package:flutter/material.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/widgets/add_expense_dialog.dart';

class EditExpenseDialog extends StatefulWidget {
  final Expense? initialExpense;
  const EditExpenseDialog({super.key, this.initialExpense});

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late final Expense? expense;

  @override
  void initState() {
    super.initState();
    expense = widget.initialExpense;
  }

  @override
  Widget build(BuildContext context) {
    return AddExpenseDialog(initialExpense: expense);
  }
}
