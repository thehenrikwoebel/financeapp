import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';

import 'package:frontend/widgets/add_category_dialog.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category? initialCategory;
  const EditCategoryDialog({super.key, this.initialCategory});

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  @override
  Widget build(BuildContext context) {
    return AddCategoryDialog(initialCategory: widget.initialCategory);
  }
}
