import 'package:flutter/material.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/cache.dart';
import 'package:frontend/widgets/add_expense_dialog.dart';
import 'package:frontend/widgets/app_bar_top.dart';
import 'package:frontend/widgets/confirm_delete_dialog.dart';
import 'package:frontend/widgets/edit_expense_dialog.dart';
import 'package:frontend/widgets/expenses_list.dart';
import 'package:frontend/widgets/load_more_button.dart';
import 'package:frontend/widgets/monthly_balance_title.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Expense>> expensesFuture;
  late Future<MonthlyBalance> monthlyBalanceFuture;
  bool isSelectionMode = false;
  bool _isSearching = false;
  Set<Expense> selectedExpenses = {};
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;
  int _amountExpenses = 20;
  final _cache = AppCache();

  void _increaseFetchLimit() {
    _amountExpenses += 20;
    _reloadData();
  }

  void _enterSelectionMode(Expense expense) {
    setState(() {
      isSelectionMode = true;
      selectedExpenses.add(expense);
    });
  }

  void _toggleSelect(Expense expense) {
    setState(() {
      if (selectedExpenses.contains(expense)) {
        selectedExpenses.remove(expense);
        if (selectedExpenses.isEmpty) isSelectionMode = false;
      } else {
        selectedExpenses.add(expense);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedExpenses.clear();
    });
  }

  void _deleteSelected() async {
    for (final expense in selectedExpenses) {
      await RepositoryProvider.instance.deleteExpense(expense.id);
    }
    _exitSelectionMode();
    _reloadData();
  }

  void fetchExpenses() {
    if (_cache.expenses.isValid) {
      expensesFuture = Future.value(_cache.expenses.value);
    } else {
      expensesFuture = RepositoryProvider.instance
          .fetchExpenses(fetchLimit: _amountExpenses)
          .then((e) {
            _cache.expenses.update(e);
            return e;
          });
    }
  }

  void fetchMonthlyBalance() {
    if (_cache.monthlyBalance.isValid) {
      monthlyBalanceFuture = Future.value(_cache.monthlyBalance.value);
    } else {
      monthlyBalanceFuture = RepositoryProvider.instance
          .fetchMonthlyBalance()
          .then((m) {
            _cache.monthlyBalance.update(m);
            return m;
          });
    }
  }

  void fetchData() {
    setState(() {
      fetchExpenses();
      fetchMonthlyBalance();
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final pixels = _scrollController.position.pixels;
      final maxExtent = _scrollController.position.maxScrollExtent;

      final nearBottom = pixels >= maxExtent - 100;
      final farFromBottom = pixels < maxExtent - 200; // neu

      if (nearBottom && !_showLoadMore) {
        setState(() => _showLoadMore = true);
      } else if (farFromBottom && _showLoadMore) {
        setState(() => _showLoadMore = false);
      }
    });
    _amountExpenses = 20;
    fetchData();
  }

  void _reloadData() {
    setState(() {
      _cache.expenses.invalidate();
      _cache.monthlyBalance.invalidate();
      _cache.monthlyBalances.invalidate();
      _cache.categories.invalidate();
      expensesFuture = RepositoryProvider.instance
          .fetchExpenses(fetchLimit: _amountExpenses)
          .then((e) {
            _cache.expenses.update(e);
            return e;
          });
      monthlyBalanceFuture = RepositoryProvider.instance
          .fetchMonthlyBalance()
          .then((m) {
            _cache.monthlyBalance.update(m);
            return m;
          });
    });
  }

  void _searchExpenses(String query) {
    _isSearching = true;
    setState(() {
      if (query.isEmpty) {
        fetchExpenses();
      } else {
        expensesFuture = RepositoryProvider.instance.searchExpenses(query);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTop(
        onRefresh: _reloadData,
        onSearch: _searchExpenses,
        isSelectionMode: isSelectionMode,
        selectedCount: selectedExpenses.length,
        onExitSelectionMode: _exitSelectionMode,
        onDeleteSelected: _showConfirmDeleteDialog,
        isSearching: _isSearching,
        onSearchToggle: (value) => setState(() => _isSearching = value),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthlyBalanceTitle(monthlyBalanceFuture: monthlyBalanceFuture),
          Expanded(
            child: ExpensesList(
              expensesFuture: expensesFuture,
              onReload: _reloadData,
              isSelectionMode: isSelectionMode,
              selectedExpenses: selectedExpenses,
              onLongPress: _enterSelectionMode,
              onToggleSelect: _toggleSelect,
              controller: _scrollController,
              onCardTap: _showEditExpenseDialog,
            ),
          ),
          if (_showLoadMore && !_isSearching)
            LoadMoreButton(onPressed: _increaseFetchLimit),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result == true) {
      // reloads expenses if new expense was added
      _reloadData();
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

  void _showEditExpenseDialog(Expense expense) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditExpenseDialog(initialExpense: expense),
    );
    if (result == true) {
      _reloadData();
    }
  }
}
