import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';

class BudgetService {
  static CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('budgets');
  }

  /// Live stream of this user's budgets.
  static Stream<List<Budget>> streamBudgets(String uid) {
    return _collection(uid).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Budget.fromFirestore(doc.data()))
        .toList());
  }

  /// Sets (creates or overwrites) the budget for a category.
  /// Using the category name as the document ID keeps it to one budget
  /// per category, so re-setting a limit just updates the existing one.
  static Future<void> setBudget(String uid, Budget budget) {
    return _collection(uid).doc(budget.category).set(budget.toFirestore());
  }

  static Future<void> deleteBudget(String uid, String category) {
    return _collection(uid).doc(category).delete();
  }
}
