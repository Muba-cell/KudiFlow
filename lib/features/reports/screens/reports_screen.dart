import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/categories.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/transaction_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String get _uid => AuthService.currentUser?.uid ?? "";

  List<Transaction> _thisMonth(List<Transaction> all) {
    final now = DateTime.now();
    return all
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();
  }

  Map<String, double> _categoryTotals(List<Transaction> transactions) {
    final Map<String, double> totals = {};
    for (final tx in transactions) {
      if (tx.amount >= 0) continue;
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount.abs();
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    final monthLabel = "${monthNames[now.month - 1]} ${now.year}";

    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,
      appBar: AppBar(
        title: const Text("Reports", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: TransactionService.streamTransactions(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTransactions = snapshot.data ?? [];
          final monthTransactions = _thisMonth(allTransactions);

          final income = monthTransactions
              .where((tx) => tx.amount > 0)
              .fold(0.0, (sum, tx) => sum + tx.amount);
          final expenses = monthTransactions
              .where((tx) => tx.amount < 0)
              .fold(0.0, (sum, tx) => sum + tx.amount.abs());
          final net = income - expenses;

          final categoryTotals = _categoryTotals(monthTransactions);
          final sortedCategories = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.eclipseMint,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Summary of this month's activity",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: "Income",
                        amount: income,
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: "Expenses",
                        amount: expenses,
                        color: Colors.red,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StatCard(
                  label: net >= 0 ? "This Month's Net" : "This Month's Shortfall",
                  amount: net.abs(),
                  color: net >= 0 ? AppTheme.eclipseMint : Colors.red,
                  icon: net >= 0 ? Icons.trending_up : Icons.warning_amber,
                  fullWidth: true,
                ),

                const SizedBox(height: 28),
                const Text(
                  "Spending by Category",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.eclipseMint,
                  ),
                ),
                const SizedBox(height: 12),

                if (sortedCategories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No expenses recorded this month yet.",
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: sortedCategories.map((entry) {
                        final percent =
                            expenses > 0 ? (entry.value / expenses) * 100 : 0.0;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: categoryColor(entry.key).withValues(alpha: 0.15),
                            child: Icon(categoryIcon(entry.key), color: categoryColor(entry.key)),
                          ),
                          title: Text(entry.key),
                          subtitle: Text("${percent.toStringAsFixed(0)}% of expenses"),
                          trailing: Text(
                            "GH₵${entry.value.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "GH₵${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
