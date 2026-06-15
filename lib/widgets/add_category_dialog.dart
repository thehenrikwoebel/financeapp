import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:frontend/widgets/secondary_button.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AddCategoryDialog extends StatefulWidget {
  final Category? initialCategory;
  const AddCategoryDialog({super.key, this.initialCategory});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late TextEditingController nameController;
  IconData? selectedIcon;

  // icons
  final List<IconData> icons = [
    Symbols.live_tv,
    Symbols.security,
    Symbols.local_gas_station,
    Symbols.question_mark,
    Symbols.home,
    Symbols.work,
    Symbols.school,
    Symbols.shopping_cart,
    Symbols.favorite,
    Symbols.star,
    Symbols.sports_soccer,
    Symbols.music_note,
    Symbols.directions_car,
    Symbols.restaurant,
    Symbols.flight,
    Symbols.local_hospital,
    Symbols.fitness_center,
    Symbols.pets,
    Symbols.attach_money,
    Symbols.phone,
    Symbols.mail,
    Symbols.camera_alt,
    Symbols.book,
    Symbols.computer,
    Symbols.savings,
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.initialCategory?.name ?? '',
    );
    selectedIcon = widget.initialCategory?.icon;
  }

  bool get _isFormValid {
    return selectedIcon != null && nameController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.initialCategory != null
                      ? widget.initialCategory!.name
                      : AppStrings.get('new_category'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('name'),
                  ),
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.get('select_icon'),
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 8),

                // Icon Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return FilterChip(
                      label: Icon(icon, size: 20),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedIcon = isSelected ? null : icon;
                        });
                      },
                      showCheckmark: false,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10),

                PrimaryButton(
                  label: AppStrings.get('save'),
                  onPressed: _save,
                  isActive: _isFormValid,
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
      ),
    );
  }

  Future<void> _save() async {
    if (widget.initialCategory == null) {
      await RepositoryProvider.instance.addNewCategory(
        nameController.text,
        selectedIcon!,
      );
    } else {
      await RepositoryProvider.instance.updateCategory(
        nameController.text,
        selectedIcon!,
        widget.initialCategory!.id,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
