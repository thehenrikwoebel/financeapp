import 'package:flutter/material.dart';
import 'package:frontend/models/configured_expense.dart';
import 'package:frontend/widgets/configured_expense_card.dart';

import '../services/app_strings.dart';

class ConfiguredExpensesList extends StatefulWidget {
  final Future<List<ConfiguredExpense>> configuredExpensesFuture;
  final void Function(ConfiguredExpense)? onCardTap;
  final bool isSelectionMode;
  final Set<ConfiguredExpense> selectedConfiguredExpenses;
  final Function(ConfiguredExpense) onLongPress;
  final Function(ConfiguredExpense) onToggleSelect;
  const ConfiguredExpensesList({
    super.key,
    required this.configuredExpensesFuture,
    this.onCardTap,
    required this.isSelectionMode,
    required this.onLongPress,
    required this.onToggleSelect,
    required this.selectedConfiguredExpenses,
  });

  @override
  State<ConfiguredExpensesList> createState() => _ConfiguredExpensesListState();
}

class _ConfiguredExpensesListState extends State<ConfiguredExpensesList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.configuredExpensesFuture,
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
          children: snapshot.data!.map((configuredExpense) {
            final isSelected = widget.selectedConfiguredExpenses.contains(
              configuredExpense,
            );
            return Row(
              children: [
                if (widget.isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => widget.onToggleSelect(configuredExpense),
                  ),
                Expanded(
                  child: ConfiguredExpenseCard(
                    configuredExpense: configuredExpense,
                    onLongPress: () => widget.onLongPress(configuredExpense),
                    onTap: () => widget.isSelectionMode
                        ? widget.onToggleSelect(configuredExpense)
                        : widget.onCardTap?.call(
                            configuredExpense,
                          ), // opens edit modal
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
