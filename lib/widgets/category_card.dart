import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/utils/formatter.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Icon(category.icon),
        title: Text.rich(TextSpan(children: [TextSpan(text: category.name)])),
        trailing: Text(
          "${formatNumber(category.totalAmount ?? 0, AppStrings.currentLanguage)}${AppStrings.get('currency_symbol')}",
          style: TextStyle(
            color: (category.totalAmount ?? 0) > 0 ? Colors.green : Colors.red,
            fontSize: 18,
          ),
        ),
        subtitle: Text("#${category.count}"),
      ),
    );
  }
}
