import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/categories.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/transaction_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../widgets/spending_chart.dart';
import '../../budgets/screens/budget_screen.dart';
import '../../savings/screens/savings_goals_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../notifications/widgets/notification_bell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  String searchQuery = "";
  String typeFilter = "All";

  String get _uid => AuthService.currentUser?.uid ?? "";

  void _deleteTransaction(Transaction tx) {
    if (tx.id == null) return;
    TransactionService.deleteTransaction(_uid, tx.id!);
  }

  Future<void> _confirmDelete(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete transaction?"),
        content: Text('Remove "${tx.title}"? This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteTransaction(tx);
    }
  }

  Future<void> _editTransaction(Transaction tx) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(existingTransaction: tx),
      ),
    );
    if (result != null && result is Transaction) {
      await TransactionService.updateTransaction(_uid, result);
    }
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result != null && result is Transaction) {
      await TransactionService.addTransaction(_uid, result);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  double _balance(List<Transaction> transactions) =>
      transactions.fold(0.0, (sum, tx) => sum + tx.amount);

  double _totalIncome(List<Transaction> transactions) => transactions
      .where((tx) => tx.amount > 0)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double _totalExpenses(List<Transaction> transactions) => transactions
      .where((tx) => tx.amount < 0)
      .fold(0.0, (sum, tx) => sum + tx.amount.abs());

  List<Transaction> _filtered(List<Transaction> transactions) {
    return transactions.where((tx) {
      final matchesType = typeFilter == "All" || tx.type == typeFilter;
      final matchesSearch = searchQuery.isEmpty ||
          tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,
      appBar: AppBar(
        title: const Text(
          "KudiFlow",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetScreen()),
            ),
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'Budgets',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
            ),
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Savings Goals',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Reports',
          ),
          const NotificationBell(),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: TransactionService.streamTransactions(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Couldn't load your transactions: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final transactions = snapshot.data ?? [];
          final visibleTransactions = _filtered(transactions);
          final balance = _balance(transactions);
          final totalIncome = _totalIncome(transactions);
          final totalExpenses = _totalExpenses(transactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.eclipseMint,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Understand your money. Build better habits.",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.eclipseMint,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Available Balance", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Text(
                        "GH₵ ${balance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppTheme.moonlitMint,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: "Income",
                        amount: "GH₵ ${totalIncome.toStringAsFixed(2)}",
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: "Expenses",
                        amount: "GH₵ ${totalExpenses.toStringAsFixed(2)}",
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                const Text(
                  "Spending by Category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.eclipseMint,
                  ),
                ),
                const SizedBox(height: 12),
                SpendingChart(transactions: transactions),

                const SizedBox(height: 25),

                const Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.eclipseMint,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Tap to edit, long-press to delete",
                  style: TextStyle(color: Colors.black38, fontSize: 12),
                ),
                const SizedBox(height: 16),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search transactions...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["All", "Income", "Expense"].map((type) {
                      final isSelected = typeFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              typeFilter = type;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                if (visibleTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      transactions.isEmpty
                          ? "No transactions yet. Tap + to add one."
                          : "No transactions match your search.",
                      style: const TextStyle(color: Colors.black45),
                    ),
                  ),

                ...visibleTransactions.map(
                  (tx) => _TransactionTile(
                    title: tx.title,
                    category: tx.category,
                    amount: tx.formattedAmount,
                    date: tx.formattedDate,
                    icon: categoryIcon(tx.category),
                    onTap: () => _editTransaction(tx),
                    onLongPress: () => _confirmDelete(tx),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.moonlitMint,
        foregroundColor: AppTheme.eclipseMint,
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.auroraDust,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.eclipseMint,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final String date;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TransactionTile({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text("$category · $date"),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
