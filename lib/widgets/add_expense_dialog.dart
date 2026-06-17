import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/utils/formatter.dart';
import 'package:frontend/widgets/date_field.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:frontend/widgets/secondary_button.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expense? initialExpense;

  const AddExpenseDialog({super.key, this.initialExpense});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController amountController = TextEditingController();
  late Future<List<Category>> categoriesFuture;
  late DateTime _selectedDate;
  late final String dialogTitle =
      widget.initialExpense?.title ?? AppStrings.get('new_expense');
  List<Category> _categories = [];
  int selectedIndex = -1;

  bool get isFormValid {
    return nameController.text.trim().isNotEmpty &&
        amountController.text.trim().isNotEmpty &&
        isStringValidNum(amountController.text.trim()) &&
        _categories.isNotEmpty &&
        selectedIndex >= 0;
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.initialExpense?.title ?? '',
    );

    if (widget.initialExpense != null) {
      amountController = TextEditingController(
        text: formatNumber(
          widget.initialExpense!.amount,
          AppStrings.currentLanguage,
        ),
      );
    } else {
      amountController = TextEditingController(text: '');
    }

    categoriesFuture = RepositoryProvider.instance.fetchCategories().then((
      categories,
    ) {
      if (widget.initialExpense != null) {
        final index = categories.indexWhere(
          (c) => c.id == widget.initialExpense!.category.id,
        );
        setState(() {
          _categories = categories;
          if (index != -1) setState(() => selectedIndex = index);
        });
      }
      return categories;
    });

    _selectedDate = widget.initialExpense?.createdAt ?? DateTime.now();

    // refresh UI so that isFormValid works
    nameController.addListener(() => setState(() {}));
    amountController.addListener(() => setState(() {}));
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

              DateField(
                hintText: AppStrings.get('date'),
                initialDate: widget.initialExpense?.createdAt ?? DateTime.now(),
                onDateSelected: (date) {
                  _selectedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    12,
                    0,
                    0,
                  ); // use 12 o'clock to not run into time problems
                },
              ),

              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppStrings.get('name')),
              ),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.get('amount'),
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
                          selected: selectedIndex == index,
                          onSelected: (selected) {
                            setState(() {
                              selectedIndex = index;
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
                  _save(widget.initialExpense);
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

  Future<void> _save(Expense? exp) async {
    if (exp == null) {
      await RepositoryProvider.instance.addNewExpense(
        nameController.text,
        parseNumber(amountController.text, AppStrings.currentLanguage),
        _categories[selectedIndex],
        _selectedDate,
      );
    } else {
      await RepositoryProvider.instance.updateExpense(
        nameController.text,
        parseNumber(amountController.text, AppStrings.currentLanguage),
        _categories[selectedIndex],
        _selectedDate,
        exp.id,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
