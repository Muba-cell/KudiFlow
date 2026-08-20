import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/savings_goal.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/savings_goal_service.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  String get _uid => AuthService.currentUser?.uid ?? "";

  Future<void> _showCreateGoalDialog() async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("New Savings Goal"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Goal name",
                    hintText: "e.g. New Laptop",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter a name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Target amount (GH₵)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter a target amount";
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return "Enter a valid amount";
                    }
                    return null;
                  },
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
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
                try {
                  final goal = SavingsGoal(
                    name: nameController.text.trim(),
                    targetAmount: double.parse(targetController.text),
                    savedAmount: 0,
                  );
                  await SavingsGoalService.addGoal(_uid, goal);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Goal created"), duration: Duration(seconds: 2)),
                    );
                  }
                } catch (e) {
                  setDialogState(() => errorText = "Couldn't save: $e");
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddContributionDialog(SavingsGoal goal) async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add to "${goal.name}"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Amount (GH₵)",
                    hintText: "e.g. 50, or -20 to correct a mistake",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter an amount";
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed == 0) {
                      return "Enter a valid, non-zero amount";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  "This will be recorded as a Savings expense and deducted from your balance.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
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
                try {
                  final amount = double.parse(amountController.text);
                  await SavingsGoalService.addContribution(
                    _uid,
                    goal.id!,
                    goal.name,
                    amount,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Contribution added"), duration: Duration(seconds: 2)),
                    );
                  }
                } catch (e) {
                  setDialogState(() => errorText = "Couldn't save: $e");
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this goal?"),
        content: Text('Remove "${goal.name}"? This can\'t be undone. Past contributions stay in your transaction history.'),
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
    if (confirmed == true && goal.id != null) {
      await SavingsGoalService.deleteGoal(_uid, goal.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goal deleted"), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,
      appBar: AppBar(
        title: const Text("Savings Goals", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<SavingsGoal>>(
        stream: SavingsGoalService.streamGoals(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 48, color: Colors.black26),
                  const SizedBox(height: 12),
                  const Text(
                    "No savings goals yet.",
                    style: TextStyle(color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showCreateGoalDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Create Goal"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(
                goal: goal,
                onAddContribution: () => _showAddContributionDialog(goal),
                onDelete: () => _confirmDelete(goal),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.moonlitMint,
        foregroundColor: AppTheme.eclipseMint,
        onPressed: _showCreateGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onAddContribution;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onAddContribution,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal.targetAmount - goal.savedAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppTheme.eclipseMint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (goal.isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Achieved",
                      style: TextStyle(
                        color: Colors.green,
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
                  "GH₵${goal.savedAmount.toStringAsFixed(2)} saved",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "Target: GH₵${goal.targetAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: goal.isComplete ? Colors.green : AppTheme.eclipseMint,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(goal.progress * 100).toStringAsFixed(0)}% there",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (!goal.isComplete)
                  Text(
                    "GH₵${remaining.toStringAsFixed(2)} to go",
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
              ],
            ),
            if (!goal.isComplete) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddContribution,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Money"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.eclipseMint,
                    side: const BorderSide(color: AppTheme.eclipseMint),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
