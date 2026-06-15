import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/repositories/database_repository.dart';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../models/monthlyBalance.dart';

class ApiService implements DatabaseRepository {
  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const int limit = 20;
  @override
  Future<List<Expense>> fetchExpenses({int fetchLimit = limit}) async {
    final response = await http.get(Uri.parse('$baseUrl/expenses/$fetchLimit'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Fehler beim Laden der Daten!');
    }
  }

  @override
  Future<List<Expense>> searchExpenses(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/search/$query'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Fehler beim Laden der Daten!');
    }
  }

  @override
  Future<MonthlyBalance> fetchMonthlyBalance() async {
    final response = await http.get(Uri.parse('$baseUrl/balance/monthly/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MonthlyBalance.fromJson(data);
    } else {
      throw Exception('Fehler beim Laden der Bilanz!');
    }
  }

  @override
  Future<MonthlyBalance> fetchPastMonthlyBalance(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/balance/monthly/$year/$month'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MonthlyBalance.fromJson(data);
    } else {
      throw Exception('Fehler beim Laden der Bilanz!');
    }
  }

  @override
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalances(int amount) async {
    final response = await http.get(
      Uri.parse('$baseUrl/balance/monthly/last/$amount'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((m) => MonthlyBalance.fromJson(m)).toList();
    } else {
      throw Exception('Fehler beim Laden der Bilanzen!');
    }
  }

  @override
  Future<List<MonthlyBalance>> fetchLastXMonthlyBalancesWithCategory(
    Category category,
    int amount,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/balance/monthly/last/${category.id}/$amount'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((m) => MonthlyBalance.fromJson(m)).toList();
    } else {
      throw Exception('Fehler beim Laden der Bilanzen!');
    }
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/costtypes/'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((c) => Category.fromJson(c)).toList();
    } else {
      throw Exception('Fehler beim Laden der Kategorien!');
    }
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/costtypes/search/$query'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((c) => Category.fromJson(c)).toList();
    } else {
      throw Exception('Fehler beim Laden der Kategorien!');
    }
  }

  @override
  Future<void> addNewExpense(
    String name,
    double amount,
    Category category,
    DateTime date,
  ) async {
    final String id = category.id.toString();
    final int timestamp = date.millisecondsSinceEpoch ~/ 1000;
    await http.post(
      Uri.parse('$baseUrl/expenses/add/$timestamp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "amount": amount, "costTypeId": id}),
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
    final int timestamp = date.millisecondsSinceEpoch ~/ 1000;
    await http.post(
      Uri.parse('$baseUrl/expenses/update/$id/$timestamp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "amount": amount,
        "costTypeId": category.id,
      }),
    );
  }

  @override
  Future<void> deleteExpense(int id) async {
    await http.post(
      Uri.parse('$baseUrl/expenses/delete/$id'),
      headers: {"Content-Type": "application/json"},
    );
  }

  @override
  Future<void> addNewCategory(String name, IconData icon) async {
    await http.post(
      Uri.parse('$baseUrl/costtypes/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "icon": Category.iconToString(icon)}),
    );
  }

  @override
  Future<void> updateCategory(String name, IconData icon, int id) async {
    await http.post(
      Uri.parse('$baseUrl/costtypes/update/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "icon": Category.iconToString(icon)}),
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await http.post(
      Uri.parse('$baseUrl/costtypes/delete/$id'),
      headers: {"Content-Type": "application/json"},
    );
  }
}
