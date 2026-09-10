import 'package:frontend/models/category.dart';

class ConfiguredExpense {
  final int id;
  final String expenseName;
  final String newExpenseName;
  final Category category;
  const ConfiguredExpense({
    required this.id,
    required this.expenseName,
    required this.newExpenseName,
    required this.category,
  });

  factory ConfiguredExpense.fromJson(Map<String, dynamic> json) {
    return ConfiguredExpense(
      id: json['ID'],
      expenseName: json['ExpenseName'],
      newExpenseName: json['NewExpenseName'],
      category: Category.fromJson(json['category']),
    );
  }
}
