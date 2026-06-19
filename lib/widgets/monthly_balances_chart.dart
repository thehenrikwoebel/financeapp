import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/monthlyBalance.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/utils/formatter.dart';

class MonthlyBalancesChart extends StatefulWidget {
  final Future<List<MonthlyBalance>> monthlyBalancesFuture;
  const MonthlyBalancesChart({super.key, required this.monthlyBalancesFuture});

  @override
  State<MonthlyBalancesChart> createState() => _MonthlyBalancesChartState();
}

class _MonthlyBalancesChartState extends State<MonthlyBalancesChart> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MonthlyBalance>>(
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

        final data = snapshot.data!.where((m) => m.balance != 0).toList()
          ..sort(
            (a, b) => a.year != b.year
                ? a.year.compareTo(b.year)
                : a.month.compareTo(b.month),
          );

        if (data.isEmpty) {
          return Center(child: Text(AppStrings.get('no_data')));
        }

        final spots = data
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.balance))
            .toList();

        final maxBalance = data
            .map((m) => m.balance)
            .reduce((a, b) => a > b ? a : b);

        final minBalance = data
            .map((m) => m.balance)
            .reduce((a, b) => a < b ? a : b);

        final range = maxBalance - minBalance;
        final labelCount = 4;

        final rawInterval = range == 0 ? 1.0 : range / labelCount;
        final interval = niceInterval(rawInterval);

        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                dotData: FlDotData(show: true),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(0)}${AppStrings.get('currency_symbol')}',
                      TextStyle(color: spot.y >= 0 ? Colors.green : Colors.red),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.min || value == meta.max) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '${value.toInt()}${AppStrings.get('currency_symbol')}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        color: value.toInt() >= 0 ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) {
                      return const SizedBox.shrink();
                    }

                    final months = [
                      AppStrings.get('jan'),
                      AppStrings.get('feb'),
                      AppStrings.get('mar'),
                      AppStrings.get('apr'),
                      AppStrings.get('may_short'),
                      AppStrings.get('jun'),
                      AppStrings.get('jul'),
                      AppStrings.get('aug'),
                      AppStrings.get('sep'),
                      AppStrings.get('oct'),
                      AppStrings.get('nov'),
                      AppStrings.get('dec'),
                    ];
                    final m = data[index];
                    return Text(months[m.month - 1]);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
