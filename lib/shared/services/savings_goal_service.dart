import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart' as model;
import 'transaction_service.dart';

class SavingsGoalService {
  static CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savingsGoals');
  }

  static Stream<List<SavingsGoal>> streamGoals(String uid) {
    return _collection(uid).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SavingsGoal.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  static Future<void> addGoal(String uid, SavingsGoal goal) {
    return _collection(uid).add(goal.toFirestore());
  }

  static Future<void> updateGoal(String uid, SavingsGoal goal) {
    if (goal.id == null) {
      throw ArgumentError('Cannot update a goal with no id');
    }
    return _collection(uid).doc(goal.id).update(goal.toFirestore());
  }

  /// Adds a contribution to a goal AND records it as a real "Savings"
  /// expense transaction, so it actually deducts from the user's balance.
  /// This keeps the dashboard balance as the single source of truth.
  static Future<void> addContribution(
    String uid,
    String goalId,
    String goalName,
    double amount,
  ) async {
    await _collection(uid).doc(goalId).update({
      'savedAmount': FieldValue.increment(amount),
    });

    await TransactionService.addTransaction(
      uid,
      model.Transaction(
        title: 'Savings: $goalName',
        type: 'Expense',
        category: 'Savings',
        amount: -amount,
        date: DateTime.now(),
      ),
    );
  }

  static Future<void> deleteGoal(String uid, String goalId) {
    return _collection(uid).doc(goalId).delete();
  }
}
