enum BankName {
  ziraat('Ziraat Bankası', '🏦'),
  garanti('Garanti BBVA', '🟢'),
  akbank('Akbank', '🔴'),
  isbank('İş Bankası', '⚫'),
  yapikredi('Yapı Kredi', '🔵'),
  halkbank('Halkbank', '🟤'),
  vakifbank('VakıfBank', '🟡'),
  denizbank('Denizbank', '🌊'),
  qnb('QNB Finansbank', '🟣'),
  enpara('Enpara', '💜'),
  ykb('Yapı Kredi', '💙'),
  other('Diğer', '🏧');

  final String label;
  final String emoji;
  const BankName(this.label, this.emoji);

  static BankName fromString(String value) {
    return BankName.values.firstWhere(
      (b) => b.name == value,
      orElse: () => BankName.other,
    );
  }
}

class CardModel {
  final String id;
  final String name;
  final BankName bank;
  final bool isAnonymous;
  final String? cardHolder;
  final String? lastFourDigits;
  final bool isCredit;

  CardModel({
    String? id,
    required this.name,
    required this.bank,
    this.isAnonymous = false,
    this.cardHolder,
    this.lastFourDigits,
    this.isCredit = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bank': bank.name,
    'isAnonymous': isAnonymous,
    'cardHolder': cardHolder,
    'lastFourDigits': lastFourDigits,
    'isCredit': isCredit,
  };

  static CardModel fromJson(Map<String, dynamic> json) => CardModel(
    id: json['id'] as String,
    name: json['name'] as String,
    bank: BankName.fromString(json['bank'] as String),
    isAnonymous: json['isAnonymous'] as bool? ?? false,
    cardHolder: json['cardHolder'] as String?,
    lastFourDigits: json['lastFourDigits'] as String?,
    isCredit: json['isCredit'] as bool? ?? false,
  );
}
