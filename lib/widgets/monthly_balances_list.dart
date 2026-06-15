import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/monthly_balance_card.dart';

class MonthlyBalancesList extends StatefulWidget {
  final Category category;
  final Future<List<MonthlyBalance>> monthlyBalancesFuture;
  const MonthlyBalancesList({
    super.key,
    required this.monthlyBalancesFuture,
    required this.category,
  });

  @override
  State<MonthlyBalancesList> createState() => _MonthlyBalancesListState();
}

class _MonthlyBalancesListState extends State<MonthlyBalancesList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.monthlyBalancesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${AppStrings.get('error')}: ${snapshot.error}'),
          );
        }

        return Expanded(
          child: ListView(
            children: snapshot.data!
                .where((m) => m.balance != 0)
                .map(
                  (m) => MonthlyBalanceCard(
                    monthlyBalance: m,
                    category: widget.category,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
