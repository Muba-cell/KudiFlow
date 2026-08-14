import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String? id; // Firestore document ID — null for a not-yet-saved transaction
  final String title;
  final String type; // "Income" or "Expense"
  final String category;
  final double amount; // positive = income, negative = expense
  final DateTime date;

  Transaction({
    this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });

  String get formattedAmount {
    final sign = amount >= 0 ? "+" : "-";
    return "$sign GH₵${amount.abs().toStringAsFixed(2)}";
  }

  String get formattedDate {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final month = months[date.month - 1];
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? "PM" : "AM";
    return "$month ${date.day}, ${date.year} · $hour12:$minute $period";
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'type': type,
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date),
      };

  factory Transaction.fromFirestore(String id, Map<String, dynamic> data) {
    final rawDate = data['date'];
    final parsedDate = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return Transaction(
      id: id,
      title: data['title'] ?? 'Transaction',
      type: data['type'] ?? 'Expense',
      category: data['category'] ?? 'Other',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
    );
  }

  /// Returns a copy of this transaction with a different id — used when
  /// editing, to carry the original document id forward to the update.
  Transaction copyWithId(String? newId) => Transaction(
        id: newId,
        title: title,
        type: type,
        category: category,
        amount: amount,
        date: date,
      );
}
