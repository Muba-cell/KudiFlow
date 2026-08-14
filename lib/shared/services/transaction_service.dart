import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model;

class TransactionService {
  static CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions');
  }

  /// Live stream of this user's transactions, newest first.
  static Stream<List<model.Transaction>> streamTransactions(String uid) {
    return _collection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.Transaction.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  static Future<void> addTransaction(String uid, model.Transaction tx) {
    return _collection(uid).add(tx.toFirestore());
  }

  static Future<void> updateTransaction(String uid, model.Transaction tx) {
    if (tx.id == null) {
      throw ArgumentError('Cannot update a transaction with no id');
    }
    return _collection(uid).doc(tx.id).update(tx.toFirestore());
  }

  static Future<void> deleteTransaction(String uid, String transactionId) {
    return _collection(uid).doc(transactionId).delete();
  }
}
