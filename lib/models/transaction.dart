enum TransactionCategory {
  salary('Maaş', '💼'),
  freelance('Serbest Çalışma', '💻'),
  business('İş', '🏢'),
  investment('Yatırım', '📈'),
  otherIncome('Diğer Gelir', '💰'),
  rent('Kira', '🏠'),
  food('Yemek', '🍽️'),
  transport('Ulaşım', '🚗'),
  utilities('Faturalar', '💡'),
  entertainment('Eğlence', '🎮'),
  shopping('Alışveriş', '🛍️'),
  healthcare('Sağlık', '⚕️'),
  education('Eğitim', '📚'),
  otherExpense('Diğer Gider', '📉');

  final String label;
  final String emoji;

  const TransactionCategory(this.label, this.emoji);

  bool get isIncome => [
    TransactionCategory.salary,
    TransactionCategory.freelance,
    TransactionCategory.business,
    TransactionCategory.investment,
    TransactionCategory.otherIncome,
  ].contains(this);

  bool get isExpense => !isIncome;

  static TransactionCategory fromString(String value) {
    return TransactionCategory.values.firstWhere(
      (cat) => cat.name == value,
      orElse: () => TransactionCategory.otherExpense,
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionCategory category;
  final DateTime date;
  final String? description;
  final String? notes;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    DateTime? date,
    this.description,
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       date = date ?? DateTime.now();

  bool get isIncome => category.isIncome;
  bool get isExpense => category.isExpense;

  Transaction copyWith({
    String? title,
    double? amount,
    TransactionCategory? category,
    DateTime? date,
    String? description,
    String? notes,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  // Serialization methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'description': description,
      'notes': notes,
    };
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: TransactionCategory.fromString(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, title: $title, amount: $amount, category: ${category.label})';
}
