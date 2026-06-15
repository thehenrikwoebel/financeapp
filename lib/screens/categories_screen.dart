import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/services/cache.dart';
import 'package:frontend/widgets/add_category_dialog.dart';
import 'package:frontend/widgets/app_bar_top.dart';
import 'package:frontend/widgets/categories_list.dart';
import 'package:frontend/widgets/confirm_delete_dialog.dart';
import 'package:frontend/widgets/edit_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> categoriesFuture;
  bool isSelectionMode = false;
  Set<Category> selectedCategories = {};
  final _cache = AppCache();

  void _enterSelectionMode(Category category) {
    setState(() {
      isSelectionMode = true;
      selectedCategories.add(category);
    });
  }

  void _toggleSelect(Category category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        if (selectedCategories.isEmpty) isSelectionMode = false;
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedCategories.clear();
    });
  }

  void _deleteSelected() async {
    for (final category in selectedCategories) {
      await RepositoryProvider.instance.deleteCategory(category.id);
    }
    _exitSelectionMode();
    _reload();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchCategories() {
    if (_cache.categories.isValid) {
      categoriesFuture = Future.value(_cache.categories.value);
    } else {
      categoriesFuture = RepositoryProvider.instance.fetchCategories().then((
        c,
      ) {
        _cache.categories.update(c);
        return c;
      });
    }
  }

  void fetchData() {
    setState(() {
      fetchCategories();
    });
  }

  void _reload() {
    _cache.categories.invalidate();
    _cache.expenses.invalidate();
    fetchData();
  }

  void _searchCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchCategories();
      } else {
        categoriesFuture = RepositoryProvider.instance.searchCategories(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTop(
        onRefresh: _reload,
        onSearch: _searchCategories,
        isSelectionMode: isSelectionMode,
        onDeleteSelected: _showConfirmDeleteDialog,
        onExitSelectionMode: _exitSelectionMode,
        selectedCount: selectedCategories.length,
        isSearching: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75,
            child: Center(
              child: Text(
                AppStrings.get('categories'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: CategoriesList(
              categoriesFuture: categoriesFuture,
              onCardTap: (category) => _showEditCategoryDialog(category),
              isSelectionMode: isSelectionMode,
              selectedCategories: selectedCategories,
              onLongPress: _enterSelectionMode,
              onToggleSelect: _toggleSelect,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddCategoryDialog(),
    );

    if (result == true) {
      // reloads expenses if new expense was added
      _reload();
    }
  }

  void _showEditCategoryDialog(Category category) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditCategoryDialog(initialCategory: category),
    );

    if (result == true) {
      // reloads expenses if new expense was added
      _reload();
    }
  }

  void _showConfirmDeleteDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ConfirmDeleteDialog(),
    );

    if (result == true) {
      // deletes the selected expenses if confirmed
      _deleteSelected();
    }
  }
}
