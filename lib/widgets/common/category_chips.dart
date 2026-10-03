import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/services/app_strings.dart';

class CategoryChips extends StatefulWidget {
  final Future<List<Category>> categoriesFuture;
  final ValueChanged<Category> onSelectedCategory;
  final Category? initialCategory;
  const CategoryChips({
    super.key,
    required this.categoriesFuture,
    required this.onSelectedCategory,
    this.initialCategory,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late List<Category> _categories;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _applyInitialCategory();
  }

  Future<void> _applyInitialCategory() async {
    final initial = widget.initialCategory;
    if (initial == null) return;

    final categories = await widget.categoriesFuture;
    if (!mounted) return;

    final index = categories.indexWhere((c) => c.id == initial.id);
    if (index == -1) return;

    setState(() => _selectedIndex = index);
    widget.onSelectedCategory(categories[index]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: widget.categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("${AppStrings.get('error')}: ${snapshot.error}");
        }

        _categories = snapshot.data!;

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: SingleChildScrollView(
            child: Wrap(
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
                      widget.onSelectedCategory(_categories[_selectedIndex!]);
                    },
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
