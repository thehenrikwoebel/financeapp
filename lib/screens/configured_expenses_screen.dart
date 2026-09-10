import 'package:flutter/material.dart';
import 'package:frontend/models/configured_expense.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/services/cache.dart';
import 'package:frontend/widgets/add_configured_expense_dialog.dart';
import 'package:frontend/widgets/app_bar_top.dart';
import 'package:frontend/widgets/configured_expenses_list.dart';
import 'package:frontend/widgets/confirm_delete_dialog.dart';
import 'package:frontend/widgets/edit_configured_expense_dialog.dart';

class ConfiguredExpensesScreen extends StatefulWidget {
  const ConfiguredExpensesScreen({super.key});

  @override
  State<ConfiguredExpensesScreen> createState() =>
      _ConfiguredExpensesScreenState();
}

class _ConfiguredExpensesScreenState extends State<ConfiguredExpensesScreen> {
  late Future<List<ConfiguredExpense>> configuredExpensesFuture;
  bool isSelectionMode = false;
  Set<ConfiguredExpense> selectedConfiguredExpenses = {};
  final _cache = AppCache();

  void _enterSelectionMode(ConfiguredExpense configuredExpense) {
    setState(() {
      isSelectionMode = true;
      selectedConfiguredExpenses.add(configuredExpense);
    });
  }

  void _toggleSelect(ConfiguredExpense configuredExpense) {
    setState(() {
      if (selectedConfiguredExpenses.contains(configuredExpense)) {
        selectedConfiguredExpenses.remove(configuredExpense);
        if (selectedConfiguredExpenses.isEmpty) isSelectionMode = false;
      } else {
        selectedConfiguredExpenses.add(configuredExpense);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedConfiguredExpenses.clear();
    });
  }

  void _deleteSelected() async {
    for (final configuredExpense in selectedConfiguredExpenses) {
      await RepositoryProvider.instance.deleteConfiguredExpense(
        configuredExpense.id,
      );
    }
    _exitSelectionMode();
    _reload();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchConfiguredExpenses() {
    if (_cache.configuredExpenses.isValid) {
      configuredExpensesFuture = Future.value(_cache.configuredExpenses.value);
    } else {
      configuredExpensesFuture = RepositoryProvider.instance
          .fetchConfiguredExpenses()
          .then((c) {
            _cache.configuredExpenses.update(c);
            return c;
          });
    }
  }

  void fetchData() {
    setState(() {
      fetchConfiguredExpenses();
    });
  }

  void _reload() {
    _cache.categories.invalidate();
    _cache.expenses.invalidate();
    _cache.configuredExpenses.invalidate();
    fetchData();
  }

  void _searchCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchConfiguredExpenses();
      } else {
        configuredExpensesFuture = RepositoryProvider.instance
            .searchConfiguredExpenses(query);
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
        selectedCount: selectedConfiguredExpenses.length,
        isSearching: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddConfiguredExpenseDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75,
            child: Center(
              child: Text(
                AppStrings.get('configured_expenses'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ConfiguredExpensesList(
              configuredExpensesFuture: configuredExpensesFuture,
              onCardTap: (configuredExpense) =>
                  _showEditConfiguredExpenseDialog(configuredExpense),
              isSelectionMode: isSelectionMode,
              selectedConfiguredExpenses: selectedConfiguredExpenses,
              onLongPress: _enterSelectionMode,
              onToggleSelect: _toggleSelect,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddConfiguredExpenseDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddConfiguredExpenseDialog(),
    );

    if (result == true) {
      // reloads expenses if new expense was added
      _reload();
    }
  }

  void _showEditConfiguredExpenseDialog(
    ConfiguredExpense configuredExpense,
  ) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditConfiguredExpenseDialog(
        initialConfiguredExpense: configuredExpense,
      ),
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
