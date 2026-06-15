import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/repositories/database_repository.dart';
import 'package:sembast_web/sembast_web.dart';

class LocalWebDatabaseRepository implements DatabaseRepository {
  static Database? _db;

  final _expenseStore = intMapStoreFactory.store('expenses');
  final _categoryStore = intMapStoreFactory.store('cost_types');

  Future<Database> get db async {
    _db ??= await databaseFactoryWeb.openDatabase('expenses_local.db');
    return _db!;
  }

  int get _now => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // builds a category object from a sembast-record
  Category _categoryFromRecord(RecordSnapshot<int, Map<String, Object?>> r) {
    final v = r.value;
    return Category(
      id: r.key,
      name: v['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (v['createdAt'] as int) * 1000,
      ),
      updatedAt: v['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((v['updatedAt'] as int) * 1000)
          : null,
      icon: Category.mapIcon(v['icon'] as String),
      totalAmount: (v['totalAmount'] as num?)?.toDouble(),
      count: (v['count'] as num?)?.toInt(),
    );
  }

  /// builds an expense object from a sembcast-record + corresponding category
  Expense _expenseFromRecord(
    RecordSnapshot<int, Map<String, Object?>> r,
    Category category,
  ) {
    final v = r.value;
    return Expense(
      id: r.key,
      title: v['title'] as String,
      amount: (v['amount'] as num).toDouble(),
      category: category,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (v['createdAt'] as int) * 1000,
      ),
      updatedAt: v['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((v['updatedAt'] as int) * 1000)
          : null,
    );
  }

  /// loads all expenses and enriches them with their categories
  Future<List<Expense>> _hydrateExpenses(
    List<RecordSnapshot<int, Map<String, Object?>>> records,
    Database database,
  ) async {
    // Alle benötigten Category-IDs sammeln und einmalig laden
    final categoryIds = records
        .map((r) => r.value['costTypeId'] as int?)
        .whereType<int>()
        .toSet();

    final categoryMap = <int, Category>{};
    for (final id in categoryIds) {
      final record = await _categoryStore.record(id).getSnapshot(database);
      if (record != null) {
        categoryMap[id] = _categoryFromRecord(record);
      }
    }

    // fallback category for costTypeId NULL
    final fallback = Category(
      id: -1,
      name: 'Unbekannt',
      createdAt: DateTime.now(),
      updatedAt: null,
      icon: Icons.help_outline,
    );

    return records.map((r) {
      final costTypeId = r.value['costTypeId'] as int?;
      final category = costTypeId != null
          ? categoryMap[costTypeId] ?? fallback
          : fallback;
      return _expenseFromRecord(r, category);
    }).toList();
  }

  @override
  Future<List<Expense>> fetchExpenses({int fetchLimit = 20}) async {
    final database = await db;
    final finder = Finder(
      sortOrders: [SortOrder('createdAt', false)],
      limit: fetchLimit,
    );
    final records = await _expenseStore.find(database, finder: finder);
    return _hydrateExpenses(records, database);
  }

  @override
  Future<List<Expense>> searchExpenses(String query) async {
    final database = await db;
    final lower = query.toLowerCase();

    // Alle Expenses laden und in Dart filtern (wie LIKE in SQL)
    final allRecords = await _expenseStore.find(
      database,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)]),
    );

    // first hydrate then filter (needs category.name for searching)
    final all = await _hydrateExpenses(allRecords, database);
    return all.where((e) {
      return e.title.toLowerCase().contains(lower) ||
          e.category.name.toLowerCase().contains(lower) ||
          e.amount.toString().contains(lower);
    }).toList();
  }

  @override
  Future<void> addNewExpense(
    String name,
    double amount,
    Category category,
    DateTime date,
  ) async {
    final database = await db;
    final timestamp = date.millisecondsSinceEpoch ~/ 1000;
    await _expenseStore.add(database, {
      'title': name,
      'amount': amount,
      'costTypeId': category.id,
      'createdAt': timestamp,
      'updatedAt': null,
    });
  }

  @override
  Future<void> updateExpense(
    String name,
    double amount,
    Category category,
    DateTime date,
    int id,
  ) async {
    final database = await db;
    final timestamp = date.millisecondsSinceEpoch ~/ 1000;
    await _expenseStore.record(id).update(database, {
      'title': name,
      'amount': amount,
      'costTypeId': category.id,
      'createdAt': timestamp,
      'updatedAt': _now,
    });
  }

  @override
  Future<void> deleteExpense(int id) async {
    final database = await db;
    await _expenseStore.record(id).delete(database);
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final database = await db;
    final records = await _categoryStore.find(database);

    // totalAmount and count per category
    final allExpenses = await _expenseStore.find(database);

    return records.map((r) {
        final expenses = allExpenses
            .where((e) => e.value['costTypeId'] == r.key)
            .toList();
        final totalAmount = expenses.fold<double>(
          0,
          (sum, e) => sum + (e.value['amount'] as num).toDouble(),
        );

        return Category(
          id: r.key,
          name: r.value['name'] as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            (r.value['createdAt'] as int) * 1000,
          ),
          updatedAt: r.value['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  (r.value['updatedAt'] as int) * 1000,
                )
              : null,
          icon: Category.mapIcon(r.value['icon'] as String),
          totalAmount: totalAmount,
          count: expenses.length,
        );
      }).toList()
      ..sort((a, b) => (b.totalAmount ?? 0).compareTo(a.totalAmount ?? 0));
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    final lower = query.toLowerCase();
    final all = await fetchCategories();
    return all.where((c) => c.name.toLowerCase().contains(lower)).toList();
  }

  @override
  Future<void> addNewCategory(String name, IconData icon) async {
    final database = await db;
    await _categoryStore.add(database, {
      'name': name,
      'icon': Category.iconToString(icon),
      'createdAt': _now,
      'updatedAt': null,
    });
  }

  @override
  Future<void> updateCategory(String name, IconData icon, int id) async {
    final database = await db;
    await _categoryStore.record(id).update(database, {
      'name': name,
      'icon': Category.iconToString(icon),
      'updatedAt': _now,
    });
  }

  @override
  Future<void> deleteCategory(int id) async {
    final database = await db;

    // ON DELETE SET NULL
    final finder = Finder(filter: Filter.equals('costTypeId', id));
    final affected = await _expenseStore.find(database, finder: finder);
    for (final expense in affected) {
      await _expenseStore.record(expense.key).update(database, {
        'costTypeId': null,
      });
    }

    await _categoryStore.record(id).delete(database);
  }

  // returns unix timestamp for start and end of month
  (int, int) _monthBounds(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return (
      start.millisecondsSinceEpoch ~/ 1000,
      end.millisecondsSinceEpoch ~/ 1000,
    );
  }

  Future<double> _sumExpenses(
    Database database, {
    required int startTs,
    required int endTs,
    int? costTypeId,
  }) async {
    var filter = Filter.and([
      Filter.greaterThanOrEquals('createdAt', startTs),
      Filter.lessThan('createdAt', endTs),
      if (costTypeId != null) Filter.equals('costTypeId', costTypeId),
    ]);

    final records = await _expenseStore.find(
      database,
      finder: Finder(filter: filter),
    );
    return records.fold<double>(
      0,
      (sum, r) => sum + (r.value['amount'] as num).toDouble(),
    );
  }

  @override
  Future<MonthlyBalance> fetchMonthlyBalance() async {
    final now = DateTime.now();
    return fetchPastMonthlyBalance(now.year, now.month);
  }

  @override
  Future<MonthlyBalance> fetchPastMonthlyBalance(int year, int month) async {
    final database = await db;
    final (startTs, endTs) = _monthBounds(year, month);
    final balance = await _sumExpenses(
      database,
      startTs: startTs,
      endTs: endTs,
    );
    return MonthlyBalance(year: year, month: month, balance: balance);
  }

  @override
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalances(int amount) async {
    final database = await db;
    final now = DateTime.now();
    final result = <MonthlyBalance>[];

    for (int i = 0; i < amount; i++) {
      final target = DateTime(now.year, now.month - i, 1);
      final (startTs, endTs) = _monthBounds(target.year, target.month);
      final balance = await _sumExpenses(
        database,
        startTs: startTs,
        endTs: endTs,
      );
      result.add(
        MonthlyBalance(
          year: target.year,
          month: target.month,
          balance: balance,
        ),
      );
    }

    return result;
  }

  @override
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalancesWithCategory(
    Category category,
    int amount,
  ) async {
    final database = await db;
    final now = DateTime.now();
    final result = <MonthlyBalance>[];

    for (int i = 0; i < amount; i++) {
      final target = DateTime(now.year, now.month - i, 1);
      final (startTs, endTs) = _monthBounds(target.year, target.month);
      final balance = await _sumExpenses(
        database,
        startTs: startTs,
        endTs: endTs,
        costTypeId: category.id,
      );
      result.add(
        MonthlyBalance(
          year: target.year,
          month: target.month,
          balance: balance,
        ),
      );
    }

    return result;
  }
}
