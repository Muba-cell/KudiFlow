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

  /// Adds (or, with a negative amount, corrects/reduces) a goal's saved
  /// total, and records a matching transaction so the balance always
  /// reflects reality.
  ///
  /// Positive amount: recorded as a "Savings" expense (money set aside,
  /// balance goes down).
  /// Negative amount: recorded as a "Savings" income (money returned to
  /// spendable balance, goal total goes down) — this is how mistakes
  /// get corrected, as a new event rather than silently rewriting history.
  static Future<void> addContribution(
    String uid,
    String goalId,
    String goalName,
    double amount,
  ) async {
    await _collection(uid).doc(goalId).update({
      'savedAmount': FieldValue.increment(amount),
    });

    final isCorrection = amount < 0;

    await TransactionService.addTransaction(
      uid,
      model.Transaction(
        title: isCorrection
            ? 'Savings correction: $goalName'
            : 'Savings: $goalName',
        type: isCorrection ? 'Income' : 'Expense',
        category: 'Savings',
        amount: isCorrection ? amount.abs() : -amount,
        date: DateTime.now(),
      ),
    );
  }

  static Future<void> deleteGoal(String uid, String goalId) {
    return _collection(uid).doc(goalId).delete();
  }
}
