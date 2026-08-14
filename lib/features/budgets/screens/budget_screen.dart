import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/budget.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/categories.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/budget_service.dart';
import '../../../shared/services/transaction_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String get _uid => AuthService.currentUser?.uid ?? "";

  Future<void> _showSetBudgetDialog({Budget? existing}) async {
    String selectedCategory = existing?.category ?? expenseCategories.first;
    final limitController = TextEditingController(
      text: existing != null ? existing.limit.toStringAsFixed(0) : "",
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? "Set a Budget" : "Edit Budget"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: expenseCategories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: existing != null
                      ? null // don't allow changing category when editing
                      : (value) {
                          if (value != null) {
                            setDialogState(() => selectedCategory = value);
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Monthly Limit (GH₵)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter a limit";
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return "Enter a valid amount";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final limit = double.parse(limitController.text);
                await BudgetService.setBudget(
                  _uid,
                  Budget(category: selectedCategory, limit: limit),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteBudget(String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove this budget?"),
        content: Text('Remove the budget for "$category"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await BudgetService.deleteBudget(_uid, category);
    }
  }

  /// Sums this month's expenses per category from a transaction list.
  Map<String, double> _spentThisMonth(List<Transaction> transactions) {
    final now = DateTime.now();
    final Map<String, double> totals = {};
    for (final tx in transactions) {
      if (tx.amount >= 0) continue; // only expenses count against budgets
      if (tx.date.year != now.year || tx.date.month != now.month) continue;
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount.abs();
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,
      appBar: AppBar(
        title: const Text("Budgets", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: TransactionService.streamTransactions(_uid),
        builder: (context, txSnapshot) {
          final transactions = txSnapshot.data ?? [];
          final spentByCategory = _spentThisMonth(transactions);

          return StreamBuilder<List<Budget>>(
            stream: BudgetService.streamBudgets(_uid),
            builder: (context, budgetSnapshot) {
              if (budgetSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final budgets = budgetSnapshot.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Set spending limits per category and track them against this month's expenses.",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: budgets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.pie_chart_outline,
                                      size: 48, color: Colors.black26),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No budgets set yet.",
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () => _showSetBudgetDialog(),
                                    icon: const Icon(Icons.add),
                                    label: const Text("Create Budget"),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: budgets.length,
                              itemBuilder: (context, index) {
                                final budget = budgets[index];
                                final spent = spentByCategory[budget.category] ?? 0.0;
                                return _BudgetCard(
                                  budget: budget,
                                  spent: spent,
                                  icon: categoryIcon(budget.category),
                                  onTap: () => _showSetBudgetDialog(existing: budget),
                                  onDelete: () => _confirmDeleteBudget(budget.category),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.moonlitMint,
        foregroundColor: AppTheme.eclipseMint,
        onPressed: () => _showSetBudgetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.icon,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percent = budget.limit > 0 ? (spent / budget.limit).clamp(0.0, 1.5) : 0.0;
    final remaining = budget.limit - spent;
    final isOver = spent > budget.limit;
    final isNearLimit = !isOver && percent >= 0.8;

    final Color statusColor = isOver
        ? Colors.red
        : isNearLimit
            ? Colors.orange
            : Colors.green;
    final String statusLabel = isOver
        ? "Over Budget"
        : isNearLimit
            ? "Near Limit"
            : "On Track";

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.eclipseMint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      budget.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Colors.black45,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Spent: GH₵${spent.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Limit: GH₵${budget.limit.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent > 1.0 ? 1.0 : percent,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${(percent * 100).clamp(0, 999).toStringAsFixed(0)}% consumed",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    isOver
                        ? "Over by GH₵${(-remaining).toStringAsFixed(2)}"
                        : "Remaining: GH₵${remaining.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOver ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
