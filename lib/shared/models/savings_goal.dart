class SavingsGoal {
  final String? id;
  final String name;
  final double targetAmount;
  final double savedAmount;

  SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
  });

  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => savedAmount >= targetAmount;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
      };

  factory SavingsGoal.fromFirestore(String id, Map<String, dynamic> data) {
    return SavingsGoal(
      id: id,
      name: data['name'] ?? 'Goal',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (data['savedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
