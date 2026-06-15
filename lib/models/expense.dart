import 'category.dart';

class Expense {
  final int id;
  final String title;
  final double amount;
  final Category category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: Category.fromJson(json['category']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num).toInt() * 1000,
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['updatedAt'] as num).toInt() * 1000,
            )
          : null,
    );
  }
}
