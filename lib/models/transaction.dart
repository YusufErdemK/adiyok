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
  final int quantity;
  final TransactionCategory category;
  final String? treeNodeId;
  final String? treeNodeName;
  final DateTime date;
  final String? description;
  final String? notes;
  final String? cardId; // null = nakit
  final bool isCash;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    this.quantity = 1,
    required this.category,
    this.treeNodeId,
    this.treeNodeName,
    DateTime? date,
    this.description,
    this.notes,
    this.cardId,
    this.isCash = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       date = date ?? DateTime.now();

  bool get isIncome => category.isIncome;
  bool get isExpense => category.isExpense;

  String get displayCategory => treeNodeName ?? category.label;
  String get displayEmoji => treeNodeName != null ? '🌳' : category.emoji;

  Transaction copyWith({
    String? title,
    double? amount,
    int? quantity,
    TransactionCategory? category,
    String? treeNodeId,
    String? treeNodeName,
    bool clearTreeNode = false,
    DateTime? date,
    String? description,
    String? notes,
    String? cardId,
    bool? isCash,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      treeNodeId: clearTreeNode ? null : (treeNodeId ?? this.treeNodeId),
      treeNodeName: clearTreeNode ? null : (treeNodeName ?? this.treeNodeName),
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      cardId: cardId ?? this.cardId,
      isCash: isCash ?? this.isCash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'quantity': quantity,
      'category': category.name,
      'treeNodeId': treeNodeId,
      'treeNodeName': treeNodeName,
      'date': date.toIso8601String(),
      'description': description,
      'notes': notes,
      'cardId': cardId,
      'isCash': isCash,
    };
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      quantity: (json['quantity'] as int?) ?? 1,
      category: TransactionCategory.fromString(json['category'] as String),
      treeNodeId: json['treeNodeId'] as String?,
      treeNodeName: json['treeNodeName'] as String?,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      cardId: json['cardId'] as String?,
      isCash: json['isCash'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, title: $title, amount: $amount, quantity: $quantity, category: ${category.label})';
}
