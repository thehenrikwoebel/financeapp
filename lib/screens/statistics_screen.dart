import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/cache.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/app_bar_top.dart';
import 'package:frontend/widgets/monthly_balances_chart.dart';
import 'package:frontend/widgets/monthly_balances_list.dart';
import 'package:material_symbols_icons/symbols.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<MonthlyBalance>> monthlyBalancesFuture;
  late TextEditingController _dropdownController;
  Category? _selectedCategory;
  List<DropdownMenuEntry<Category>> dropDownEntries = [];

  final _cache = AppCache();

  final Category _allCategory = Category(
    id: -1,
    name: AppStrings.get('all_categories'),
    createdAt: DateTime.now(),
    updatedAt: null,
    icon: Symbols.category,
  );

  @override
  void initState() {
    super.initState();
    _selectedCategory = _allCategory;
    _dropdownController = TextEditingController(text: _allCategory.name);
    fetchMonthlyBalances();
    _loadCategories();
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  void fetchMonthlyBalances() {
    // only use cache for not category specific queries
    if (_selectedCategory!.id == -1) {
      if (_cache.monthlyBalances.isValid) {
        monthlyBalancesFuture = Future.value(_cache.monthlyBalances.value);
      } else {
        monthlyBalancesFuture = RepositoryProvider.instance
            .fetchLastXMonthlyBalances(20)
            .then((m) {
              _cache.monthlyBalances.update(m);
              return m;
            });
      }
    } else {
      // no cache
      monthlyBalancesFuture = RepositoryProvider.instance
          .fetchLastXMonthlyBalancesWithCategory(_selectedCategory!, 20);
    }
  }

  Future<void> _loadCategories() async {
    if (_cache.categories.isValid) {
      setState(() {
        _buildDropdownEntries(_cache.categories.value!);
      });
      return;
    }

    final categories = await RepositoryProvider.instance.fetchCategories();
    _cache.categories.update(categories);
    setState(() {
      _buildDropdownEntries(categories);
    });
  }

  void _buildDropdownEntries(List<Category> categories) {
    dropDownEntries = [
      DropdownMenuEntry<Category>(
        value: _allCategory,
        label: _allCategory.name,
        leadingIcon: Icon(_allCategory.icon),
      ),
      ...categories.map(
        (category) => DropdownMenuEntry<Category>(
          value: category,
          label: category.name,
          leadingIcon: Icon(category.icon),
        ),
      ),
    ];
  }

  void _reload() {
    _cache.monthlyBalances.invalidate();
    setState(() {
      fetchMonthlyBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTop(
        onRefresh: _reload,
        showSearch: false,
        isSearching: false,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 75,
              child: Center(
                child: Text(
                  AppStrings.get('bilances'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DropdownMenu(
              controller: _dropdownController,
              width: MediaQuery.of(context).size.width * 0.90,
              label: Text(AppStrings.get('category')),
              leadingIcon: Icon(_selectedCategory?.icon ?? Symbols.search),
              dropdownMenuEntries: dropDownEntries,
              onSelected: (Category? selected) {
                _selectedCategory = selected;
                _reload();
              },
            ),
            SizedBox(height: 25),
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.28, // 28% of display height
              width:
                  MediaQuery.of(context).size.width *
                  0.9, // 90% of display width
              child: MonthlyBalancesChart(
                monthlyBalancesFuture: monthlyBalancesFuture,
              ),
            ),
            SizedBox(height: 50),
            MonthlyBalancesList(
              monthlyBalancesFuture: monthlyBalancesFuture,
              category: _selectedCategory ?? _allCategory,
            ),
          ],
        ),
      ),
    );
  }
}
