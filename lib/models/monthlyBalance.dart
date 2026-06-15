class MonthlyBalance {
  final int year;
  final int month;
  final double balance;

  MonthlyBalance({
    required this.year,
    required this.month,
    required this.balance,
  });

  factory MonthlyBalance.fromJson(Map<String, dynamic> json) {
    return MonthlyBalance(
      year: json['year'],
      month: json['month'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
