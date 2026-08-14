class Budget {
  final String category;
  final double limit;

  Budget({required this.category, required this.limit});

  Map<String, dynamic> toFirestore() => {
        'category': category,
        'limit': limit,
      };

  factory Budget.fromFirestore(Map<String, dynamic> data) {
    return Budget(
      category: data['category'] ?? 'Other',
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
