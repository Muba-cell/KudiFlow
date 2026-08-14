import '../models/app_notification.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';
import 'package:flutter/material.dart';

class NotificationGenerator {
  /// Builds the current list of relevant alerts from live app data.
  /// Pure function: same inputs always produce the same alerts, so it's
  /// easy to reason about and doesn't need its own storage.
  static List<AppNotification> generate({
    required List<Budget> budgets,
    required List<SavingsGoal> savingsGoals,
    required List<Transaction> transactions,
  }) {
    final List<AppNotification> notifications = [];
    final now = DateTime.now();

    // Budget alerts — compare each budget's limit to this month's spend.
    for (final budget in budgets) {
      final spent = transactions
          .where((tx) =>
              tx.amount < 0 &&
              tx.category == budget.category &&
              tx.date.year == now.year &&
              tx.date.month == now.month)
          .fold(0.0, (sum, tx) => sum + tx.amount.abs());

      if (budget.limit <= 0) continue;
      final percent = spent / budget.limit;

      if (percent >= 1.0) {
        notifications.add(AppNotification(
          title: "${budget.category} budget exceeded",
          message:
              "You've spent GH₵${spent.toStringAsFixed(2)} of your GH₵${budget.limit.toStringAsFixed(2)} limit this month.",
          icon: Icons.error_outline,
          severity: NotificationSeverity.critical,
        ));
      } else if (percent >= 0.8) {
        notifications.add(AppNotification(
          title: "${budget.category} budget almost reached",
          message:
              "You've used ${(percent * 100).toStringAsFixed(0)}% of your GH₵${budget.limit.toStringAsFixed(2)} limit this month.",
          icon: Icons.warning_amber_outlined,
          severity: NotificationSeverity.warning,
        ));
      }
    }

    // Savings goal alerts.
    for (final goal in savingsGoals) {
      if (goal.isComplete) {
        notifications.add(AppNotification(
          title: "Goal reached: ${goal.name}",
          message:
              "You've saved GH₵${goal.savedAmount.toStringAsFixed(2)} — target met.",
          icon: Icons.check_circle_outline,
          severity: NotificationSeverity.info,
        ));
      } else if (goal.progress >= 0.8) {
        notifications.add(AppNotification(
          title: "Almost there: ${goal.name}",
          message:
              "${(goal.progress * 100).toStringAsFixed(0)}% saved toward your GH₵${goal.targetAmount.toStringAsFixed(2)} goal.",
          icon: Icons.emoji_events_outlined,
          severity: NotificationSeverity.info,
        ));
      }
    }

    return notifications;
  }
}
