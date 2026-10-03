import 'package:flutter/src/widgets/icon_data.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/configured_expense.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/repositories/database_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class LocalMobileDatabaseRepository implements DatabaseRepository {
  late final Future<Database> db = _openOrCreateDatabase();
  static const int _fallbackCategoryId = 0;

  Future<Database> _openOrCreateDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'financeapp.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        final schema = await rootBundle.loadString('assets/schema.sql');

        // split sql statements and execute them one by
        final statements = schema
            .split(';')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);

        await db.execute('PRAGMA foreign_keys = ON');

        for (final statement in statements) {
          await db.execute(statement);
        }
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      version: 1,
    );
  }

  @override
  Future<void> addNewCategory(String name, IconData icon) async {
    final database = await db;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await database.insert('CostTypes', {
      'Name': name,
      'CreatedAt': timestamp,
      'icon': Category.iconToString(icon),
    });
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

    try {
      await database.transaction((txn) async {
        final rules = await txn.query(
          'ConfiguredExpenses',
          columns: ['NewExpenseName', 'CostTypeID'],
          where: 'ExpenseName = ?',
          whereArgs: [name],
          limit: 1,
        );

        final finalName = rules.isNotEmpty
            ? rules.first['NewExpenseName'] as String
            : name;
        final finalCostTypeId = rules.isNotEmpty
            ? rules.first['CostTypeID'] as int
            : category.id;

        await txn.insert('Expenses', {
          'Name': finalName,
          'Amount': amount,
          'CreatedAt': timestamp,
          'CostTypeID': finalCostTypeId,
        });
      });
    } on DatabaseException catch (e) {
      if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw Exception('CostType does not exist');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    if (id == _fallbackCategoryId)
      return; // don't allow deletion of fallback category
    final database = await db;

    await database.transaction((txn) async {
      await txn.update(
        'Expenses',
        {'CostTypeID': _fallbackCategoryId},
        where: 'CostTypeID = ?',
        whereArgs: [id],
      );

      await txn.update(
        'ConfiguredExpenses',
        {'CostTypeID': _fallbackCategoryId},
        where: 'CostTypeID = ?',
        whereArgs: [id],
      );

      await txn.delete('CostTypes', where: 'ID = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> deleteExpense(int id) async {
    final database = await db;

    await database.delete('Expenses', where: 'ID = ?', whereArgs: [id]);
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final database = await db;

    final rows = await database.rawQuery('''
    SELECT c.*, COUNT(e.ID) as count, COALESCE(SUM(e.Amount), 0) as TotalAmount
    FROM CostTypes c
    LEFT JOIN Expenses e ON e.CostTypeID = c.ID
    WHERE c.ID != $_fallbackCategoryId
    GROUP BY c.ID
    ORDER BY TotalAmount DESC
  ''');

    return rows.map((row) => Category.fromJson(row)).toList();
  }

  @override
  Future<List<Expense>> fetchExpenses({int fetchLimit = 20}) async {
    final database = await db;

    final rows = await database.rawQuery(
      '''
    SELECT 
      e.Name as Title,
      e.Amount,
      e.CreatedAt,
      e.UpdatedAt,
      e.ID as e_ID,
      c.ID as c_ID,
      c.Name as c_Name,
      c.CreatedAt as c_CreatedAt,
      c.UpdatedAt as c_UpdatedAt,
      c.icon as c_icon
    FROM Expenses e
    LEFT JOIN CostTypes c 
      ON e.CostTypeID = c.ID
    ORDER BY e.CreatedAt DESC
    LIMIT ?
  ''',
      [fetchLimit],
    );

    return rows.map((row) {
      final categoryId = row['c_ID'];
      return Expense.fromJson({
        'id': row['e_ID'],
        'title': row['Title'],
        'amount': row['Amount'],
        'createdAt': row['CreatedAt'],
        'updatedAt': row['UpdatedAt'],
        'category': categoryId != null
            ? {
                'ID': categoryId,
                'Name': row['c_Name'],
                'CreatedAt': row['c_CreatedAt'],
                'UpdatedAt': row['c_UpdatedAt'],
                'icon': row['c_icon'],
              }
            : null,
      });
    }).toList();
  }

  @override
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalances(int amount) async {
    final database = await db;

    final now = DateTime.now();
    final earliest = DateTime(now.year, now.month - (amount - 1), 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final startTs = earliest.millisecondsSinceEpoch ~/ 1000;
    final endTs = end.millisecondsSinceEpoch ~/ 1000;

    final rows = await database.rawQuery(
      '''
    SELECT 
      CAST(strftime('%Y', datetime(CreatedAt, 'unixepoch')) AS INTEGER) as year,
      CAST(strftime('%m', datetime(CreatedAt, 'unixepoch')) AS INTEGER) as month,
      SUM(Amount) as balance
    FROM Expenses
    WHERE CreatedAt >= ? AND CreatedAt < ?
    GROUP BY year, month
  ''',
      [startTs, endTs],
    );

    // Map (year, month) -> balance
    final balances = {
      for (final row in rows)
        (row['year'] as int, row['month'] as int): (row['balance'] as num)
            .toDouble(),
    };

    return List.generate(amount, (i) {
      final target = DateTime(now.year, now.month - i, 1);
      return MonthlyBalance.fromJson({
        'year': target.year,
        'month': target.month,
        'balance': balances[(target.year, target.month)] ?? 0.0,
      });
    });
  }

  @override
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalancesWithCategory(
    Category category,
    int amount,
  ) async {
    final database = await db;

    final now = DateTime.now();
    final earliest = DateTime(now.year, now.month - (amount - 1), 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final startTs = earliest.millisecondsSinceEpoch ~/ 1000;
    final endTs = end.millisecondsSinceEpoch ~/ 1000;

    final rows = await database.rawQuery(
      '''
    SELECT 
      CAST(strftime('%Y', datetime(CreatedAt, 'unixepoch')) AS INTEGER) as year,
      CAST(strftime('%m', datetime(CreatedAt, 'unixepoch')) AS INTEGER) as month,
      SUM(Amount) as balance
    FROM Expenses
    WHERE CostTypeID = ?
      AND CreatedAt >= ? AND CreatedAt < ?
    GROUP BY year, month
  ''',
      [category.id, startTs, endTs],
    );

    final balances = {
      for (final row in rows)
        (row['year'] as int, row['month'] as int): (row['balance'] as num)
            .toDouble(),
    };

    return List.generate(amount, (i) {
      final target = DateTime(now.year, now.month - i, 1);
      return MonthlyBalance.fromJson({
        'year': target.year,
        'month': target.month,
        'balance': balances[(target.year, target.month)] ?? 0.0,
      });
    });
  }

  Future<MonthlyBalance> fetchMonthlyBalance() async {
    final database = await db;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(
      now.year,
      now.month + 1,
      1,
    ); // DateTime handles december automatically

    final startTs = start.millisecondsSinceEpoch ~/ 1000;
    final endTs = end.millisecondsSinceEpoch ~/ 1000;

    final rows = await database.rawQuery(
      '''
    SELECT SUM(Amount) as balance
    FROM Expenses
    WHERE CreatedAt >= ? AND CreatedAt < ?
  ''',
      [startTs, endTs],
    );

    final balance = (rows.first['balance'] as num?)?.toDouble() ?? 0.0;

    return MonthlyBalance.fromJson({
      'year': now.year,
      'month': now.month,
      'balance': balance,
    });
  }

  @override
  Future<MonthlyBalance> fetchPastMonthlyBalance(int year, int month) async {
    final database = await db;

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final startTs = start.millisecondsSinceEpoch ~/ 1000;
    final endTs = end.millisecondsSinceEpoch ~/ 1000;

    final rows = await database.rawQuery(
      '''
    SELECT SUM(Amount) as balance
    FROM Expenses
    WHERE CreatedAt >= ? AND CreatedAt < ?
  ''',
      [startTs, endTs],
    );

    final balance = (rows.first['balance'] as num?)?.toDouble() ?? 0.0;

    return MonthlyBalance.fromJson({
      'year': year,
      'month': month,
      'balance': balance,
    });
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    final database = await db;

    final rows = await database.rawQuery(
      '''
    SELECT c.*, COUNT(e.ID) as count, COALESCE(SUM(e.Amount), 0) as TotalAmount
    FROM CostTypes c
    LEFT JOIN Expenses e ON e.CostTypeID = c.ID
    WHERE c.Name LIKE ?
    AND c.ID != $_fallbackCategoryId
    GROUP BY c.ID
    ORDER BY TotalAmount DESC
  ''',
      ['%$query%'],
    );

    return rows.map((row) => Category.fromJson(row)).toList();
  }

  @override
  Future<List<Expense>> searchExpenses(String query) async {
    final database = await db;

    final rows = await database.rawQuery(
      '''
    SELECT 
      e.Name as Title,
      e.Amount,
      e.CreatedAt,
      e.UpdatedAt,
      e.ID as e_ID,
      c.ID as c_ID,
      c.Name as c_Name,
      c.CreatedAt as c_CreatedAt,
      c.UpdatedAt as c_UpdatedAt,
      c.icon as c_icon
    FROM Expenses e
    LEFT JOIN CostTypes c 
      ON e.CostTypeID = c.ID
    WHERE
      e.Name LIKE ?
      OR c.Name LIKE ?
      OR CAST(e.Amount AS TEXT) LIKE ?
    ORDER BY e.CreatedAt DESC
  ''',
      ['%$query%', '%$query%', '%$query%'],
    );

    return rows.map((row) {
      final categoryId = row['c_ID'];
      return Expense.fromJson({
        'id': row['e_ID'],
        'title': row['Title'],
        'amount': row['Amount'],
        'createdAt': row['CreatedAt'],
        'updatedAt': row['UpdatedAt'],
        'category': categoryId != null
            ? {
                'ID': categoryId,
                'Name': row['c_Name'],
                'CreatedAt': row['c_CreatedAt'],
                'UpdatedAt': row['c_UpdatedAt'],
                'icon': row['c_icon'],
              }
            : null,
      });
    }).toList();
  }

  @override
  Future<void> updateCategory(String name, IconData icon, int id) async {
    final database = await db;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await database.update(
      'CostTypes',
      {
        'Name': name,
        'icon': Category.iconToString(icon),
        'UpdatedAt': timestamp,
      },
      where: 'ID = ?',
      whereArgs: [id],
    );
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

    await database.update(
      'Expenses',
      {
        'Name': name,
        'Amount': amount,
        'UpdatedAt': timestamp,
        'CostTypeID': category.id,
      },
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  static const _configuredExpenseSelect = '''
    SELECT
      ce.ID as ce_ID,
      ce.ExpenseName,
      ce.NewExpenseName,
      c.ID as c_ID,
      c.Name as c_Name,
      c.CreatedAt as c_CreatedAt,
      c.UpdatedAt as c_UpdatedAt,
      c.icon as c_icon
    FROM ConfiguredExpenses ce
    JOIN CostTypes c ON ce.CostTypeID = c.ID
  ''';

  ConfiguredExpense _configuredExpenseFromRow(Map<String, Object?> row) {
    return ConfiguredExpense.fromJson({
      'ID': row['ce_ID'],
      'ExpenseName': row['ExpenseName'],
      'NewExpenseName': row['NewExpenseName'],
      'category': {
        'ID': row['c_ID'],
        'Name': row['c_Name'],
        'CreatedAt': row['c_CreatedAt'],
        'UpdatedAt': row['c_UpdatedAt'],
        'icon': row['c_icon'],
      },
    });
  }

  @override
  Future<void> addNewConfiguredExpense(
    String text,
    String text2,
    Category categori,
  ) async {
    final database = await db;
    try {
      await database.insert('ConfiguredExpenses', {
        'ExpenseName': text,
        'NewExpenseName': text2,
        'CostTypeID': categori.id,
      });
    } on DatabaseException catch (e) {
      if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw Exception('CostType does not exist');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteConfiguredExpense(int id) async {
    final database = await db;
    await database.delete(
      'ConfiguredExpenses',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ConfiguredExpense>> fetchConfiguredExpenses() async {
    final database = await db;
    final rows = await database.rawQuery(
      '$_configuredExpenseSelect ORDER BY ce.ExpenseName',
    );
    return rows.map(_configuredExpenseFromRow).toList();
  }

  @override
  Future<List<ConfiguredExpense>> searchConfiguredExpenses(String query) async {
    final database = await db;
    final rows = await database.rawQuery(
      '''
      $_configuredExpenseSelect
      WHERE ce.ExpenseName LIKE ?
         OR ce.NewExpenseName LIKE ?
         OR c.Name LIKE ?
      ORDER BY ce.ExpenseName
      ''',
      ['%$query%', '%$query%', '%$query%'],
    );
    return rows.map(_configuredExpenseFromRow).toList();
  }

  @override
  Future<void> updateConfiguredExpense(
    String text,
    String text2,
    Category categori,
    int id,
  ) async {
    final database = await db;
    try {
      await database.update(
        'ConfiguredExpenses',
        {
          'ExpenseName': text,
          'NewExpenseName': text2,
          'CostTypeID': categori.id,
        },
        where: 'ID = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw Exception('CostType does not exist');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateCategoryBulk(
    String name,
    Category category,
    List<int> ids,
  ) {
    // TODO: implement updateCategoryBulk
    throw UnimplementedError();
  }
}
