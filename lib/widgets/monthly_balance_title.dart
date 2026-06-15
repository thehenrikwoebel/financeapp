import 'package:flutter/material.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/monthly_balance_text.dart';

class MonthlyBalanceTitle extends StatefulWidget {
  final Future<MonthlyBalance> monthlyBalanceFuture;
  const MonthlyBalanceTitle({super.key, required this.monthlyBalanceFuture});

  @override
  State<MonthlyBalanceTitle> createState() => _MonthlyBalanceTitleState();
}

class _MonthlyBalanceTitleState extends State<MonthlyBalanceTitle> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MonthlyBalance>(
      future: widget.monthlyBalanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Text('${AppStrings.get('error')}: ${snapshot.error}'),
          );
        }

        final monthlyBalance = snapshot.data!;

        return MonthlyBalanceText(monthlyBalance: monthlyBalance);
      },
    );
  }
}
