import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/category_card.dart';

class CategoriesList extends StatefulWidget {
  final Future<List<Category>> categoriesFuture;
  final void Function(Category)? onCardTap;
  final bool isSelectionMode;
  final Set<Category> selectedCategories;
  final Function(Category) onLongPress;
  final Function(Category) onToggleSelect;
  const CategoriesList({
    super.key,
    required this.categoriesFuture,
    this.onCardTap,
    required this.isSelectionMode,
    required this.selectedCategories,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.categoriesFuture,
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
          children: snapshot.data!.map((category) {
            final isSelected = widget.selectedCategories.contains(category);
            return Row(
              children: [
                if (widget.isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => widget.onToggleSelect(category),
                  ),
                Expanded(
                  child: CategoryCard(
                    category: category,
                    onLongPress: () => widget.onLongPress(category),
                    onTap: () => widget.isSelectionMode
                        ? widget.onToggleSelect(category)
                        : widget.onCardTap?.call(category), // opens edit modal
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
