// lib/repositories/expense_repository.dart
import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/models/monthlyBalance.dart';

abstract class DatabaseRepository {
  Future<List<Expense>> fetchExpenses({int fetchLimit});
  Future<List<Expense>> searchExpenses(String query);
  Future<MonthlyBalance> fetchMonthlyBalance();
  Future<MonthlyBalance> fetchPastMonthlyBalance(int year, int month);
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalances(int amount);
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalancesWithCategory(
    Category category,
    int amount,
  );
  Future<List<Category>> fetchCategories();
  Future<List<Category>> searchCategories(String query);
  Future<void> addNewExpense(
    String name,
    double amount,
    Category category,
    DateTime date,
  );
  Future<void> updateExpense(
    String name,
    double amount,
    Category category,
    DateTime date,
    int id,
  );
  Future<void> deleteExpense(int id);
  Future<void> addNewCategory(String name, IconData icon);
  Future<void> updateCategory(String name, IconData icon, int id);
  Future<void> deleteCategory(int id);
}
