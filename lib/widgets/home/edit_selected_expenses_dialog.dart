import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/common/category_chips.dart';
import 'package:frontend/widgets/common/primary_button.dart';
import 'package:frontend/widgets/common/secondary_button.dart';

class EditSelectedExpensesDialog extends StatefulWidget {
  final Set<Expense> expenses;
  const EditSelectedExpensesDialog({super.key, required this.expenses});

  @override
  State<EditSelectedExpensesDialog> createState() =>
      _EditSelectedExpenesDialogState();
}

class _EditSelectedExpenesDialogState
    extends State<EditSelectedExpensesDialog> {
  String get _dialogTitle =>
      "${AppStrings.get('edit_selected_expenses')} (${widget.expenses.length})";
  TextEditingController nameController = TextEditingController();
  late Future<List<Category>> categoriesFuture;
  Category? _selectedCategory;

  bool get isFormValid {
    return nameController.text.trim().isNotEmpty && _selectedCategory != null;
  }

  @override
  void initState() {
    super.initState();
    categoriesFuture = RepositoryProvider.instance.fetchCategories();
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
                _dialogTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('shared_name'),
                ),
              ),

              const SizedBox(height: 16),

              CategoryChips(
                categoriesFuture: categoriesFuture,
                onSelectedCategory: _onSelectedCategory,
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                label: AppStrings.get('save'),
                onPressed: () {
                  _save(widget.expenses);
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

  void _onSelectedCategory(Category category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _save(Set<Expense> expenses) async {
    if (_selectedCategory == null) return;

    List<int> ids = [];

    for (var expense in expenses) {
      ids.add(expense.id);
    }

    await RepositoryProvider.instance.updateCategoryBulk(
      nameController.text,
      _selectedCategory!,
      ids,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
