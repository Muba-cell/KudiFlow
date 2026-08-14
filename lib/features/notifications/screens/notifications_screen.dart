import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/models/budget.dart';
import '../../../shared/models/savings_goal.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/budget_service.dart';
import '../../../shared/services/savings_goal_service.dart';
import '../../../shared/services/transaction_service.dart';
import '../../../shared/services/notification_generator.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String get _uid => AuthService.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: TransactionService.streamTransactions(_uid),
        builder: (context, txSnapshot) {
          return StreamBuilder<List<Budget>>(
            stream: BudgetService.streamBudgets(_uid),
            builder: (context, budgetSnapshot) {
              return StreamBuilder<List<SavingsGoal>>(
                stream: SavingsGoalService.streamGoals(_uid),
                builder: (context, goalSnapshot) {
                  final waiting = txSnapshot.connectionState == ConnectionState.waiting ||
                      budgetSnapshot.connectionState == ConnectionState.waiting ||
                      goalSnapshot.connectionState == ConnectionState.waiting;

                  if (waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notifications = NotificationGenerator.generate(
                    budgets: budgetSnapshot.data ?? [],
                    savingsGoals: goalSnapshot.data ?? [],
                    transactions: txSnapshot.data ?? [],
                  );

                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none, size: 48, color: Colors.black26),
                          const SizedBox(height: 12),
                          const Text(
                            "You're all caught up.",
                            style: TextStyle(color: Colors.black45),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Budget and savings alerts will show up here.",
                            style: TextStyle(color: Colors.black38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: n.color.withValues(alpha: 0.12),
                            child: Icon(n.icon, color: n.color),
                          ),
                          title: Text(
                            n.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(n.message, style: const TextStyle(fontSize: 13)),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
