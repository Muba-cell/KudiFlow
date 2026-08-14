import 'package:flutter/material.dart';
import '../../../shared/models/budget.dart';
import '../../../shared/models/savings_goal.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/budget_service.dart';
import '../../../shared/services/savings_goal_service.dart';
import '../../../shared/services/transaction_service.dart';
import '../../../shared/services/notification_generator.dart';
import '../screens/notifications_screen.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  String get _uid => AuthService.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: TransactionService.streamTransactions(_uid),
      builder: (context, txSnapshot) {
        return StreamBuilder<List<Budget>>(
          stream: BudgetService.streamBudgets(_uid),
          builder: (context, budgetSnapshot) {
            return StreamBuilder<List<SavingsGoal>>(
              stream: SavingsGoalService.streamGoals(_uid),
              builder: (context, goalSnapshot) {
                final count = NotificationGenerator.generate(
                  budgets: budgetSnapshot.data ?? [],
                  savingsGoals: goalSnapshot.data ?? [],
                  transactions: txSnapshot.data ?? [],
                ).length;

                return IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none),
                      if (count > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                            child: Text(
                              '$count',
                              style: const TextStyle(color: Colors.white, fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
