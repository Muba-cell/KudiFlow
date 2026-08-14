import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/categories.dart';

class SpendingChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingChart({super.key, required this.transactions});

  Map<String, double> get _categoryTotals {
    final expenses = transactions.where((tx) => tx.amount < 0);
    final Map<String, double> totals = {};
    for (final tx in expenses) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount.abs();
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final totals = _categoryTotals;

    if (totals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "No expenses yet to chart.",
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    final totalSpent = totals.values.fold(0.0, (sum, v) => sum + v);
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 45,
              sections: entries.map((entry) {
                final percent = (entry.value / totalSpent) * 100;
                return PieChartSectionData(
                  color: categoryColor(entry.key),
                  value: entry.value,
                  title: "${percent.toStringAsFixed(0)}%",
                  radius: 55,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${entry.key} · GH₵${entry.value.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
