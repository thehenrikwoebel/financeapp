import 'package:flutter/material.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/expense_card.dart';

class ExpensesList extends StatefulWidget {
  final Future<List<Expense>> expensesFuture;
  final VoidCallback onReload;
  final Function(Expense) onCardTap;
  final bool isSelectionMode;
  final Set<Expense> selectedExpenses;
  final Function(Expense) onLongPress;
  final Function(Expense) onToggleSelect;
  final ScrollController controller;

  const ExpensesList({
    super.key,
    required this.expensesFuture,
    required this.onReload,
    required this.isSelectionMode,
    required this.selectedExpenses,
    required this.onLongPress,
    required this.onToggleSelect,
    required this.controller,
    required this.onCardTap,
  });

  @override
  State<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  @override
  void didUpdateWidget(covariant ExpensesList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      future: widget.expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${AppStrings.get('error')}: ${snapshot.error}'),
          );
        }

        return ListView(
          controller: widget.controller,
          children: snapshot.data!.map((expense) {
            final isSelected = widget.selectedExpenses.contains(expense);
            return Row(
              children: [
                if (widget.isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => widget.onToggleSelect(expense),
                  ),
                Expanded(
                  child: ExpenseCard(
                    expense: expense,
                    onTap: () => widget.isSelectionMode
                        ? widget.onToggleSelect(expense)
                        : widget.onCardTap.call(expense),
                    onLongPress: () => widget.onLongPress(expense),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
