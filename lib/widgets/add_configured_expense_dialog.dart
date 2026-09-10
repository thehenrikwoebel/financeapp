import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/configured_expense.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:frontend/widgets/secondary_button.dart';

class AddConfiguredExpenseDialog extends StatefulWidget {
  final ConfiguredExpense? initialConfiguredExpense;
  const AddConfiguredExpenseDialog({super.key, this.initialConfiguredExpense});

  @override
  State<AddConfiguredExpenseDialog> createState() =>
      _AddConfiguredExpenseDialogState();
}

class _AddConfiguredExpenseDialogState
    extends State<AddConfiguredExpenseDialog> {
  late TextEditingController expenseNameController;
  late TextEditingController newExpenseNameController;
  late Future<List<Category>> categoriesFuture;
  late final String dialogTitle = AppStrings.get('new_rule');
  List<Category> _categories = [];
  int _selectedIndex = -1;

  bool get isFormValid {
    return expenseNameController.text.trim().isNotEmpty &&
        newExpenseNameController.text.isNotEmpty &&
        _selectedIndex != -1;
  }

  @override
  void initState() {
    super.initState();

    expenseNameController = TextEditingController(
      text: widget.initialConfiguredExpense?.expenseName ?? '',
    );

    newExpenseNameController = TextEditingController(
      text: widget.initialConfiguredExpense?.newExpenseName ?? '',
    );

    categoriesFuture = RepositoryProvider.instance.fetchCategories().then((
      categories,
    ) {
      if (widget.initialConfiguredExpense != null) {
        final index = categories.indexWhere(
          (c) => c.id == widget.initialConfiguredExpense!.category.id,
        );
        setState(() {
          _categories = categories;
          if (index != -1) setState(() => _selectedIndex = index);
        });
      }
      return categories;
    });

    // refresh UI so that isFormValid works
    expenseNameController.addListener(() => setState(() {}));
    newExpenseNameController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: expenseNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('configured_expense_name_hint'),
                ),
              ),

              TextField(
                controller: newExpenseNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('configured_expense_new_name_hint'),
                ),
              ),

              const SizedBox(height: 16),

              FutureBuilder<List<Category>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text(
                      "${AppStrings.get('error')}: ${snapshot.error}",
                    );
                  }

                  _categories = snapshot.data!;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_categories.length, (index) {
                      return SizedBox(
                        width: 100,
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(_categories[index].icon),
                          label: Text(
                            _categories[index].name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: _selectedIndex == index,
                          onSelected: (selected) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                label: AppStrings.get('save'),
                onPressed: () {
                  _save(widget.initialConfiguredExpense);
                },
                isActive: isFormValid,
              ),

              SizedBox(height: 10),

              SecondaryButton(
                label: AppStrings.get('abort'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(ConfiguredExpense? configuredExpense) async {
    if (configuredExpense == null) {
      await RepositoryProvider.instance.addNewConfiguredExpense(
        expenseNameController.text,
        newExpenseNameController.text,
        _categories[_selectedIndex],
      );
    } else {
      await RepositoryProvider.instance.updateConfiguredExpense(
        expenseNameController.text,
        newExpenseNameController.text,
        _categories[_selectedIndex],
        configuredExpense.id,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
